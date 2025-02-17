import Foundation

struct Direction: Hashable {
  let dx: Int
  let dy: Int
}

struct Directions {

  static let all: [Direction] = [
    right,
    down,
    diagonalRightDown,
    diagonalLeftDown,
    left,
    up,
    diagonalLeftUp,
    diagonalRightUp,
  ]

  static let right = Direction(dx: 0, dy: 1)
  static let down = Direction(dx: 1, dy: 0)
  static let diagonalRightDown = Direction(dx: 1, dy: 1)
  static let diagonalLeftDown = Direction(dx: -1, dy: 1)
  static let left = Direction(dx: 0, dy: -1)
  static let up = Direction(dx: -1, dy: 0)
  static let diagonalLeftUp = Direction(dx: -1, dy: -1)
  static let diagonalRightUp = Direction(dx: 1, dy: -1)
}

extension [[String]] {
  func printGrid() {
    let output = self.map { $0.joined() }.joined(separator: "\n")
    print(output)
  }

  /// Returns the coordinates of all cells that form a word in the grid
  func findWordCoordinates(_ word: String, directions: [Direction] = Directions.all) -> [(
    Int, Int
  )]? {
    let size = self.count
    let wordChars = word.uppercased().map { String($0) }

    for row in 0..<size {
      for col in 0..<size {
        for direction in directions {
          var coordinates = [(Int, Int)]()
          var isValid = true

          for index in 0..<wordChars.count {
            let newRow = row + (direction.dx * index)
            let newCol = col + (direction.dy * index)

            guard newRow >= 0 && newRow < size && newCol >= 0 && newCol < size else {
              isValid = false
              break
            }

            if self[newRow][newCol] != wordChars[index] {
              isValid = false
              break
            }

            coordinates.append((newRow, newCol))
          }

          if isValid {
            return coordinates
          }
        }
      }
    }

    return nil
  }

  func getWord(in positions: [(Int, Int)]) -> String {
    positions.map { self[$0.0][$0.1] }.joined()
  }
}
