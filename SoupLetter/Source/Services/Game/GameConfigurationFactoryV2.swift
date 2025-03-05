import Foundation

struct GameConfigurationFactoryV2: GameConfigurationFactoring {
  private let dictionary: [Difficulty: GridModel]
  init() {
    let categoriesModel = CategoriesModelParser.fromBundle() ?? []

    dictionary = categoriesModel.map { (Self.getDifficulty(from: $0.mode), $0) }.reduce(
      into: [Difficulty: GridModel]()
    ) {
      $0[$1.0] = $1.1
    }
  }

  private func getGridRandom(difficulty: Difficulty) -> GridDataDTO {
    return dictionary[difficulty]!.grids.randomElement()!
  }

  func createConfiguration(difficulty: Difficulty) -> GridGenerating {
    let gridModel = getGridRandom(difficulty: difficulty)
    let gridSize = gridModel.size
    let words = gridModel.placedWords.map { $0.word }
    let validDirections = Directions.all
    let category = gridModel.category
    let gameConfiguration = GameConfiguration(
      gridSize: gridSize, words: words, validDirections: validDirections, category: category
    )
    let placedWords = gridModel.placedWords
    return GridGeneratorV2(
      gameConfiguration: gameConfiguration, placedWords: placedWords)
  }
  static func getDifficulty(from mode: String) -> Difficulty {
    switch mode {
    case "veryEasy": return .veryEasy
    case "easy": return .easy
    case "medium": return .medium
    case "hard": return .hard
    case "veryHard": return .veryHard
    default: return .easy
    }
  }

}

struct GridGeneratorV2: GridGenerating {
  private(set) var configuration: GameConfiguration

  let placedWords: [WordPlacementDTO]

  init(gameConfiguration: GameConfiguration, placedWords: [WordPlacementDTO]) {
    self.configuration = gameConfiguration
    self.placedWords = placedWords
  }

  func generate() -> ([[String]], [WordData]) {
    let size = configuration.gridSize
    let emptyLetter = ""
    var grid: [[String]] = Array(
      repeating: Array(repeating: emptyLetter, count: size), count: size)
    for word in placedWords {
      print("!grid \(word)")
      for (index, letter) in word.word.uppercased().enumerated() {
        let direction = word.direction.toDirection()
        let x = word.col + index * direction.dx
        let y = word.row + index * direction.dy
        grid[y][x] = String(letter)
      }
    }
    for row in 0..<size {
      for col in 0..<size where grid[row][col] == emptyLetter {
        grid[row][col] = String(UnicodeScalar(Int.random(in: 65...90))!)  // Random uppercase letter
      }
    }
    return (
      grid,
      placedWords.map {
        WordData(
          word: $0.word,
          isFound: false,
          position: Position(row: $0.row, col: $0.col),
          direction: $0.direction.toDirection()
        )
      }
    )
  }

}
