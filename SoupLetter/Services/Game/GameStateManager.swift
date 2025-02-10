import Foundation

/// Represents the current state of the game
enum GameState {
  case loading
  case playing
  case paused
  case completed
}

/// Service responsible for managing the overall game state
@Observable class GameStateManager {
  /// The current state of the game
  private(set) var state: GameState = .loading

  /// The current score
  private(set) var score: Int = 0

  /// The current level
  private(set) var currentLevel: Int = 1

  /// The current word list
  private let wordList: WordList

  /// The grid generator service
  private let gridGenerator: GridGenerator

  /// The word validator service
  private let wordValidator: WordValidator

  /// The user input handler service
  private let inputHandler: UserInputHandler

  /// The storage service
  private let storage: any StorageProtocol

  /// The current grid
  private(set) var grid: [[Character]]

  /// Time elapsed in seconds
  private(set) var timeElapsed: TimeInterval = 0

  /// Timer for tracking game duration
  private var timer: Timer?

  init(wordList: WordList, storage: any StorageProtocol) {
    self.wordList = wordList
    self.storage = storage

    // Initialize game services
    self.gridGenerator = GridGenerator()
    let grid = gridGenerator.generateGrid(
      size: wordList.difficulty.gridSize, words: wordList.words)
    self.grid = grid
    self.wordValidator = WordValidator(
      words: wordList.words, minWordLength: wordList.difficulty.minWordLength)
    self.inputHandler = UserInputHandler(gridSize: wordList.difficulty.gridSize, grid: grid)

    // Load saved progress
    Task {
      await loadProgress()
    }
  }

  /// Starts a new game
  func startGame() {
    state = .playing
    startTimer()
  }

  /// Pauses the game
  func pauseGame() {
    state = .paused
    stopTimer()
  }

  /// Resumes the game
  func resumeGame() {
    state = .playing
    startTimer()
  }

  /// Handles word submission
  func submitWord(_ word: String) async {
    let (isValid, points) = wordValidator.validateWord(word)

    if isValid {
      score += points
      await saveProgress()

      if wordValidator.isComplete {
        completeGame()
      }
    }
  }

  /// Completes the current game
  private func completeGame() {
    state = .completed
    stopTimer()
    currentLevel += 1

    Task {
      await saveProgress()
    }
  }

  /// Starts a new level
  func startNextLevel() {
    grid = gridGenerator.generateGrid(size: wordList.difficulty.gridSize, words: wordList.words)
    wordValidator.reset()
    timeElapsed = 0
    startGame()
  }

  /// Returns whether a word has been found
  func isWordFound(_ word: String) -> Bool {
    wordValidator.isWordFound(word)
  }

  /// Returns a hint for an unfound word
  func getHint() -> String? {
    wordValidator.getHint()
  }

  /// Returns the coordinates for a word in the grid
  func findWordCoordinates(_ word: String) -> [(Int, Int)]? {
    gridGenerator.findWordCoordinates(word, in: grid)
  }

  /// Returns the current completion percentage
  var completionPercentage: Double {
    wordValidator.completionPercentage
  }

  /// Returns the list of found words
  var foundWords: [String] {
    wordValidator.foundWordsList
  }

  /// Returns the total number of words to find
  var totalWords: Int {
    wordValidator.totalWords
  }

  /// Returns the number of words found
  var foundWordCount: Int {
    wordValidator.foundWordCount
  }

  /// Loads saved progress from storage
  private func loadProgress() async {
    do {
      let progress = try await storage.fetchGameProgress()
      if progress.wordListId == wordList.id {
        self.score = progress.score
        self.currentLevel = progress.currentLevel
        // Don't restore time elapsed to give a fresh start
      }
    } catch {
      print("Failed to load progress: \(error)")
      // Start fresh if no progress is found
    }
  }

  /// Saves current progress to storage
  private func saveProgress() async {
    do {
      let progress = GameProgress(
        score: score,
        foundWords: Set(wordValidator.foundWordsList),
        currentLevel: currentLevel,
        lastPlayedDate: Date(),
        wordListId: wordList.id
      )
      try await storage.saveGameProgress(progress)
    } catch {
      print("Failed to save progress: \(error)")
    }
  }

  /// Starts the game timer
  private func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.timeElapsed += 1
    }
  }

  /// Stops the game timer
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  deinit {
    stopTimer()
  }
}
