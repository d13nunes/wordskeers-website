import Foundation

/// Service responsible for validating words and managing the word list
@Observable class WordValidator {
  /// The list of valid words for the current game
  private let wordList: Set<String>

  /// The minimum word length required
  private let minWordLength: Int

  /// Words that have been found so far
  private(set) var foundWords: Set<String> = []

  init(words: [String], minWordLength: Int) {
    self.wordList = Set(words.map { $0.uppercased() })
    self.minWordLength = minWordLength
  }

  /// Validates a word and updates the found words list if valid
  /// Returns a tuple containing whether the word is valid and its score (0 if invalid)
  func validateWord(_ word: String) -> (isValid: Bool, score: Int) {
    let upperWord = word.uppercased()

    guard upperWord.count >= minWordLength,
      !foundWords.contains(upperWord),
      wordList.contains(upperWord)
    else {
      return (false, 0)
    }

    foundWords.insert(upperWord)
    return (true, calculateScore(for: upperWord))
  }

  /// Calculates the score for a valid word
  private func calculateScore(for word: String) -> Int {
    // Base scoring:
    // 3 letters = 100 points
    // 4 letters = 400 points
    // 5 letters = 800 points
    // 6+ letters = 1500 points + 300 per additional letter
    switch word.count {
    case 3: return 100
    case 4: return 400
    case 5: return 800
    default:
      let baseScore = 1500
      let additionalLetters = word.count - 6
      return baseScore + (additionalLetters * 300)
    }
  }

  /// Returns whether a word has already been found
  func isWordFound(_ word: String) -> Bool {
    foundWords.contains(word.uppercased())
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

  /// Returns a hint for an unfound word
  func getHint() -> String? {
    let unfoundWords = wordList.subtracting(foundWords)
    return unfoundWords.randomElement()
  }

  /// Resets the found words list
  func reset() {
    foundWords.removeAll()
  }
}
