import Foundation
import GRDB

class DatabaseManager {
  private(set) var dbQueue: DatabaseQueue?
  private let databaseName: String

  init(databaseName: String, createTables: @escaping (DatabaseQueue) throws -> Void) {
    self.databaseName = databaseName
    setupDatabase(createTables: createTables)
  }

  private func setupDatabase(createTables: @escaping (DatabaseQueue) throws -> Void) {
    do {
      let fileManager = FileManager.default
      let dbURL = try getDatabaseURL()

      // Check if the database file exists, if not, create it
      let dbExists = fileManager.fileExists(atPath: dbURL.path)

      dbQueue = try DatabaseQueue(path: dbURL.path)

      //if !dbExists {
        try createTables(dbQueue!)
      //}

    } catch {
      print("Database setup failed: \(error)")
    }
  }

  private func getDatabaseURL() throws -> URL {
    let fileManager = FileManager.default
    let folderURL =
      try fileManager
      .url(
        for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
      )
      .appendingPathComponent("MyAppDatabase", isDirectory: true)

    if !fileManager.fileExists(atPath: folderURL.path) {
      try fileManager.createDirectory(
        at: folderURL, withIntermediateDirectories: true, attributes: nil)
    }

    return folderURL.appendingPathComponent("database.sqlite")
  }

}
