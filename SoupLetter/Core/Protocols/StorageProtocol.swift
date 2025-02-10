import Foundation

/// Protocol defining the contract for storing and retrieving word lists and game progress
protocol StorageProtocol {
  /// Fetches all available word lists
  func fetchWordLists() async throws -> [WordList]

  /// Saves a word list
  func saveWordList(_ wordList: WordList) async throws

  /// Fetches the current game progress
  func fetchGameProgress() async throws -> GameProgress

  /// Saves the current game progress
  func saveGameProgress(_ progress: GameProgress) async throws

  /// Deletes all stored data
  func clearAllData() async throws
}

/// Represents a collection of words for the game
@Observable class WordList: Identifiable {
  let id: UUID
  var name: String
  var words: [String]
  var difficulty: GameDifficulty
  var language: String

  init(
    id: UUID = UUID(), name: String, words: [String], difficulty: GameDifficulty,
    language: String = "en"
  ) {
    self.id = id
    self.name = name
    self.words = words
    self.difficulty = difficulty
    self.language = language
  }
}

/// Represents the current state and progress of a game
@Observable class GameProgress: Identifiable {
  let id: UUID
  var score: Int
  var foundWords: Set<String>
  var currentLevel: Int
  var lastPlayedDate: Date
  var wordListId: UUID

  init(
    id: UUID = UUID(), score: Int = 0, foundWords: Set<String> = [], currentLevel: Int = 1,
    lastPlayedDate: Date = Date(), wordListId: UUID
  ) {
    self.id = id
    self.score = score
    self.foundWords = foundWords
    self.currentLevel = currentLevel
    self.lastPlayedDate = lastPlayedDate
    self.wordListId = wordListId
  }
}

/// Represents the difficulty level of a word list
enum GameDifficulty: String, Codable, CaseIterable {
  case easy
  case medium
  case hard

  var minWordLength: Int {
    switch self {
    case .easy: return 3
    case .medium: return 4
    case .hard: return 5
    }
  }

  var gridSize: Int {
    switch self {
    case .easy: return 4
    case .medium: return 5
    case .hard: return 6
    }
  }
}
