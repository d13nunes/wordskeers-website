import Foundation

protocol GameConfigurationFactoryProtocol {
  func createRandomConfiguration() -> GameConfiguration
  func createRandomConfiguration(setting: GameConfigurationSetting) -> GameConfiguration
  func createConfiguration(setting: GameConfigurationSetting, category: String, subCategory: String)
    -> GameConfiguration
}

struct GameConfigurationFactory: GameConfigurationFactoryProtocol {
  let emptyConfiguration = GameConfiguration(
    gridId: -1,
    gridSize: 0,
    words: [],
    validDirections: Direction.easy,
    category: "",
    gameMode: .undefined
  )

  private let wordStore: WordListStore
  private let defaultSetting = GameConfigurationSetting(
    gridSize: 10,
    wordsCount: 12,
    validDirections: Direction.all,
    gameMode: .undefined
  )

  init(wordStore: WordListStore = WordListStore()) {
    self.wordStore = wordStore
  }

  func createRandomConfiguration() -> GameConfiguration {
    createRandomConfiguration(setting: defaultSetting)
  }

  func createRandomConfiguration(setting: GameConfigurationSetting) -> GameConfiguration {
    guard let category = wordStore.getRandomCategory() else {
      assert(false, "No category found")
      return emptyConfiguration
    }
    guard let subCategory = wordStore.getRandomSubCategory(for: category) else {
      assert(false, "No subCategory found")
      return emptyConfiguration
    }

    return createConfiguration(
      setting: setting,
      category: category,
      subCategory: subCategory
    )
  }

  func createConfiguration(setting: GameConfigurationSetting, category: String, subCategory: String)
    -> GameConfiguration
  {
    let words = wordStore.getWords(category: category, subCategory: subCategory)
    guard !words.isEmpty else {
      assert(false, "No words found for category: \(category) and subCategory: \(subCategory)")
      return emptyConfiguration
    }

    let wordsThatFitGrid = words.filter { $0.count <= setting.gridSize }
    let filteredWords: [String] = wordsThatFitGrid.shuffled().prefix(setting.wordsCount ?? 0).map {
      $0
    }
    return GameConfiguration(
      gridId: -1,
      gridSize: setting.gridSize,
      words: filteredWords,
      validDirections: setting.validDirections,
      category: category,
      gameMode: .undefined
    )
  }
}

#if DEBUG

  struct GameConfigurationFactoryPreview: GameConfigurationFactoring {

    let gridSize: Int
    let words: [String]
    let validDirections: Set<Direction>
    let category: String
    let subCategory: String

    init(
      gridSize: Int = 5,
      words: [String] = ["Hello", "World"],
      validDirections: Set<Direction> = Direction.medium,
      category: String = "Test",
      subCategory: String = "Test"
    ) {
      self.gridSize = gridSize
      self.words = words
      self.validDirections = validDirections
      self.category = category
      self.subCategory = subCategory
    }

    func createConfiguration(configuration: GameConfigurationSetting) -> GridGenerating {
      let configuration = getConfiguration(gridSize: gridSize, wordCount: words.count)
      return GridGenerator(configuration: configuration)

    }

    func getConfiguration(gridSize: Int, wordCount: Int) -> GameConfiguration {
      let words = Array(
        [
          "hello", "world", "foo", "bar", "baz", "qux", "quux", "corge", "grault", "garply",
          "waldo",
          "fred", "plugh", "xyzzy", "thud",
          "hello1", "world2", "foo1", "bar2", "baz3", "qux4", "quux5", "corge6", "grault7",
          "garply8",
          "hello12", "world22", "foo11", "bar22", "baz33", "qux44", "quux55", "corge66", "grault77",
          "garply88",
          "hello123", "world223", "foo113", "bar223", "baz333", "qux443", "quux553", "corge663",
          "grault773", "garply883",
          "hello1234", "world2234", "foo1134", "bar2234", "baz3334", "qux4434", "quux5534",
          "corge6634", "grault7734", "garply8834",
          "hello12345", "world22345", "foo11345", "bar22345", "baz33345", "qux44345", "quux55345",
          "corge66345", "grault77345", "garply88345",
          "hello123456", "world223456", "foo113456", "bar223456", "baz333456", "qux443456",
          "quux553456", "corge663456", "grault773456", "garply883456",
          "hello1234567", "world2234567", "foo1134567", "bar2234567", "baz3334567",
          "qux4434567", "quux5534567", "corge6634567", "grault7734567", "garply8834567",
        ].prefix(wordCount))

      return GameConfiguration(
        gridId: -1,
        gridSize: gridSize,
        words: words,
        validDirections: Direction.medium,
        category: "animals",
        gameMode: .undefined
      )
    }

  }
#endif
