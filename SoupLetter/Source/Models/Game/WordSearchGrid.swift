import Foundation
import GRDB

// word_search_grids
/// Represents a word search grid in the database
struct WordSearchGrid: Identifiable, Codable, Equatable, TableRecord, FetchableRecord,
  PersistableRecord
{
  /// The unique identifier for the grid
  var id: Int64?

  /// The name or title of the grid
  var name: String

  /// The size of the grid (number of rows/columns)
  var size: Int

  /// The number of words in the grid
  var wordsCount: Int

  /// The directions that words can be placed in the grid
  var directions: [Direction]

  static let databaseTableName = "word_search_grids"

  enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.name)
    static let size = Column(CodingKeys.size)
    static let wordsCount = Column(CodingKeys.wordsCount)
    static let directions = Column(CodingKeys.directions)

  }

  // MARK: - PersistableRecord

  /// Define the database encoding strategy for the directions array
  // static let databaseColumnEncodingStrategy = DatabaseColumnEncodingStrategy.custom({ db, key in
  //   if key.name == "directions" {
  //     return "directions_json"
  //   }
  //   return key.name
  // })

  // static func setupTable(_ db: Database) throws {
  //   try db.create(table: databaseTableName, ifNotExists: true) { table in
  //     table.autoIncrementedPrimaryKey("id")
  //     table.column("name", .text).notNull()
  //     table.column("size", .integer).notNull()
  //     table.column("wordsCount", .integer).notNull()
  //     table.column("directions_json", .text).notNull()
  //   }
  // }
}

// MARK: - Codable Support for DirectionType Array
extension WordSearchGrid {
  private enum CodingKeys: String, CodingKey {
    case id, name, size
    case wordsCount = "words_count"
    case directions
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(Int64.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    size = try container.decode(Int.self, forKey: .size)
    wordsCount = try container.decode(Int.self, forKey: .wordsCount)
    directions = try container.decode([Direction].self, forKey: .directions)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(size, forKey: .size)
    try container.encode(wordsCount, forKey: .wordsCount)
    try container.encode(directions, forKey: .directions)

  }
}
