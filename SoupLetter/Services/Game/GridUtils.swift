import Foundation

struct GridUtils {
  static let directions: [(dx: Int, dy: Int)] = [
    (0, 1),  // right
    (1, 0),  // down
    (1, 1),  // diagonal right down
    (-1, 1),  // diagonal left down
    (0, -1),  // left
    (-1, 0),  // up
    (-1, -1),  // diagonal left up
    (1, -1),  // diagonal right up
  ]
}

extension [[String]] {

  func printGrid() {
    let output = self.map { $0.joined() }.joined(separator: "\n")
    print(output)
  }

  /// Returns the coordinates of all cells that form a word in the grid
  func findWordCoordinates(_ word: String) -> [(Int, Int)]? {
    let size = self.count
    let wordChars = word.uppercased().map { String($0) }

    for row in 0..<size {
      for col in 0..<size {
        for direction in GridUtils.directions {
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
