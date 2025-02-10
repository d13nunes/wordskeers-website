import Foundation
import SwiftData

@Model
class WordListEntity {
  var id: UUID
  var name: String
  var words: [String]
  var difficulty: GameDifficulty
  var language: String

  init(from wordList: WordList) {
    self.id = wordList.id
    self.name = wordList.name
    self.words = wordList.words
    self.difficulty = wordList.difficulty
    self.language = wordList.language
  }

  var toWordList: WordList {
    WordList(id: id, name: name, words: words, difficulty: difficulty, language: language)
  }
}

@Model
class GameProgressEntity {
  var id: UUID
  var score: Int
  var foundWords: [String]
  var currentLevel: Int
  var lastPlayedDate: Date
  var wordListId: UUID

  init(from progress: GameProgress) {
    self.id = progress.id
    self.score = progress.score
    self.foundWords = Array(progress.foundWords)
    self.currentLevel = progress.currentLevel
    self.lastPlayedDate = progress.lastPlayedDate
    self.wordListId = progress.wordListId
  }

  var toGameProgress: GameProgress {
    GameProgress(
      id: id,
      score: score,
      foundWords: Set(foundWords),
      currentLevel: currentLevel,
      lastPlayedDate: lastPlayedDate,
      wordListId: wordListId
    )
  }
}

@Observable
class SwiftDataRepository: StorageProtocol {
  private let modelContainer: ModelContainer
  private let modelContext: ModelContext

  @MainActor
  init() throws {
    let schema = Schema([WordListEntity.self, GameProgressEntity.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    self.modelContext = modelContainer.mainContext
  }

  func fetchWordLists() async throws -> [WordList] {
    let descriptor = FetchDescriptor<WordListEntity>()
    let entities = try modelContext.fetch(descriptor)
    return entities.map { $0.toWordList }
  }

  func saveWordList(_ wordList: WordList) async throws {
    let entity = WordListEntity(from: wordList)
    modelContext.insert(entity)
    try modelContext.save()
  }

  func fetchGameProgress() async throws -> GameProgress {
    let descriptor = FetchDescriptor<GameProgressEntity>()
    let entities = try modelContext.fetch(descriptor)
    guard let entity = entities.first else {
      throw StorageError.noProgressFound
    }
    return entity.toGameProgress
  }

  func saveGameProgress(_ progress: GameProgress) async throws {
    // Delete existing progress if any
    let descriptor = FetchDescriptor<GameProgressEntity>()
    let existingEntities = try modelContext.fetch(descriptor)
    existingEntities.forEach { modelContext.delete($0) }

    // Save new progress
    let entity = GameProgressEntity(from: progress)
    modelContext.insert(entity)
    try modelContext.save()
  }

  func clearAllData() async throws {
    try modelContext.delete(model: WordListEntity.self)
    try modelContext.delete(model: GameProgressEntity.self)
    try modelContext.save()
  }
}

enum StorageError: LocalizedError {
  case noProgressFound

  var errorDescription: String? {
    switch self {
    case .noProgressFound:
      return "No game progress found"
    }
  }
}
