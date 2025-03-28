struct WordData: Hashable {
  let word: String
  let isFound: Bool
  let position: Position
  let direction: Direction

  func copy(isFound: Bool) -> WordData {
    WordData(
      word: word, isFound: isFound, position: position, direction: direction)
  }
}

extension WordData {
  func allPositions() -> [Position] {
    var positions: [Position] = []
    let row = position.row
    let col = position.col
    for index in 0..<word.count {
      let newPosition = Position(
        row: row + index * direction.dy,
        col: col + index * direction.dx
      )
      positions.append(newPosition)
    }
    return positions
  }
}
