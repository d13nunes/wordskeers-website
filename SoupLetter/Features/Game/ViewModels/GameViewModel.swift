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
  }

  // MARK: - Game Control Methods

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

  /// Submits postions for validation
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
    func isSamePosition(position: (Int, Int)) -> Bool {
      return position == coordinate
    }
    if isSelected {
      return .blue.opacity(0.4)
    } else if foundCells.contains(where: isSamePosition) {
      return .green.opacity(0.3)
    } else {
      return .clear
    }
  }

  /// Returns the scale transform for a cell
  func cellScale(for coordinate: (Int, Int), isSelected: Bool) -> CGFloat {
    isSelected ? 1.1 : 1.0
  }

}
