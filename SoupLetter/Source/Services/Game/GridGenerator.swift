import Foundation

enum GridGeneratorError: String, Error {
  case wordTooLong = "Word is too long for the grid"
}

/// Service responsible for generating the letter grid and placing words
class GridGenerator: GridFactory {
  private let vowels = "AEIOU"
  private let consonants = "BCDFGHJKLMNPQRSTVWXYZ"

  private let words: [String]
  private let size: Int
  private let directions: [(Int, Int)] = [
    (1, 0),
    (0, 1),
    // (1, 1),
    // (-1, 1),
  ]  // Down, Right, Diagonal Down-Right, Diagonal Up-Right

  init(words: [String], size: Int) {
    self.words = words
    self.size = size
  }

  func getGrid() -> ([[String]], [String]) {
    let (grid, placedWords) = generateWordSearch(gridSize: size, words: words)
    return (grid, placedWords)
  }

  func canPlaceWord(_ word: String, row: Int, col: Int, direction: (Int, Int), grid: [[String]])
    -> Bool
  {
    let (directionRow, directionCol) = direction
    for (index, char) in word.enumerated() {
      let row = row + index * directionRow
      let col = col + index * directionCol
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

  func placeWord(_ word: String, grid: inout [[String]]) -> Bool {
    let shuffledDirections = directions.shuffled()

    for _ in 0..<100 {  // Try multiple times to find a position
      let row = Int.random(in: 0..<size)
      let col = Int.random(in: 0..<size)

      for direction in shuffledDirections
      where canPlaceWord(word, row: row, col: col, direction: direction, grid: grid) {
        let (directionRow, directionCol) = direction
        for (index, char) in word.enumerated() {
          grid[row + index * directionRow][col + index * directionCol] = String(char)
        }
        return true
      }
    }
    return false
  }

  func generateWordSearch(gridSize: Int, words: [String]) -> ([[String]], [String]) {
    var grid = Array(repeating: Array(repeating: " ", count: gridSize), count: gridSize)
    var placedWords: [String] = []

    for word in words where placeWord(word.uppercased(), grid: &grid) {
      placedWords.append(word)

    }

    for row in 0..<gridSize {
      for col in 0..<gridSize where grid[row][col] == " " {
        grid[row][col] = String(UnicodeScalar(Int.random(in: 65...90))!)  // Random uppercase letter
      }
    }
    return (grid, placedWords)
  }
}
