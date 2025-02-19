import Foundation

protocol GameConfigurationFactoryProtocol {
  func createRandomConfiguration() -> GameConfiguration
  func createConfiguration(category: String, subCategory: String) -> GameConfiguration
}

struct GameConfigurationFactory: GameConfigurationFactoryProtocol {
  let emptyConfiguration = GameConfiguration(gridSize: 0, words: [], category: "", subCategory: "")

  private let wordStore: WordListStore

  init(wordStore: WordListStore = WordListStore()) {
    self.wordStore = wordStore
  }

  func createRandomConfiguration() -> GameConfiguration {
    guard let category = wordStore.getRandomCategory() else {
      assert(false, "No category found")
      return emptyConfiguration
    }

    guard let subCategory = wordStore.getRandomSubCategory(for: category) else {
      assert(false, "No subCategory found")
      return emptyConfiguration
    }

    return createConfiguration(category: category, subCategory: subCategory)
  }

  func createConfiguration(category: String, subCategory: String) -> GameConfiguration {
    let words = wordStore.getWords(category: category, subCategory: subCategory)
    guard !words.isEmpty else {
      assert(false, "No words found for category: \(category) and subCategory: \(subCategory)")
      return emptyConfiguration
    }

    let gridSize = 18
    let wordCount = 20
    let filteredWords = words.filter { $0.count < gridSize }.prefix(wordCount).map {
      $0.lowercased()
    }
    return GameConfiguration(
      gridSize: gridSize,
      words: filteredWords,
      category: category,
      subCategory: subCategory
    )
  }
}

#if DEBUG

  struct GameConfigurationFactoryPreview: GameConfigurationFactoryProtocol {
    let gridSize: Int
    let words: [String]
    let category: String
    let subCategory: String

    init(
      gridSize: Int = 5,
      words: [String] = ["Hello", "World"],
      category: String = "Test",
      subCategory: String = "Test"
    ) {
      self.gridSize = gridSize
      self.words = words
      self.category = category
      self.subCategory = subCategory
    }

    func createRandomConfiguration() -> GameConfiguration {
      return GameConfiguration(
        gridSize: gridSize,
        words: words,
        category: category,
        subCategory: subCategory
      )
    }

    func createConfiguration(category: String, subCategory: String) -> GameConfiguration {
      return GameConfiguration(
        gridSize: gridSize,
        words: words,
        category: category,
        subCategory: subCategory
      )
    }
  }

#endif
