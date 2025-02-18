struct Directions {
  static let all: Set<Direction> = [
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
