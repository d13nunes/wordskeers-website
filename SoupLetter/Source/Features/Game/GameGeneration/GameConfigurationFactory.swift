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
