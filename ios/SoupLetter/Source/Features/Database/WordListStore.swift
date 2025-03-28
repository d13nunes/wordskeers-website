import Foundation

/// Manages categorized word lists with different difficulty levels
struct WordListStore {
  // MARK: - Types

  typealias WordList = [String]
  typealias SubCategoryMap = [String: WordList]
  typealias CategoryMap = [String: SubCategoryMap]

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
  func getWords(category: String, subCategory: String) -> WordList {
    guard let categoryWords = categories[category] else {
      return []
    }

    guard let subCategoryWords = categoryWords[subCategory] else {
      return []
    }

    return subCategoryWords
  }

  // MARK: - Private Methods

  /// Loads and parses the word list JSON file from the app bundle
  private static func loadJSON() -> CategoryMap {
    guard let url = Bundle.main.url(forResource: "word_lists", withExtension: "json"),
      let data = try? Data(contentsOf: url),
      let rawData = try? JSONDecoder().decode(
        [String: [String: [String: [String]]]].self, from: data)
    else {
      print("Error: Could not load or decode word_lists.json")
      return [:]
    }

    print("rawData: \(rawData)")
    return rawData["categories"]?.mapValues { subCategoryDict in
      subCategoryDict.mapValues { wordList in
        wordList.map { $0 }
      }
    } ?? [:]
  }

  func getRandomCategory() -> String? {
    categories.keys.randomElement()
  }

  func getRandomSubCategory(for category: String) -> String? {
    categories[category]?.keys.randomElement()
  }

}

// MARK: - Preview Helper

#if DEBUG
  extension WordListStore {
    static var preview: WordListStore {
      WordListStore()
    }

    /// Preview helper to check if words exist for a category and subCategory
    func hasWords(category: String, subCategory: String) -> Bool {
      !getWords(category: category, subCategory: subCategory).isEmpty
    }
  }
#endif
