import Foundation

enum GridGeneratorError: String, Error {
  case wordTooLong = "Word is too long for the grid"
}

/// Service responsible for generating the letter grid and placing words
class GridGenerator: GridGenerating {
  private let vowels = "AEIOU"
  private let consonants = "BCDFGHJKLMNPQRSTVWXYZ"

  private let words: [String]
  private let size: Int
  private let validDirections: [Direction]

  var configuration: GameConfiguration

  convenience init(configuration: GameConfiguration) {
    self.init(
      words: configuration.words,
      size: configuration.gridSize,
      validDirections: configuration.validDirections
    )
  }

  init(words: [String], size: Int, validDirections: Set<Direction>) {
    self.words = words
    self.size = size
    self.validDirections = Array(validDirections)
    self.configuration = GameConfiguration(
      gridSize: size,
      words: words,
      validDirections: validDirections,
      category: "Placeholder"
    )
  }

  func generate() -> ([[String]], [WordData]) {
    let (grid, wordData) = generateWordSearch(gridSize: size, words: words)
    return (grid, wordData)
  }

  func canPlaceWord(_ word: String, row: Int, col: Int, direction: Direction, grid: [[String]])
    -> Bool
  {
    for (index, char) in word.enumerated() {
      let row = row + index * direction.dx
      let col = col + index * direction.dy
      if row < 0
        || row >= size
        || col < 0
        || col >= size
        || (grid[row][col] != " " && grid[row][col] != String(char))
      {
        return false
      }
    }
    return true
  }

  func placeWord(_ word: String, grid: inout [[String]]) -> (Position, Direction)? {
    let shuffledDirections = validDirections.shuffled()
    for _ in 0..<100 {  // Try multiple times to find a position
      let row = Int.random(in: 0..<size)
      let col = Int.random(in: 0..<size)

      for direction in shuffledDirections
      where canPlaceWord(word, row: row, col: col, direction: direction, grid: grid) {
        for (index, char) in word.enumerated() {
          grid[row + index * direction.dx][col + index * direction.dy] = String(char)
        }
        return (Position(row: row, col: col), direction)
      }
    }
    return nil
  }

  func generateWordSearch(gridSize: Int, words: [String]) -> ([[String]], [WordData]) {
    let emptyLetter = " "
    var grid = Array(repeating: Array(repeating: emptyLetter, count: gridSize), count: gridSize)
    var wordData: [WordData] = []
    for word in words {
      if let (position, direction) = placeWord(word.uppercased(), grid: &grid) {
        wordData.append(
          WordData(
            word: word,
            isFound: false,
            position: position,
            direction: direction
          ))
      }
    }

    for row in 0..<gridSize {
      for col in 0..<gridSize where grid[row][col] == emptyLetter {
        
        grid[row][col] = String(UnicodeScalar(Int.random(in: 65...90))!)  // Random uppercase letter
      }
    }
    return (grid, wordData)
  }
}

