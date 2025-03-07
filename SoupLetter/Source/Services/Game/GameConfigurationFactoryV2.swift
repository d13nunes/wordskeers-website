import Foundation

struct GameConfigurationFactoryV2: GameConfigurationFactoring {

  private let gridFetcher: GridFetching

  init(gridFetcher: GridFetching) {
    self.gridFetcher = gridFetcher
  }

  func createConfiguration(configuration: GameConfigurationSetting) -> any GridGenerating {
    let gridModel = gridFetcher.getGridRandom(config: configuration)
    let gridSize = gridModel.size
    let words = gridModel.placedWords.map { $0.word }
    let validDirections = Direction.all
    let category = gridModel.category
    let gameConfiguration = GameConfiguration(
      gridId: gridModel.id,
      gridSize: gridSize,
      words: words,
      validDirections: validDirections,
      category: category,
      gameMode: configuration.gameMode
    )
    let placedWords = gridModel.placedWords
    return GridGeneratorV2(
      gameConfiguration: gameConfiguration, placedWords: placedWords)
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
        let direction = word.direction
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
          direction: $0.direction
        )
      }
    )
  }

}
