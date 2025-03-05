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

  static let right = Direction(dx: 1, dy: 0)
  static let down = Direction(dx: 0, dy: 1)
  static let diagonalRightDown = Direction(dx: 1, dy: 1)
  static let diagonalLeftDown = Direction(dx: -1, dy: 1)
  static let left = Direction(dx: -1, dy: 0)
  static let up = Direction(dx: 0, dy: -1)
  static let diagonalLeftUp = Direction(dx: -1, dy: -1)
  static let diagonalRightUp = Direction(dx: 1, dy: -1)

  static let directionGroups: [[Direction]] = [
    [right, down],
    [left, up],
    [diagonalRightUp, diagonalRightDown],
    [diagonalLeftDown, diagonalLeftUp],
  ]

  static func getSymbol(for direction: Direction) -> String {
    switch direction {
    case right: return "→"
    case down: return "↓"
    case diagonalRightDown: return "↘"
    case diagonalRightUp: return "↗"
    case left: return "←"
    case up: return "↑"
    case diagonalLeftDown: return "↙"
    case diagonalLeftUp: return "↖"
    default: return ""
    }
  }
  static let veryEasy: Set<Direction> = [right]
  static let easy: Set<Direction> = [right, down]
  static let medium: Set<Direction> = [right, down, diagonalRightDown, diagonalRightDown]
  static let hard: Set<Direction> = [right, down, diagonalRightDown, diagonalRightDown, left, up]
  static let veryHard: Set<Direction> = all

}
