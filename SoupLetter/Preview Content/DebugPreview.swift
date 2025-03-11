#if DEBUG

  let wordsByLength =
    [
      // 3-4 letters
      [
        "cat", "dog", "rat", "pig", "owl", "bat", "fox", "ant", "bee", "cow", "elk", "emu", "fly",
        "hog", "jay",
      ],
      // 5-6 letters
      [
        "horse", "sheep", "mouse", "koala", "panda", "zebra", "tiger", "camel", "lemur", "bison",
        "eagle", "gecko", "llama", "otter", "whale",
      ],
      // 7-8 letters
      [
        "dolphin", "penguin", "gorilla", "giraffe", "octopus", "hamster", "leopard", "ostrich",
        "raccoon", "squirrel", "tortoise", "wombat", "gazelle", "macaque", "meerkat",
      ],
      // 9-10 letters
      [
        "butterfly", "crocodile", "hedgehog", "kangaroo", "porcupine", "seahorse", "chipmunk",
        "flamingo", "jellyfish", "mongoose", "scorpion", "tarantula", "wallaby", "antelope",
        "armadillo",
      ],
      // 11-12 letters
      [
        "hippopotamus", "rhinoceros", "chimpanzee", "orangutan", "woodpecker", "hummingbird",
        "pomeranian", "salamander", "sugarglider", "waterbuffalo", "cheetah", "komododragon",
        "mountaingoat", "polarbear", "sealion",
      ],
      // 13-15 letters
      [
        "humpbackwhale", "mountainlion", "bottlenosedolphin", "elephantseal", "emperorpenguin",
        "greatdane", "kingcobra", "komododragon", "mountaingorilla", "orangebellied", "platypus",
        "redpanda", "snowleopard", "tasmaniandevil", "tigersalamander",
      ],
    ]
  @MainActor
  func getViewModel(gridSize: Int, wordCount: Int) -> GameViewModel {

    print("!!! wordsByLength")
    let wordsByLenghtSize = wordsByLength[0].count
    wordsByLength.forEach {
      assert($0.count == wordsByLenghtSize, "Debug Preview: All words must be of the same length")
    }
    print("!!! wordsByLenghtSize: \(wordsByLenghtSize)")
    var normalisedWords = [String]()
    var index = 0
    while normalisedWords.count < wordCount {
      for word in wordsByLength {
        print("!!! word: \(index) \(word[index])")
        normalisedWords.append(word[index])
      }
      index += 1
    }
    let normalizedWordCount = min(normalisedWords.count, wordCount)
    let words = Array(normalisedWords.prefix(normalizedWordCount))
    print("!!! words: \(words)")
    let gameConfigurationFactory = GameConfigurationFactoryPreview(
      gridSize: gridSize,
      words: words,
      category: "animals",
      subCategory: "mammals"
    )
    let gameManager = getGameManager(
      gridSize: gridSize,
      wordCount: wordCount,
      gameConfigurationFactory: gameConfigurationFactory
    )
    return GameViewModel(
      gameManager: gameManager,
      gameConfigurationFactory: gameConfigurationFactory,
      adManager: MockAdManager(),
      analytics: ConsoleAnalyticsManager(),
      gameHistoryService: MockGameHistoryService(),
      wallet: Wallet.forTesting()
    )
  }

  func getGameConfigFactory() -> GameConfigurationFactoring {
    GameConfigurationFactoryPreview()
  }

  func getGameManager(
    gridSize: Int, wordCount: Int, gameConfigurationFactory: GameConfigurationFactoring
  ) -> GameManager {
    return GameManager(
      gridGenerator: gameConfigurationFactory.createConfiguration(
        configuration: GameConfigurationSetting(
          gridSize: gridSize,
          wordsCount: wordCount,
          validDirections: Direction.medium,
          gameMode: .undefined
        )
      )
    )
  }

  class MockGameHistoryService: GameHistoryServicing {
    func save(record: GameHistoryRecord) async -> GameHistory? {
      return nil
    }
  }

  class MockGridGenerator: GridGenerating {
    var configuration: GameConfiguration

    init(configuration: GameConfiguration) {
      self.configuration = configuration
    }

    func generate() -> ([[String]], [WordData]) {
      return (
        [["a", "b", "c"], ["d", "e", "f"], ["g", "h", "i"]],
        [
          WordData(
            word: "abc", isFound: false, position: Position(row: 0, col: 0), direction: .horizontal
          ),
          WordData(
            word: "def", isFound: false, position: Position(row: 0, col: 1), direction: .horizontal
          ),
          WordData(
            word: "ghi", isFound: false, position: Position(row: 0, col: 2), direction: .horizontal
          ),
        ]
      )
    }
  }

#endif
