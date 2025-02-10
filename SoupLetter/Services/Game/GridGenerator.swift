import Foundation

/// Service responsible for generating the letter grid and placing words
@Observable class GridGenerator {
  private let vowels = "AEIOU"
  private let consonants = "BCDFGHJKLMNPQRSTVWXYZ"
  private let directions: [(dx: Int, dy: Int)] = [
    (0, 1),  // right
    (1, 0),  // down
    (1, 1),  // diagonal right down
    (-1, 1),  // diagonal left down
    (0, -1),  // left
    (-1, 0),  // up
    (-1, -1),  // diagonal left up
    (1, -1),  // diagonal right up
  ]

  /// Generates a grid with the given words placed and filled with random letters
  func generateGrid(size: Int, words: [String]) -> [[Character]] {
    var grid = Array(repeating: Array(repeating: Character(" "), count: size), count: size)
    var placedWords = Set<String>()

    // Sort words by length (longest first) to ensure better placement
    let sortedWords = words.sorted { $0.count > $1.count }

    // Try to place each word
    for word in sortedWords {
      if tryPlaceWord(word.uppercased(), in: &grid) {
        placedWords.insert(word)
      }
    }

    // Fill remaining spaces with random letters
    fillEmptySpaces(&grid)

    return grid
  }

  /// Attempts to place a word in the grid
  private func tryPlaceWord(_ word: String, in grid: inout [[Character]]) -> Bool {
    let size = grid.count
    let attempts = 100  // Maximum attempts to place the word

    for _ in 0..<attempts {
      // Random starting position
      let startX = Int.random(in: 0..<size)
      let startY = Int.random(in: 0..<size)

      // Random direction
      let direction = directions.randomElement()!

      // Check if word fits in this direction
      if canPlaceWord(word, at: (startX, startY), in: direction, grid: grid) {
        placeWord(word, at: (startX, startY), in: direction, grid: &grid)
        return true
      }
    }

    return false
  }

  /// Checks if a word can be placed at the given position and direction
  private func canPlaceWord(
    _ word: String, at start: (x: Int, y: Int), in direction: (dx: Int, dy: Int),
    grid: [[Character]]
  ) -> Bool {
    let size = grid.count
    let wordChars = Array(word)

    for i in 0..<word.count {
      let x = start.x + (direction.dx * i)
      let y = start.y + (direction.dy * i)

      // Check bounds
      guard x >= 0 && x < size && y >= 0 && y < size else {
        return false
      }

      // Check if space is empty or has matching letter
      let currentChar = grid[x][y]
      if currentChar != " " && currentChar != wordChars[i] {
        return false
      }
    }

    return true
  }

  /// Places a word in the grid at the specified position and direction
  private func placeWord(
    _ word: String, at start: (x: Int, y: Int), in direction: (dx: Int, dy: Int),
    grid: inout [[Character]]
  ) {
    let wordChars = Array(word)

    for i in 0..<word.count {
      let x = start.x + (direction.dx * i)
      let y = start.y + (direction.dy * i)
      grid[x][y] = wordChars[i]
    }
  }

  /// Fills empty spaces in the grid with random letters
  private func fillEmptySpaces(_ grid: inout [[Character]]) {
    let size = grid.count

    for i in 0..<size {
      for j in 0..<size {
        if grid[i][j] == " " {
          // 70% chance for consonant, 30% for vowel
          grid[i][j] =
            Bool.random()
            ? consonants.randomElement()!
            : (Double.random(in: 0...1) < 0.3
              ? vowels.randomElement()! : consonants.randomElement()!)
        }
      }
    }
  }

  /// Returns the coordinates of all cells that form a word in the grid
  func findWordCoordinates(_ word: String, in grid: [[Character]]) -> [(Int, Int)]? {
    let size = grid.count
    let wordChars = Array(word.uppercased())

    for x in 0..<size {
      for y in 0..<size {
        for direction in directions {
          var coordinates = [(Int, Int)]()
          var isValid = true

          for i in 0..<wordChars.count {
            let newX = x + (direction.dx * i)
            let newY = y + (direction.dy * i)

            guard newX >= 0 && newX < size && newY >= 0 && newY < size else {
              isValid = false
              break
            }

            if grid[newX][newY] != wordChars[i] {
              isValid = false
              break
            }

            coordinates.append((newX, newY))
          }

          if isValid {
            return coordinates
          }
        }
      }
    }

    return nil
  }
}
