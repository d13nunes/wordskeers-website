import Foundation
import SwiftUI

/// ViewModel responsible for coordinating game logic and UI updates
@Observable class GameViewModel: WordSelectionVisualizing {
  let gameHistoryService: GameHistoryServicing
  let gameConfigurationFactory: GameConfigurationFactoring
  let wallet: Wallet

  var coinsToastAmount: Int = 0
  var showCoinsToast: Bool = false

  /// The ad manager for displaying ads
  let adManager: AdManaging

  let selectionHandler: SelectionHandler

  var canShowBannerAd: Bool {
    adManager.canShowAds
  }

  var gameConfiguration: GameConfiguration {
    gameManager.configuration
  }

  var words: [WordData] {
    gameManager.words
  }

  var selectedLetters: [String] {
    selectionHandler.selectedCells.map { grid[$0.row][$0.col] }
  }

  private(set) var pathValidator: PathValidator
  /// The current game state
  var gameState: GameState {
    gameManager.currentState
  }

  /// The game grid
  var grid: [[String]] {
    gameManager.grid
  }

  var wordValidator: WordValidator {
    gameManager.wordValidator
  }

  var showDailyRewardsBadge: Bool {
    dailyRewardsService.showDailyRewardsBadge
  }

  /// The game state manager
  private(set) var gameManager: GameManager
  var isShowingPauseMenu = false
  var isShowingCompletionView = false
  var newGameSelectionViewModel: NewGameSelectionViewModel?

  var discoveredCells: [Position] {
    gameManager.discoveredCells
  }

  /// Time elapsed in the current game
  var timeElapsed: TimeInterval {
    gameManager.timeElapsed
  }

  /// Formatted time string (MM:SS)
  var formattedTime: String {
    let minutes = Int(timeElapsed) / 60
    let seconds = Int(timeElapsed) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  /// Total number of words to find
  var totalWords: Int {
    gameManager.totalWords
  }

  /// Number of words found
  var foundWordCount: Int {
    gameManager.foundWordCount
  }

  var isShowingStoreView = false
  var showNotEnoughCoinsAlert = false
  var isShowingDailyRewardsView = false
  /// Whether to show daily rewards screen from a notification tap
  var showDailyRewardsFromNotification = false {
    didSet {
      if showDailyRewardsFromNotification {
        isShowingDailyRewardsView = true
        showDailyRewardsFromNotification = false
      }
    }
  }

  let storeService: StoreService
  let dailyRewardsService: DailyRewardsService
  let analytics: AnalyticsService
  private(set) var powerUpManager: PowerUpManager
  private var firstGame = true

  init(
    gameManager: GameManager,
    gameConfigurationFactory: GameConfigurationFactoring,
    adManager: AdManaging,
    analytics: AnalyticsService,
    gameHistoryService: GameHistoryServicing,
    wallet: Wallet
  ) {
    self.gameManager = gameManager
    self.gameConfigurationFactory = gameConfigurationFactory
    self.adManager = adManager
    self.powerUpManager = PowerUpManager(
      adManager: adManager,
      analytics: analytics,
      wallet: wallet
    )
    self.wallet = wallet
    self.analytics = analytics
    self.storeService = StoreService(
      wallet: wallet,
      analytics: analytics,
      adManager: adManager
    )
    self.dailyRewardsService = DailyRewardsService(
      wallet: wallet, adManager: adManager, analytics: analytics)
    self.gameHistoryService = gameHistoryService
    self.pathValidator = PathValidator(
      allowedDirections: Direction.all,
      gridSize: gameManager.grid.count
    )
    self.selectionHandler = SelectionHandler(
      allowedDirections: Direction.all,
      gridSize: gameManager.grid.count
    )
    self.selectionHandler.onDragStarted = onDragStarted
    self.selectionHandler.onDragEnd = onDragEnd
    Task { @MainActor in
      createNewGame(gameManager: gameManager)
    }
  }

  @MainActor
  func createNewGame(gameManager: GameManager) {
    self.gameManager = gameManager
    self.gameManager.tryTransitioningTo(state: .start)
    self.pathValidator = PathValidator(
      allowedDirections: Direction.all,
      gridSize: self.gameManager.grid.count
    )
    powerUpManager.setupPowerUps(
      enabledPowerUps: [.hint, .directional],
      words: gameManager.words
    )
  }

  // MARK: - Game Control Methods
  @MainActor
  func startNewGame(on viewController: UIViewController) async {
    _ = await adManager.onGameComplete(on: viewController)
    if !firstGame {
      track(event: .gameQuit)
    }
    onShowGameSelection()
  }

  @MainActor
  func onViewAppear() {
    if firstGame {
      onShowGameSelection()
      firstGame = false
    } else {
      gameManager.tryTransitioningTo(state: .resume)
    }
  }

  func onViewDisappear() {
    gameManager.tryTransitioningTo(state: .pause)
  }

  /// Pauses the game
  func pauseGame() {
    track(event: .gamePaused)
    gameManager.tryTransitioningTo(state: .pause)
  }

  func onShowPauseMenu() {
    isShowingPauseMenu = true
    pauseGame()
  }

  @MainActor
  func completionCollectCoins(double: Bool, on viewController: UIViewController) async {
    var amount = 5
    let event: AnalyticsEvent = double ? .gameCoinsCollectedDouble : .gameCoinsCollected
    if double {
      let success = await adManager.showRewardedAd(on: viewController)
      if success {
        amount = 10
      }
    } else {
      _ = await adManager.onGameComplete(on: viewController)
    }
    wallet.addCoins(amount)
    coinsToastAmount = amount
    showCoinsToast = true
    track(event: event)
    onShowGameSelection()
  }

  @MainActor
  func onShowGameSelection() {
    isShowingCompletionView = false
    isShowingPauseMenu = false
    newGameSelectionViewModel = NewGameSelectionViewModel(onStartGame: { difficulty in
      let gridGenerator = self.gameConfigurationFactory.createConfiguration(
        configuration: DifficultyConfigMap.config(for: difficulty))
      let gameManager = GameManager(gridGenerator: gridGenerator)
      self.createNewGame(gameManager: gameManager)
      self.track(event: .gameStarted)
      self.onHideGameSelection()
    })
  }

  func onHideGameSelection() {
    newGameSelectionViewModel = nil
  }

  func hidePauseMenu() {
    isShowingPauseMenu = false
  }

  /// Resumes the game
  func resumeGame() {
    track(event: .gameResumed)
    gameManager.tryTransitioningTo(state: .resume)
  }

  @MainActor
  func onDragStarted() {
    clearHint()
  }

  @MainActor
  func onDragEnd(positions: [Position]) {
    _ = checkIfIsWord(in: positions)
    clearHint()
  }

  /// Submits positions for validation
  func checkIfIsWord(in positions: [Position]) -> Bool {
    let word = gameManager.validateWord(in: positions)
    let foundWord = word != nil
    if foundWord {
      track(event: .gameWordFound)
    }
    if gameManager.currentState == .complete {
      track(event: .gameCompleted)
      Task {
        await gameHistoryService.save(
          record: GameHistoryRecord(
            gridId: gameManager.gridId,
            gameMode: gameManager.mode.rawValue,
            score: gameManager.score,
            timeTaken: gameManager.timeElapsed,
            playedAt: .now,
            powerUpsUsed: powerUpManager.powerUpsActivated
          ))
      }
      isShowingCompletionView = true
    }
    return foundWord
  }

  /// Returns the color for a cell based on its state
  func cellColor(at position: Position, isSelected: Bool) -> Color {
    if isSelected {
      return .blue.opacity(0.4)
    } else if discoveredCells.contains(position) {
      return .green.opacity(0.3)
    } else if powerUpManager.hintedPositions.contains(position) {
      return .yellow.opacity(0.3)
    } else {
      return .clear
    }
  }

  @MainActor
  func clearHint() {
    powerUpManager.clearActivePowerUp()
  }

  // MARK: - Private Methods

  func getGameOverViewFormattedTime() -> String {
    return gameOverViewFormattedTime(timeElapsed)
  }

  func gameOverViewFormattedTime(_ timeElapsed: TimeInterval) -> String {
    return timeElapsed.formattedTime()
  }

  @MainActor
  func showStoreView() {
    isShowingStoreView = true
  }

  @MainActor
  func hideStoreView() {
    isShowingStoreView = false
    showNotEnoughCoinsAlert = false
  }

  func showDailyRewardsView() {
    isShowingDailyRewardsView = true
  }

  func closeDailyRewardsView() {
    isShowingDailyRewardsView = false
  }
}

extension TimeInterval {
  func formattedTime() -> String {
    var string = ""
    let hours = Int(self) / 3600
    if hours > 0 {
      string += "\(hours)h "
    }
    let minutes = (Int(self) % 3600) / 60
    if minutes > 0 {
      string += "\(minutes)m "
    }
    let seconds = Int(self) % 60
    if seconds > 0 {
      string += "\(seconds)s"
    }
    return string.isEmpty ? "0s" : string
  }
}

extension GameViewModel {
  func trackWordFound(word: String) {
    analytics.trackEvent(
      .gameWordFound,
      parameters: AnalyticsParamsCreator.wordFound(
        gridId: gameManager.gridId,
        config: gameManager.configuration,
        word: word,
        wordsLeft: gameManager.totalWords - gameManager.foundWordCount,
        timeElapsed: timeElapsed
      )
    )
  }

  func track(event: AnalyticsEvent) {
    let parameters = AnalyticsParamsCreator.gameState(
      gridId: gameManager.gridId,
      config: gameManager.configuration,
      wordsLeft: gameManager.totalWords - gameManager.foundWordCount,
      timeElapsed: timeElapsed
    )
    analytics.trackEvent(
      event,
      parameters: parameters
    )
  }
}
