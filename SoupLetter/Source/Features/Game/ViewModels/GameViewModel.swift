import Foundation
import SwiftUI

/// ViewModel responsible for coordinating game logic and UI updates
@Observable class GameViewModel {

  let gameConfigurationFactory: GameConfigurationFactoryProtocol
  private let adManager: AdManager

  var words: [WordData] {
    gameManager.words
  }

  /// The current game state
  var gameState: GameState {
    gameManager.currentState
  }

  /// The game grid
  var grid: [[String]] {
    gameManager.grid
  }
  /// The game state manager
  private(set) var gameManager: GameManager
  var showingPauseMenu = false
  var showingCompletionView = false

  private var foundCells: [(Int, Int)] {
    gameManager.selectedCells
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

  init(
    gameManager: GameManager,
    gameConfigurationFactory: GameConfigurationFactoryProtocol,
    adManager: AdManager
  ) {
    self.gameManager = gameManager
    self.gameConfigurationFactory = gameConfigurationFactory
    self.adManager = adManager
    startNewGame()
  }

  // MARK: - Game Control Methods
  private var firstGame = true
  func startNewGame() {
    showingCompletionView = false
    let configuration = gameConfigurationFactory.createRandomConfiguration()
    let gameManager = GameManager(configuration: configuration)
    self.gameManager = gameManager
    gameManager.tryTransitioningTo(state: .start)
    if !firstGame {
      Task {
        await adManager.onGameComplete()
      }
    }
    firstGame = false
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
    showingPauseMenu = true
    pauseGame()
  }

  func hidePauseMenu() {
    showingPauseMenu = false
  }

  /// Resumes the game
  func resumeGame() {
    gameManager.tryTransitioningTo(state: .resume)
  }

  /// Submits positions for validation
  func checkIfIsWord(in positions: [(Int, Int)]) -> Bool {
    let word = gameManager.validateWord(in: positions)
    if gameManager.currentState == .complete {
      showingCompletionView = true
    }
    return word != nil
  }

  /// Returns the color for a cell based on its state
  func cellColor(for coordinate: (Int, Int), isSelected: Bool) -> Color {
    if isSelected {
      return .blue.opacity(0.4)
    } else if foundCells.contains(where: { $0 == coordinate }) {
      return .green.opacity(0.3)
    } else {
      return .clear
    }
  }

  // MARK: - Private Methods

  private func getGridSize(for difficulty: Difficulty) -> Int {
    switch difficulty {
    case .easy: return 6
    case .medium: return 8
    case .hard: return 10
    }
  }
}
