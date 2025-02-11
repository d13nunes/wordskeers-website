import Foundation

/// Service responsible for validating words and managing the word list
@Observable class WordValidator {
  /// The list of valid words for the current game
  private var wordList: Set<String>

  /// Words that have been found so far
  private(set) var foundWords: Set<String> = []

  init(words: [String]) {
    self.wordList = Set(words.map { $0.uppercased() })
  }

  /// Validates a word and updates the found words list if valid
  func validateWord(_ word: String) -> Bool {
    let upperWord = word.uppercased()
    if !wordList.contains(upperWord) {
      return false
    }

    if foundWords.contains(upperWord) {
      return false
    }

    foundWords.insert(upperWord)
    return true
  }

  /// Returns the total number of words in the word list
  var totalWords: Int {
    wordList.count
  }

  /// Returns the number of words found so far
  var foundWordCount: Int {
    foundWords.count
  }

  /// Returns the completion percentage (0-100)
  var completionPercentage: Double {
    guard totalWords > 0 else { return 0 }
    return Double(foundWordCount) / Double(totalWords) * 100
  }

  /// Returns all found words sorted alphabetically
  var foundWordsList: [String] {
    Array(foundWords).sorted()
  }

  /// Returns whether all words have been found
  var isComplete: Bool {
    foundWords.count == wordList.count
  }

  /// Resets the found words list
  func reset() {
    foundWords.removeAll()
  }
}
