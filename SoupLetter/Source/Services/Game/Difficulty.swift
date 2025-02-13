enum Difficulty: Int, Codable, CaseIterable {
  case easy = 1
  case medium = 2
  case hard = 3

  var description: String {
    switch self {
    case .easy: "easy"
    case .medium: "medium"
    case .hard: "hard"
    }
  }

  func getGridSize() -> Int {
    switch self {
    case .easy:
      return 6
    case .medium:
      return 12
    case .hard:
      return 18
    }
  }

  var index: Int {
    switch self {
    case .easy:
      return 0
    case .medium:
      return 1
    case .hard:
      return 2
    }
  }
}
