enum Direction: String, Codable, CaseIterable {
  case horizontal = "horizontal"  // →
  case vertical = "vertical"  // ↓
  case diagonalDownRight = "diagonal-dr"  // ↘
  case diagonalDownLeft = "diagonal-dl"  // ↙
  case diagonalUpRight = "diagonal-ur"  // ↗
  case diagonalUpLeft = "diagonal-ul"  // ↖
  case horizontalReverse = "horizontal-r"  // ←
  case verticalReverse = "vertical-r"  // ↑

  var dx: Int {
    switch self {
    case .horizontal, .diagonalDownRight, .diagonalUpRight:
      return 1
    case .horizontalReverse, .diagonalDownLeft, .diagonalUpLeft:
      return -1
    case .vertical, .verticalReverse:
      return 0
    }
  }

  var dy: Int {
    switch self {
    case .vertical, .diagonalDownRight, .diagonalDownLeft:
      return 1
    case .verticalReverse, .diagonalUpRight, .diagonalUpLeft:
      return -1
    case .horizontal, .horizontalReverse:
      return 0
    }
  }

  var symbol: String {
    switch self {
    case .horizontal: return "→"
    case .vertical: return "↓"
    case .diagonalDownRight: return "↘"
    case .diagonalDownLeft: return "↙"
    case .diagonalUpRight: return "↗"
    case .diagonalUpLeft: return "↖"
    case .horizontalReverse: return "←"
    case .verticalReverse: return "↑"
    }
  }

  static let veryEasy: Set<Direction> = [
    .horizontal,
    .vertical,
    .diagonalDownRight,
    .diagonalUpRight,
  ]

  static let easy: Set<Direction> = [
    .horizontal,
    .vertical,
    .diagonalDownRight,
    .diagonalUpRight,
  ]

  static let medium: Set<Direction> = [
    .horizontal,
    .vertical,
    .diagonalDownRight,
    .diagonalUpRight,
    .horizontalReverse,
    .verticalReverse,
  ]

  static let hard: Set<Direction> = Direction.all

  static let veryHard: Set<Direction> = Direction.all

  static let all: Set<Direction> = [
    .horizontal,
    .vertical,
    .diagonalDownRight,
    .diagonalDownLeft,
    .diagonalUpRight,
    .diagonalUpLeft,
  ]

  static func direction(from dx: Int, dy: Int) -> Direction {
    switch (dx, dy) {
    case (1, 0): return .horizontal
    case (1, -1): return .diagonalUpRight
    case (1, 1): return .diagonalDownRight

    case (0, 1): return .vertical
    case (0, -1): return .verticalReverse

    case (-1, 1): return .diagonalDownLeft
    case (-1, -1): return .diagonalUpLeft
    case (-1, 0): return .horizontalReverse
    default: return .horizontal
    }
  }
}
