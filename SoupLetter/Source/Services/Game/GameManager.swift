import Foundation

protocol GameStateOptions {
}

struct NewGameOptions: GameStateOptions {
  let configuration: GameConfiguration
}

// /// Service responsible for managing the overall game state and coordinating game logic
@Observable class GameManager {
  // MARK: - Public Properties

  /// The current state of the game
  private(set) var currentState: GameState
  private(set) var selectedCells: [(Int, Int)] = []
  /// The current grid of letters
  private(set) var grid: [[String]]

  /// Time elapsed in seconds
  private(set) var timeElapsed: TimeInterval = 0

  var completionPercentage: Double { wordValidator.completionPercentage }
  var totalWords: Int { wordValidator.totalWords }
  var foundWordCount: Int { wordValidator.foundWordCount }
  var words: [WordData] { wordValidator.words }

  // MARK: - Private Properties

  private let gridGenerator: GridGenerator
  private var wordValidator: WordValidator
  private var timer: Timer?

  // MARK: - Initialization

  init(configuration: GameConfiguration) {
    let wordsList = configuration.words
    // Initialize game services
    self.gridGenerator = GridGenerator(words: wordsList, size: configuration.gridSize)

    let (generatedGrid, wordsData) = gridGenerator.getGrid()
    self.grid = generatedGrid
    self.wordValidator = WordValidator(words: wordsData)

    // Initialize with loading state
    self.currentState = .load
  }

  // MARK: - Game Control Methods

  /// Handles game state transitions based on events
  func tryTransitioningTo(
    state: GameState,
    options: GameStateOptions? = nil,
    onCompletion: (() -> Void)? = nil
  ) {
    guard currentState != state else { return }
    switch state {
    case .resume:
      startTimer()
      currentState = .start
      onCompletion?()
    case .start:
      resetGameState()
      startTimer()
      currentState = .start
      onCompletion?()
    case .pause:
      stopTimer()
      currentState = .pause
      onCompletion?()
    case .complete:
      currentState = .complete
      stopTimer()
      onCompletion?()
    case .load:
      currentState = .load
      onCompletion?()
    }
  }

  /// Validates a word based on selected grid positions
  /// - Parameter positions: Array of (row, column) positions in the grid
  /// - Returns: The valid word if found, nil otherwise
  func validateWord(in positions: [(Int, Int)]) -> String? {
    guard case .start = currentState else { return nil }

    let word = grid.getWord(in: positions)
    guard wordValidator.validateWord(word) else { return nil }

    selectedCells += positions

    if wordValidator.isComplete {
      tryTransitioningTo(state: .complete)
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

  /// Resets the game state for a new level
  func resetGameState() {
    // Reset timer
    stopTimer()
    timeElapsed = 0

    // Generate new grid
    let (newGrid, wordsData) = gridGenerator.getGrid()
    grid = newGrid

    // Reset word validator with new words
    wordValidator = WordValidator(words: wordsData)
    selectedCells = []

  }

  deinit {
    stopTimer()
  }
}
