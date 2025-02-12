import Foundation

/// Manages categorized word lists with different difficulty levels
struct WordListStore {
  // MARK: - Types

  typealias WordList = [String]
  typealias DifficultyMap = [Difficulty: WordList]
  typealias CategoryMap = [String: DifficultyMap]

  // MARK: - Properties

  /// Dictionary mapping categories to difficulty-based word lists
  private let categories: CategoryMap

  // MARK: - Initialization

  init() {
    self.categories = Self.loadJSON()
  }

  // MARK: - Public Methods

  /// Gets all words for a specific category and difficulty
  /// - Parameters:
  ///   - category: The word category (e.g., "animals")
  ///   - difficulty: The difficulty level
  /// - Returns: Array of words matching the criteria, or empty array if none found
  func getWords(category: String, difficulty: Difficulty) -> WordList {
    guard let categoryWords = categories[category],
      categoryWords[difficulty] != nil
    else {
      return []
    }
    switch difficulty {
    case .easy:
      return categoryWords[.easy]!
    case .medium:
      var words: [String] = []
      if let easyWords = categoryWords[.easy] {
        words.append(contentsOf: easyWords)
      }
      if let mediumWords = categoryWords[.medium] {
        words.append(contentsOf: mediumWords)
      }
      return words
    case .hard:
      var words: [String] = []
      if let easyWords = categoryWords[.easy] {
        words.append(contentsOf: easyWords)
      }
      if let mediumWords = categoryWords[.medium] {
        words.append(contentsOf: mediumWords)
      }
      return words
    }
  }

  /// Gets a random word for a specific category and difficulty
  /// - Parameters:
  ///   - category: The word category (e.g., "animals")
  ///   - difficulty: The difficulty level
  /// - Returns: A random word matching the criteria, or nil if none found
  func getRandomWord(category: String, difficulty: Difficulty) -> String? {
    let words = getWords(category: category, difficulty: difficulty)
    return words.randomElement()
  }

  // MARK: - Private Methods

  /// Loads and parses the word list JSON file from the app bundle
  private static func loadJSON() -> CategoryMap {
    guard let url = Bundle.main.url(forResource: "word_lists", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let rawData = try? JSONDecoder().decode([String: [Int: [String]]].self, from: data)
    else {
      print("Error: Could not load or decode word_lists.json")
      return [:]
    }

    return rawData.mapValues { difficultyDict in
      Dictionary(
        uniqueKeysWithValues: difficultyDict.compactMap { key, words in
          Difficulty(rawValue: key).map { ($0, words) }
        })
    }
  }
}

// MARK: - Preview Helper

#if DEBUG
  extension WordListStore {
    static var preview: WordListStore {
      WordListStore()
    }

    /// Preview helper to check if words exist for a category and difficulty
    func hasWords(category: String, difficulty: Difficulty) -> Bool {
      !getWords(category: category, difficulty: difficulty).isEmpty
    }
  }
#endif
