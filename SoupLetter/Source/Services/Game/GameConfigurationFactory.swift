import Foundation

protocol GameConfigurationFactoryProtocol {
  func createRandomConfiguration() -> GameConfiguration
  func createRandomConfiguration(setting: GameConfigurationSetting) -> GameConfiguration
  func createConfiguration(setting: GameConfigurationSetting, category: String, subCategory: String)
    -> GameConfiguration
}

struct GameConfigurationFactory: GameConfigurationFactoryProtocol {
  let emptyConfiguration = GameConfiguration(
    gridSize: 0,
    words: [],
    validDirections: Directions.easy,
    category: "",
    subCategory: ""
  )

  private let wordStore: WordListStore
  private let defaultSetting = GameConfigurationSetting(
    gridSize: 10,
    wordsCount: 12,
    validDirections: Directions.veryHard
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
    let setting = setting ?? defaultSetting
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
    let filteredWords: [String] = wordsThatFitGrid.shuffled().prefix(setting.wordsCount).map { $0 }
    return GameConfiguration(
      gridSize: setting.gridSize,
      words: filteredWords,
      validDirections: setting.validDirections,
      category: category,
      subCategory: subCategory
    )
  }
}

#if DEBUG

  struct GameConfigurationFactoryPreview: GameConfigurationFactoryProtocol {
    let gridSize: Int
    let words: [String]
    let validDirections: Set<Direction>
    let category: String
    let subCategory: String

    init(
      gridSize: Int = 5,
      words: [String] = ["Hello", "World"],
      validDirections: Set<Direction> = Directions.medium,
      category: String = "Test",
      subCategory: String = "Test"
    ) {
      self.gridSize = gridSize
      self.words = words
      self.validDirections = validDirections
      self.category = category
      self.subCategory = subCategory
    }

    func createRandomConfiguration() -> GameConfiguration {
      return createRandomConfiguration(
        setting: GameConfigurationSetting(
          gridSize: gridSize,
          wordsCount: words.count,
          validDirections: validDirections
        )
      )
    }

    func createRandomConfiguration(setting: GameConfigurationSetting) -> GameConfiguration {
      return GameConfiguration(
        gridSize: setting.gridSize,
        words: words,
        validDirections: setting.validDirections,
        category: category,
        subCategory: subCategory
      )
    }

    func createConfiguration(
      setting: GameConfigurationSetting, category: String, subCategory: String
    )
      -> GameConfiguration
    {
      return GameConfiguration(
        gridSize: setting.gridSize,
        words: words,
        validDirections: setting.validDirections,
        category: category,
        subCategory: subCategory
      )
    }
  }

#endif
