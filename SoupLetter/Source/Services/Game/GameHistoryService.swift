import Foundation
import GRDB
import OSLog

struct GameHistoryRecord {
  let gridId: Int64
  let gameMode: Int
  let score: Int
  let timeTaken: TimeInterval
  let playedAt: Date
  let powerUpsUsed: [PowerUpType: Int]
}

protocol GameHistoryServicing {
  func save(record: GameHistoryRecord) async -> GameHistory?
}
/// Service for managing game history records
final class GameHistoryService: GameHistoryServicing {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "",
    category: "GameHistory"
  )

  /// Database configuration
  private static var configuration: Configuration {
    var config = Configuration()
    config.prepareDatabase { db in
    }
    return config
  }

  /// A list of recent games played
  private(set) var recentGames: [GameHistory] = []

  /// Game statistics derived from history
  private(set) var statistics: (gamesPlayed: Int, averageScore: Double, bestScore: Int) = (0, 0, 0)

  private var dbQueue: DatabaseQueue {
    databaseManager.dbQueue!
  }

  private let databaseManager: DatabaseManager

  static let name = "game_history.sqlite"

  init(
    databaseManager: DatabaseManager = DatabaseManager(
      databaseName: name, createTables: createDatabaseManager)
  ) {
    self.databaseManager = databaseManager
    print("🗞️🗞️ GameHistoryService initialized")
    Task { try printAllGameHistory() }
  }

  /// Records a completed game to the history
  /// - Parameters:
  ///   - gridId: The ID of the grid that was played
  ///   - score: The score achieved in the game
  ///   - timeTaken: The time taken to complete the game (in seconds), if available
  ///   - completed: Whether all words were found
  ///   - metadata: Additional game information as JSON, if any
  /// - Returns: The saved game history record
  func save(record: GameHistoryRecord) async -> GameHistory? {
    print("🗞️🗞️ Saving game history record: \(record)")
    do {
      let savedHistory = try saveGameHistory(record)
      return savedHistory
    } catch {
      print("🗞️Failed to record game: \(error.localizedDescription)")
      return nil
    }
  }

  /// Gets all grids that the player has already played
  /// - Returns: An array of grid IDs
  func getPlayedGrids() async -> [Int64] {
    do {
      return try getPlayedGridIds()
    } catch {
      print("🗞️Failed to get played grids: \(error.localizedDescription)")
      return []
    }
  }

  func saveGameHistory(_ record: GameHistoryRecord) throws -> GameHistory {
    let gameHistory = GameHistory(
      id: nil,
      gridId: record.gridId,
      playedAt: record.playedAt,
      score: record.score,
      timeTaken: record.timeTaken,
      gameMode: record.gameMode,
      hintPowerUpsUsed: record.powerUpsUsed[.hint] ?? 0
    )
    try dbQueue.write { db in
      try gameHistory.save(db)
    }
    return gameHistory
  }

  /// Get all game history records
  /// - Returns: Array of all game history records, sorted by played date (newest first)
  func getAllGameHistory() throws -> [GameHistory] {
    try dbQueue.read { db in
      try GameHistory.order(GameHistory.Columns.playedAt.desc).fetchAll(db)
    }
  }

  /// Get game history by grid ID
  /// - Parameter gridId: The grid ID
  /// - Returns: Array of game history records for the grid, sorted by played date (newest first)
  func getGameHistory(gridId: Int64) throws -> [GameHistory] {
    try dbQueue.read { db in
      try GameHistory
        .filter(GameHistory.Columns.gridId == gridId)
        .order(GameHistory.Columns.playedAt.desc)
        .fetchAll(db)
    }
  }

  /// Get the most recent game history
  /// - Parameter limit: Maximum number of records to return
  /// - Returns: Array of recent game history records, sorted by played date (newest first)
  func getRecentGameHistory(limit: Int = 10) throws -> [GameHistory] {
    try dbQueue.read { db in
      try GameHistory
        .order(GameHistory.Columns.playedAt.desc)
        .limit(limit)
        .fetchAll(db)
    }
  }

  /// Get statistics about games played
  /// - Returns: A tuple containing total games played, average score, and best score
  func getGameStatistics() throws -> (gamesPlayed: Int, averageScore: Double, bestScore: Int) {
    try dbQueue.read { db in
      let count = try GameHistory.fetchCount(db)
      let avg = try Double.fetchOne(db, sql: "SELECT AVG(score) FROM game_history") ?? 0.0
      let max = try Int.fetchOne(db, sql: "SELECT MAX(score) FROM game_history") ?? 0

      return (gamesPlayed: count, averageScore: avg, bestScore: max)
    }
  }

  /// Check if a grid has been played before
  /// - Parameter gridId: The grid ID to check
  /// - Returns: True if the grid has been played, false otherwise
  func hasPlayedGrid(gridId: Int64) throws -> Bool {
    try dbQueue.read { db in
      try GameHistory.filter(GameHistory.Columns.gridId == gridId).fetchCount(db) > 0
    }
  }

  /// Get all grid IDs that have been played
  /// - Returns: Array of grid IDs that have been played
  func getPlayedGridIds() throws -> [Int64] {
    try dbQueue.read { db in
      try Int64.fetchAll(
        db,
        sql: "SELECT DISTINCT grid_id FROM game_history"
      )
    }
  }

  func printAllGameHistory() throws {
    try dbQueue.read { db in
      try GameHistory.fetchAll(db).forEach { print("🗞️🗞️ \($0)") }
    }
  }

  static func createDatabaseManager(database: DatabaseQueue) throws {
    try database.write { db in
      // Only create game_history if it doesn't exist
      try db.create(table: GameHistory.databaseTableName, ifNotExists: true) { table in
        table.autoIncrementedPrimaryKey("id")
        table.column(GameHistory.Columns.gridId.name, .integer).notNull()
        table.column(GameHistory.Columns.gameMode.name, .integer).notNull()
        table.column(GameHistory.Columns.playedAt.name, .datetime).notNull()
        table.column(GameHistory.Columns.score.name, .integer).notNull()
        table.column(GameHistory.Columns.timeTaken.name, .double)
        table.column(GameHistory.Columns.hintPowerUpsUsed.name, .integer)
      }
    }
  }
}
