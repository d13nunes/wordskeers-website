import Foundation

// /// Service responsible for managing the overall game state and coordinating game logic
@Observable class GameStateManager {
  // MARK: - Public Properties

  /// The current state of the game
  private(set) var currentState: GameState
  private(set) var selectedCells: [(Int, Int)] = []
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

  private let wordList: [String]
  private let gridGenerator: GridGenerator
  private var wordValidator: WordValidator
  private var timer: Timer?

  // MARK: - Initialization

  init(wordList: [String]) {
    self.wordList = wordList
    // Initialize game services
    self.gridGenerator = GridGenerator(words: wordList, size: 5)
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
    handleEvent(.start)
  }

  /// Validates a word based on selected grid positions
  /// - Parameter positions: Array of (row, column) positions in the grid
  /// - Returns: The valid word if found, nil otherwise
  func checkIfIsWord(in positions: [(Int, Int)]) -> String? {
    guard case .playing = currentState else { return nil }
  
    let word = grid.getWord(in: positions)
    guard wordValidator.validateWord(word) else { return nil }
    
    selectedCells += positions
  
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

  /// Resets the game state for a new level
  func resetGameState() {
    // Reset timer
    stopTimer()
    timeElapsed = 0

    // Generate new grid
    let (newGrid, placedWords) = gridGenerator.getGrid()
    grid = newGrid

    // Reset word validator with new words
    wordValidator = WordValidator(words: placedWords)
    selectedCells = []
  
  }

  deinit {
    stopTimer()
  }
}
