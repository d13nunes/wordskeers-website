import Foundation
import SwiftUI

/// ViewModel responsible for coordinating game logic and UI updates
@Observable class GameViewModel {
  // MARK: - Properties
  var foundWords: [String] {
    gameManager.foundWords
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
  private let gameManager: GameStateManager
  private let wordStore: WordListStore

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

  // MARK: - Initialization
  init(gameManager: GameStateManager) {
    self.gameManager = gameManager
    self.wordStore = WordListStore()
  }

  // MARK: - Game Control Methods

  /// Starts a new game with the selected category and difficulty
  func startNewGame() {
    startGame()
  }

  /// Starts the game
  func startGame() {
    gameManager.startGame()
  }

  /// Pauses the game
  func pauseGame() {
    gameManager.pauseGame()
  }

  /// Resumes the game
  func resumeGame() {
    gameManager.resumeGame()
  }

  /// Starts the next level
  func startNextLevel() {
    gameManager.showAd()
  }

  /// Submits positions for validation
  func checkIfIsWord(in positions: [(Int, Int)]) -> Bool {
    guard gameManager.checkIfIsWord(in: positions) != nil else {
      return false
    }

    if foundWords.count == totalWords {
      print("You won!")
    }
    return true
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

  /// Returns the scale transform for a cell
  func cellScale(for coordinate: (Int, Int), isSelected: Bool) -> CGFloat {
    isSelected ? 1.1 : 1.0
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

#Preview {
  let configuration = GameConfiguration(gridSize: 10, words: ["Hello", "World"])
  let gameManager = GameStateManager(configuration: configuration)
  GameView(viewModel: GameViewModel(gameManager: gameManager), path: .constant([]))
}
