import Foundation

/// Service responsible for validating words and managing the word list
@Observable
class WordValidator {
  /// The list of valid words for the current game
  private(set) var words: [WordData]

  /// Words that have been found so far
  var foundWords: [String] {
    words.filter { $0.isFound }.map { $0.word }
  }

  init(words: [WordData]) {
    self.words = words
  }

  /// Validates a word and updates the found words list if valid
  func validateWord(_ word: String) -> Bool {
    let upperWord = word.uppercased()
    // Check if the word is in the list and if not found
    guard let wordIndex = words.firstIndex(where: { $0.word.uppercased() == upperWord })
    else {
      return false
    }
    guard !words[wordIndex].isFound else {
      return false
    }
    words[wordIndex] = words[wordIndex].copy(isFound: true)
    return true
  }

  /// Returns the total number of words in the word list
  var totalWords: Int {
    words.count
  }

  /// Returns the number of words found so far
  var foundWordCount: Int {
    words.filter { $0.isFound }.count
  }

  /// Returns the completion percentage (0-100)
  var completionPercentage: Double {
    guard totalWords > 0 else { return 0 }
    return Double(foundWordCount) / Double(totalWords) * 100
  }

  /// Returns all found words sorted alphabetically
  var foundWordsList: [String] {
    words.filter { $0.isFound }.map { $0.word }.sorted()
  }

  /// Returns whether all words have been found
  var isComplete: Bool {
    foundWords.count == words.count
  }

  /// Resets the found words list
  func reset() {
    words = words.map { $0.copy(isFound: false) }
  }
}
