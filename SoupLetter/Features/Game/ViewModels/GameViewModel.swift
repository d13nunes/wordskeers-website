import Foundation
import SwiftUI

/// ViewModel responsible for coordinating game logic and UI updates
@Observable class GameViewModel {
  // MARK: - Properties

  /// The game state manager
  private let gameManager: GameStateManager

  /// The word list service
  private let wordListService: WordListService

  /// The current game state
  var gameState: GameState {
    gameManager.state
  }

  /// The current score
  var score: Int {
    gameManager.score
  }

  /// The current level
  var level: Int {
    gameManager.currentLevel
  }

  /// The game grid
  var grid: [[Character]] {
    gameManager.grid
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

  /// Current completion percentage
  var completionPercentage: Double {
    gameManager.completionPercentage
  }

  /// List of found words
  var foundWords: [String] {
    gameManager.foundWords
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

  init(wordList: WordList, storage: any StorageProtocol) {
    self.gameManager = GameStateManager(wordList: wordList, storage: storage)
    self.wordListService = WordListService(storage: storage)
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
    gameManager.startNextLevel()
  }

  // MARK: - Word Handling Methods

  /// Submits a word for validation
  func submitWord(_ word: String) async {
    await gameManager.submitWord(word)
  }

  /// Checks if a word has been found
  func isWordFound(_ word: String) -> Bool {
    gameManager.isWordFound(word)
  }

  /// Gets a hint for an unfound word
  func getHint() -> String? {
    gameManager.getHint()
  }

  /// Finds the coordinates of a word in the grid
  func findWordCoordinates(_ word: String) -> [(Int, Int)]? {
    gameManager.findWordCoordinates(word)
  }

  // MARK: - UI Helper Methods

  /// Returns the color for a cell based on its state
  func cellColor(for coordinate: (Int, Int), isSelected: Bool) -> Color {
    if isSelected {
      return .blue
    } else if let foundWord = foundWords.first(where: { word in
      guard let coords = findWordCoordinates(word) else { return false }
      return coords.contains(where: { $0 == coordinate })
    }) {
      return .green.opacity(0.3)
    } else {
      return .clear
    }
  }

  /// Returns the scale transform for a cell
  func cellScale(for coordinate: (Int, Int), isSelected: Bool) -> CGFloat {
    isSelected ? 1.1 : 1.0
  }

  /// Returns the rotation angle for a cell
  func cellRotation(for coordinate: (Int, Int)) -> Angle {
    if let foundWord = foundWords.first(where: { word in
      guard let coords = findWordCoordinates(word) else { return false }
      return coords.contains(where: { $0 == coordinate })
    }) {
      // Calculate rotation based on word direction
      guard let coords = findWordCoordinates(foundWord),
        let startIdx = coords.firstIndex(where: { $0 == coordinate })
      else {
        return .zero
      }

      if startIdx < coords.count - 1 {
        let nextCoord = coords[startIdx + 1]
        let dx = CGFloat(nextCoord.0 - coordinate.0)
        let dy = CGFloat(nextCoord.1 - coordinate.1)
        return Angle(radians: atan2(dy, dx))
      }
    }

    return .zero
  }

  /// Returns accessibility label for a cell
  func accessibilityLabel(for coordinate: (Int, Int)) -> String {
    let letter = String(grid[coordinate.0][coordinate.1])
    let position = "Row \(coordinate.0 + 1), Column \(coordinate.1 + 1)"

    if let foundWord = foundWords.first(where: { word in
      guard let coords = findWordCoordinates(word) else { return false }
      return coords.contains(where: { $0 == coordinate })
    }) {
      return "\(letter) at \(position), part of found word \(foundWord)"
    } else {
      return "\(letter) at \(position)"
    }
  }

  /// Returns accessibility hint for a cell
  func accessibilityHint(for coordinate: (Int, Int)) -> String {
    "Double tap and drag to select letters and form words"
  }
}
