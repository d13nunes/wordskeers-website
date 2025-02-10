import Foundation

/// Service responsible for managing word lists
@Observable class WordListService {
  /// The storage service
  private let storage: any StorageProtocol

  /// Currently loaded word lists
  private(set) var wordLists: [WordList] = []

  /// Loading state
  private(set) var isLoading = false

  /// Error state
  private(set) var error: Error?

  init(storage: any StorageProtocol) {
    self.storage = storage
  }

  /// Loads all available word lists
  func loadWordLists() async {
    isLoading = true
    error = nil

    do {
      wordLists = try await storage.fetchWordLists()
    } catch {
      self.error = error
      print("Failed to load word lists: \(error)")
    }

    isLoading = false
  }

  /// Saves a new word list
  func saveWordList(_ wordList: WordList) async {
    do {
      try await storage.saveWordList(wordList)
      await loadWordLists()  // Reload lists after saving
    } catch {
      self.error = error
      print("Failed to save word list: \(error)")
    }
  }

  /// Creates a default word list if none exist
  func createDefaultWordListIfNeeded() async {
    guard wordLists.isEmpty else { return }

    let defaultWords = [
      "SWIFT", "APPLE", "CODE", "GAME",
      "PLAY", "FUN", "WORD", "LIST",
      "FIND", "SEEK", "HIDE", "SOUP",
    ]

    let defaultList = WordList(
      name: "Default",
      words: defaultWords,
      difficulty: .medium
    )

    await saveWordList(defaultList)
  }

  /// Returns a word list by ID
  func wordList(withId id: UUID) -> WordList? {
    wordLists.first { $0.id == id }
  }

  /// Returns word lists filtered by difficulty
  func wordLists(forDifficulty difficulty: GameDifficulty) -> [WordList] {
    wordLists.filter { $0.difficulty == difficulty }
  }

  /// Validates a potential new word list
  func validateWordList(_ words: [String], difficulty: GameDifficulty) -> Bool {
    let minLength = difficulty.minWordLength
    let maxSize = difficulty.gridSize

    // Check if all words meet the minimum length requirement
    guard words.allSatisfy({ $0.count >= minLength }) else {
      return false
    }

    // Check if all words fit in the grid
    guard words.allSatisfy({ $0.count <= maxSize }) else {
      return false
    }

    // Check if we have enough words (at least 5)
    guard words.count >= 5 else {
      return false
    }

    // Check if all words contain only letters
    guard words.allSatisfy({ $0.allSatisfy({ $0.isLetter }) }) else {
      return false
    }

    return true
  }

  /// Creates a new word list from raw text
  func createWordList(name: String, rawText: String, difficulty: GameDifficulty) -> WordList? {
    // Split text into words, clean them up, and filter invalid ones
    let words =
      rawText
      .components(separatedBy: .whitespacesAndNewlines)
      .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
      .filter { !$0.isEmpty }

    guard validateWordList(words, difficulty: difficulty) else {
      return nil
    }

    return WordList(
      name: name,
      words: words,
      difficulty: difficulty
    )
  }
}
