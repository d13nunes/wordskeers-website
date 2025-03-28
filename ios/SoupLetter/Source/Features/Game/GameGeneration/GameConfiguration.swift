import Foundation

struct GameConfiguration: Hashable {
  // MARK: - Properties

  /// Size of the game grid (width and height)
  let gridId: Int64
  let gridSize: Int
  let words: [String]
  let validDirections: Set<Direction>
  let category: String
  let gameMode: GameModeCode
}
