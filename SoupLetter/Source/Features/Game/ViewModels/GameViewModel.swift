import Foundation
import SwiftUI

/// ViewModel responsible for coordinating game logic and UI updates
@Observable class GameViewModel {

  let gameConfigurationFactory: GameConfigurationFactoryProtocol
  private let adManager: AdManaging

  let selectionHandler: SelectionHandler

  var gameConfiguration: GameConfiguration {
    gameManager.configuration
  }

  var words: [WordData] {
    gameManager.words
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

  var canRequestHint: Bool {
    hintManager.canRequestHint
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

  private(set) var hintManager: HintManager
  private var firstGame = true
  init(
    gameManager: GameManager,
    gameConfigurationFactory: GameConfigurationFactoryProtocol,
    adManager: AdManaging
  ) {
    self.gameManager = gameManager
    self.gameConfigurationFactory = gameConfigurationFactory
    self.adManager = adManager
    self.hintManager = HintManager(adManager: adManager)
    self.pathValidator = PathValidator(
      allowedDirections: Directions.all,
      gridSize: gameManager.grid.count
    )
    self.selectionHandler = SelectionHandler(
      allowedDirections: Directions.all,
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
      allowedDirections: Directions.all,
      gridSize: self.gameManager.grid.count
    )
    hintManager.clearHint()
  }

  // MARK: - Game Control Methods
  @MainActor
  func startNewGame(on viewController: UIViewController) async {
    _ = await adManager.onGameComplete(on: viewController)
    onShowGameSelection()
  }

  func onViewAppear() {
    gameManager.tryTransitioningTo(state: .resume)
  }

  func onViewDisappear() {
    gameManager.tryTransitioningTo(state: .pause)
  }

  /// Pauses the game
  func pauseGame() {
    gameManager.tryTransitioningTo(state: .pause)
  }

  func onShowPauseMenu() {
    isShowingPauseMenu = true
    pauseGame()
  }

  @MainActor
  func onShowGameSelection() {
    isShowingCompletionView = false
    isShowingPauseMenu = false
    newGameSelectionViewModel = NewGameSelectionViewModel(onStartGame: { setting in
      let configuration = self.gameConfigurationFactory.createRandomConfiguration(setting: setting)
      let gameManager = GameManager(configuration: configuration)
      self.createNewGame(gameManager: gameManager)
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
    gameManager.tryTransitioningTo(state: .resume)
  }

  @MainActor
  func onDragStarted() {
    hintManager.clearHint()
  }

  @MainActor
  func onDragEnd(positions: [Position]) {
    if checkIfIsWord(in: positions) {
    }
    clearHint()
  }

  /// Submits positions for validation
  func checkIfIsWord(in positions: [Position]) -> Bool {
    let word = gameManager.validateWord(in: positions)
    if gameManager.currentState == .complete {
      isShowingCompletionView = true
    }
    return word != nil
  }

  /// Returns the color for a cell based on its state
  func cellColor(at position: Position, isSelected: Bool) -> Color {
    if isSelected {
      return .blue.opacity(0.4)
    } else if discoveredCells.contains(position) {
      return .green.opacity(0.3)
    } else if hintManager.positions.contains(position) {
      return .yellow.opacity(0.3)
    } else {
      return .clear
    }
  }

  func requestHint(on viewController: UIViewController) async {
    _ = await hintManager.requestHint(words: self.words, on: viewController)
  }

  @MainActor
  func clearHint() {
    hintManager.clearHint()
  }

  // MARK: - Private Methods

  private func getGridSize(for difficulty: Difficulty) -> Int {
    switch difficulty {
    case .easy: return 6
    case .medium: return 8
    case .hard: return 10
    }
  }

  func getGameOverViewFormattedTime() -> String {
    return gameOverViewFormattedTime(timeElapsed)
  }

  func gameOverViewFormattedTime(_ timeElapsed: TimeInterval) -> String {
    return timeElapsed.formattedTime()
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
