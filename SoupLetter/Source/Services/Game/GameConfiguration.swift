import Foundation

struct GameConfiguration: Hashable {
  // MARK: - Properties

  /// Size of the game grid (width and height)
  let gridSize: Int
  let words: [String]
  let validDirections: Set<Direction>

  let category: String
}
