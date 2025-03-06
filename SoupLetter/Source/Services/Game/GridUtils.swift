import Foundation

extension [[String]] {
  func printGrid() {
    let output = self.map { $0.joined() }.joined(separator: "\n")
    print(output)
  }

  /// Returns the coordinates of all cells that form a word in the grid
  func findWordCoordinates(_ word: String, directions: Set<Direction> = Direction.all) -> [(
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

  func getWord(in positions: [Position]) -> String {
    positions.map { self[$0.row][$0.col] }.joined()
  }
}
