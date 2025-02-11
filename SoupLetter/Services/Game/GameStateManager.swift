import Foundation

/// Represents possible game state transitions
enum GameEvent {
  case start
  case pause
  case resume
  case complete
  case nextLevel
}

/// Protocol defining behavior for each game state
protocol GameStateProtocol {
  /// Handles state transitions based on events
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState?

  /// Called when entering this state
  func enter()

  /// Called when exiting this state
  func exit()
}

/// Represents the current state of the game
enum GameState: Equatable {
  static func == (lhs: GameState, rhs: GameState) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading): return true
    case (.playing, .playing): return true
    case (.paused, .paused): return true
    case (.completed, .completed): return true
    default: return false
    }
  }
  case loading(LoadingState)
  case playing(PlayingState)
  case paused(PausedState)
  case completed(CompletedState)

  /// Returns the underlying state object
  var state: GameStateProtocol {
    switch self {
    case .loading(let state): return state
    case .playing(let state): return state
    case .paused(let state): return state
    case .completed(let state): return state
    }
  }
}

/// Service responsible for managing the overall game state and coordinating game logic
@Observable class GameStateManager {
  // MARK: - Public Properties

  /// The current state of the game
  private(set) var currentState: GameState

  /// The current grid of letters
  private(set) var grid: [[String]]

  /// Time elapsed in seconds
  private(set) var timeElapsed: TimeInterval = 0

  // MARK: - Game Statistics

  /// Returns the current completion percentage (0-100)
  var completionPercentage: Double { wordValidator.completionPercentage }

  /// Returns the list of found words sorted alphabetically
  var foundWords: [String] { wordValidator.foundWordsList }

  /// Returns the total number of words to find
  var totalWords: Int { wordValidator.totalWords }

  /// Returns the number of words found
  var foundWordCount: Int { wordValidator.foundWordCount }

  // MARK: - Private Properties

  private let wordList: WordList
  private let gridGenerator: GridGenerator
  private let wordValidator: WordValidator
  private let storage: any StorageProtocol
  private var timer: Timer?

  // MARK: - Initialization

  init(wordList: WordList, storage: any StorageProtocol) {
    self.wordList = wordList
    self.storage = storage

    // Initialize game services
    self.gridGenerator = GridGenerator(words: wordList.words, size: wordList.difficulty.gridSize)
    let (generatedGrid, placedWords) = gridGenerator.getGrid()
    self.grid = generatedGrid
    self.wordValidator = WordValidator(words: placedWords)

    // Initialize with loading state
    self.currentState = .loading(LoadingState())
    self.currentState.state.enter()
  }

  // MARK: - Game Control Methods

  /// Handles game state transitions based on events
  func handleEvent(_ event: GameEvent) {
    if let newState = currentState.state.handleEvent(event, manager: self) {
      transition(to: newState)
    }
  }

  /// Starts a new game
  func startGame() {
    handleEvent(.start)
  }

  /// Pauses the current game
  func pauseGame() {
    handleEvent(.pause)
  }

  /// Resumes the paused game
  func resumeGame() {
    handleEvent(.resume)
  }

  /// Starts the next level with a new grid and words
  func startNextLevel() {
    handleEvent(.nextLevel)
  }

  /// Validates a word based on selected grid positions
  /// - Parameter positions: Array of (row, column) positions in the grid
  /// - Returns: The valid word if found, nil otherwise
  func checkIfIsWord(in positions: [(Int, Int)]) -> String? {
    guard case .playing = currentState else { return nil }

    let word = grid.getWord(in: positions)
    guard wordValidator.validateWord(word) else { return nil }

    if wordValidator.isComplete {
      handleEvent(.complete)
    }

    return word
  }

  // MARK: - Timer Methods

  func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.timeElapsed += 1
    }
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: - Private Methods

  private func transition(to newState: GameState) {
    currentState.state.exit()
    currentState = newState
    currentState.state.enter()
  }

  deinit {
    stopTimer()
  }
}

// MARK: - State Implementations

final class LoadingState: GameStateProtocol {
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .start: return .playing(PlayingState(manager: manager))
    default: return nil
    }
  }

  func enter() {}
  func exit() {}
}

final class PlayingState: GameStateProtocol {
  private weak var manager: GameStateManager?

  init(manager: GameStateManager?) {
    self.manager = manager
  }

  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .pause: return .paused(PausedState())
    case .complete: return .completed(CompletedState())
    default: return nil
    }
  }

  func enter() {
    manager?.startTimer()
  }

  func exit() {
    manager?.stopTimer()
  }
}

final class PausedState: GameStateProtocol {

  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .resume: return .playing(PlayingState(manager: manager))
    default: return nil
    }
  }

  func enter() {}
  func exit() {}
}

final class CompletedState: GameStateProtocol {
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .nextLevel:
      manager.startNextLevel()
      return .playing(PlayingState(manager: manager))
    default: return nil
    }
  }

  func enter() {}
  func exit() {}
}
