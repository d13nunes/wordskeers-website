import Foundation
import GRDB
import OSLog

/// Service for managing SQLite database operations
@Observable
final class DatabaseService: GridFetching {
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "", category: "grids.sqlite")

  /// The database queue for thread-safe database access
  private let dbQueue: DatabaseQueue

  init() throws {
    guard let dbPath = Bundle.main.path(forResource: "grids", ofType: "sqlite") else {
      do {
        self.dbQueue = try DatabaseQueue(configuration: DatabaseService.configuration)
      } catch {
        throw error
      }
      return
    }
    // If the resource exists, open a read-only connection.
    // Writes are disallowed because resources can not be modified.
    var config = Configuration()
    config.readonly = true
    do {
      self.dbQueue = try DatabaseQueue(path: dbPath, configuration: config)
    } catch {
      throw error
    }
  }

  /// Database configuration
  private static var configuration: Configuration {
    var config = Configuration()
    config.prepareDatabase { db in
      // Enable foreign keys
      try db.execute(sql: "PRAGMA foreign_keys = ON")
    }
    return config
  }

  // MARK: - WordSearchGrid Operations

  /// Save a word search grid to the database
  /// - Parameter grid: The grid to save
  /// - Returns: The saved grid with its ID
  func saveGrid(_ grid: WordSearchGrid) throws -> WordSearchGrid {
    var savedGrid = grid
    try dbQueue.write { db in
      try savedGrid.save(db)
    }
    return savedGrid
  }

  /// Get all word search grids
  /// - Returns: Array of all word search grids
  func getAllGrids() throws -> [WordSearchGrid] {
    try dbQueue.read { db in
      try WordSearchGrid.fetchAll(db)
    }
  }

  /// Get a word search grid by ID
  /// - Parameter id: The grid ID
  /// - Returns: The grid if found, nil otherwise
  func getGrid(id: Int64) throws -> WordSearchGrid? {
    try dbQueue.read { db in
      try WordSearchGrid.fetchOne(db, key: id)
    }
  }

  /// Delete a word search grid
  /// - Parameter id: The ID of the grid to delete
  /// - Returns: True if the grid was deleted, false otherwise
  @discardableResult
  func deleteGrid(id: Int64) throws -> Bool {
    try dbQueue.write { db in
      try WordSearchGrid.deleteOne(db, key: id)
    }
  }

  // MARK: - WordPlacement Operations

  /// Save a word placement to the database
  /// - Parameter placement: The word placement to save
  /// - Returns: The saved word placement with its ID
  func savePlacement(_ placement: WordPlacement) throws -> WordPlacement {
    var savedPlacement = placement
    try dbQueue.write { db in
      try savedPlacement.save(db)
    }
    return savedPlacement
  }

  /// Save multiple word placements in a single transaction
  /// - Parameter placements: The word placements to save
  /// - Returns: The saved word placements with their IDs
  func savePlacements(_ placements: [WordPlacement]) throws -> [WordPlacement] {
    var savedPlacements: [WordPlacement] = []
    try dbQueue.write { db in
      for var placement in placements {
        try placement.save(db)
        savedPlacements.append(placement)
      }
    }
    return savedPlacements
  }

  /// Get all word placements for a grid
  /// - Parameter gridId: The grid ID
  /// - Returns: Array of word placements for the grid
  func getPlacements(gridId: Int64) throws -> [WordPlacement] {
    try dbQueue.read { db in
      let request = WordPlacement.filter(Column("grid_id") == gridId)
      return try request.fetchAll(db)
    }
  }

  /// Delete all word placements for a grid
  /// - Parameter gridId: The grid ID
  /// - Returns: The number of placements deleted
  @discardableResult
  func deletePlacements(gridId: Int64) throws -> Int {
    try dbQueue.write { db in
      try WordPlacement.filter(Column("gridId") == gridId).deleteAll(db)
    }
  }

  func getGrids(size: Int, wordsCount: Int, directions: [Direction], except: [Int64] = [])
    throws -> [WordSearchGrid]
  {
    try dbQueue.read { database in
      let grids = try WordSearchGrid.filter(
        WordSearchGrid.Columns.size == size
          && WordSearchGrid.Columns.wordsCount == wordsCount
          && !except.contains(WordSearchGrid.Columns.id)
      ).fetchAll(database)
      return grids
    }
  }

  func getRandomFullGrid(config: GameConfigurationSetting, except: [Int64] = []) throws
    -> GridDataDTO
  {
    let grids = try getGrids(
      size: config.gridSize,
      wordsCount: config.wordsCount,
      directions: Array(config.validDirections),
      except: except
    )
    let filteredGrids = grids.filter { !except.contains($0.id!) }

    func sameDirections(grid: WordSearchGrid) -> Bool {
      guard grid.directions.count == config.validDirections.count else { return false }
      return grid.directions.allSatisfy { config.validDirections.contains($0) }
    }

    let grid = filteredGrids.filter(sameDirections).randomElement()!

    print("✅✅ Grid:random \(String(describing: grid.id))")
    let placements = try getPlacements(gridId: grid.id!)
    return GridDataDTO(
      category: grid.name,
      size: grid.size,
      placedWordsCount: grid.wordsCount,
      placedWords: placements.map {
        WordPlacementDTO(word: $0.word, row: $0.row, col: $0.col, direction: $0.direction)
      }
    )
  }

  func getGridRandom(config: GameConfigurationSetting) -> GridDataDTO {
    do {
      let start = CFAbsoluteTimeGetCurrent()
      let grid = try getRandomFullGrid(config: config)
      let end = CFAbsoluteTimeGetCurrent()
      print("⏱️ getRandomFullGrid took \(end - start) seconds")
      return grid
    } catch {
      print("✅✅Error getting random grid: \(error)")
      return GridDataDTO(
        category: "animals",
        size: 10,
        placedWordsCount: 10,
        placedWords: [
          WordPlacementDTO(
            word: "dog1",
            row: 0,
            col: 0,
            direction: .horizontal
          ),
          WordPlacementDTO(
            word: "cat2",
            row: 0,
            col: 4,
            direction: .vertical
          ),

        ]
      )
    }
  }
}
