import Foundation
import GRDB

/// Represents the placement of a word in a word search grid
struct WordPlacement: Identifiable, Codable, Equatable, TableRecord, FetchableRecord,
  PersistableRecord
{
  /// The unique identifier for the word placement
  var id: Int64?

  /// The foreign key reference to the grid this word belongs to
  var gridId: Int64

  /// The word that is placed in the grid
  var word: String

  /// The starting row position of the word (0-indexed)
  var row: Int

  /// The starting column position of the word (0-indexed)
  var col: Int

  /// The direction in which the word is placed
  var direction: Direction

  static let databaseTableName = "word_placements"

  enum Columns {
    static let id = Column(CodingKeys.id)
    static let gridId = Column(CodingKeys.gridId)
    static let word = Column(CodingKeys.word)
    static let row = Column(CodingKeys.row)
    static let col = Column(CodingKeys.col)
    static let direction = Column(CodingKeys.direction)
  }
}

// MARK: - Codable Support for DirectionType Array
extension WordPlacement {
  private enum CodingKeys: String, CodingKey {
    case id, word, row, col, direction
    case gridId = "grid_id"
  }

}
