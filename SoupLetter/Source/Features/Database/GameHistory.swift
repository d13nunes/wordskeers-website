import Foundation
import GRDB

/// Represents a record of a game played by the user
struct GameHistory: Identifiable, Codable, Equatable, TableRecord, FetchableRecord,
  PersistableRecord
{
  /// The unique identifier for the game history record
  var id: Int64?

  /// The foreign key reference to the grid that was played
  var gridId: Int64

  /// The date when the game was played
  var playedAt: Date

  /// The score achieved in the game
  var score: Int

  /// The time taken to complete the game (in seconds)
  var timeTaken: TimeInterval?

  /// The mode of the game
  var gameMode: Int

  var hintPowerUpsUsed: Int

  static let databaseTableName = "game_history"

  enum Columns {
    static let id = Column(CodingKeys.id)
    static let gridId = Column(CodingKeys.gridId)
    static let playedAt = Column(CodingKeys.playedAt)
    static let score = Column(CodingKeys.score)
    static let timeTaken = Column(CodingKeys.timeTaken)
    static let gameMode = Column(CodingKeys.gameMode)
    static let hintPowerUpsUsed = Column(CodingKeys.hintPowerUpsUsed)
  }
}

// MARK: - Codable Support
extension GameHistory {
  private enum CodingKeys: String, CodingKey {
    case id
    case gridId = "grid_id"
    case playedAt = "played_at"
    case score
    case timeTaken = "time_taken"
    case gameMode = "game_mode"
    case hintPowerUpsUsed = "hint_power_ups_used"
  }
}
