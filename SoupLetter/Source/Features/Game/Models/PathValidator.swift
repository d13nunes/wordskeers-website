struct PathValidator {
  private let allowedDirections: Set<Direction>
  private let gridSize: Int

  init(allowedDirections: Set<Direction>, gridSize: Int) {
    self.allowedDirections = allowedDirections
    self.gridSize = gridSize
  }

  func isValidPath(from start: Position, to end: Position) -> Bool {
    let dx = end.col - start.col
    let dy = end.row - start.row

    // Normalize to unit vector
    let magnitude = max(abs(dx), abs(dy))
    guard magnitude > 0 else { return false }

    let direction = Direction(
      dx: dx / magnitude,
      dy: dy / magnitude
    )

    return allowedDirections.contains(direction)
  }

  func getPositionsInPath(from start: Position, to end: Position) -> [Position] {
    guard isValidPath(from: start, to: end) else {
      return []
    }

    var positions: [Position] = []
    let dx = end.col - start.col
    let dy = end.row - start.row
    let steps = max(abs(dx), abs(dy))

    guard steps > 0 else { return [start] }

    let stepX = dx / steps
    let stepY = dy / steps

    for index in 0...steps {
      positions.append(
        Position(
          row: start.row + (stepY * index),
          col: start.col + (stepX * index)
        ))
    }

    return positions
  }
}
