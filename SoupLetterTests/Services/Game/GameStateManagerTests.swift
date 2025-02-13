import XCTest

@testable import SoupLetter

final class GameStateManagerTests: XCTestCase {
  // MARK: - Properties
  private var sut: GameStateManager!
  private let testWords = ["CAT", "DOG", "BIRD"]

  // MARK: - Setup & Teardown
  override func setUp() {
    super.setUp()
    sut = GameStateManager(wordList: testWords)
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  // MARK: - Initialization Tests

  func testInitialState() {
    XCTAssertEqual(sut.currentState, .loading(LoadingState()))
    XCTAssertEqual(sut.timeElapsed, 0)
    XCTAssertTrue(sut.selectedCells.isEmpty)
    XCTAssertFalse(sut.grid.isEmpty)
  }

  // MARK: - Game State Transition Tests

  func testStartGameTransition() {
    // When
    sut.startGame()

    // Then
    XCTAssertEqual(sut.currentState, .playing(PlayingState(manager: sut)))
  }

  func testPauseGameTransition() {
    // Given
    sut.startGame()

    // When
    sut.pauseGame()

    // Then
    XCTAssertEqual(sut.currentState, .paused(PausedState()))
  }

  func testResumeGameTransition() {
    // Given
    sut.startGame()
    sut.pauseGame()

    // When
    sut.resumeGame()

    // Then
    XCTAssertEqual(sut.currentState, .playing(PlayingState(manager: sut)))
  }

  func testCompleteGameTransition() {
    // Given
    sut.startGame()

    // When
    sut.handleEvent(.complete)

    // Then
    XCTAssertEqual(sut.currentState, .completed(CompletedState()))
  }

  // MARK: - Word Validation Tests

  func testValidWordSubmission() {
    // Given
    sut.startGame()
    let coordinates = sut.grid.findWordCoordinates("CAT")!

    // When
    let result = sut.validateWord(in: coordinates)

    // Then
    XCTAssertEqual(result, "CAT")
    XCTAssertEqual(sut.foundWordCount, 1)
    XCTAssertTrue(sut.foundWords.contains("CAT"))
  }

  func testInvalidWordSubmission() {
    // Given
    sut.startGame()
    let invalidCoordinates = [(0, 0), (0, 1)]

    // When
    let result = sut.validateWord(in: invalidCoordinates)

    // Then
    XCTAssertNil(result)
    XCTAssertEqual(sut.foundWordCount, 0)
    XCTAssertTrue(sut.foundWords.isEmpty)
  }

  func testDuplicateWordSubmission() {
    // Given
    sut.startGame()
    let coordinates = sut.grid.findWordCoordinates("CAT")!

    // When
    let firstResult = sut.validateWord(in: coordinates)
    let secondResult = sut.validateWord(in: coordinates)

    // Then
    XCTAssertEqual(firstResult, "CAT")
    XCTAssertNil(secondResult)
    XCTAssertEqual(sut.foundWordCount, 1)
  }

  // MARK: - Timer Tests

  func testTimerIncrement() {
    // Given
    sut.startGame()

    // When
    sut.startTimer()

    // Then
    let expectation = XCTestExpectation(description: "Timer should increment")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
      XCTAssertGreaterThan(self.sut.timeElapsed, 0)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 2)
  }

  func testTimerPause() {
    // Given
    sut.startGame()
    sut.startTimer()

    // When
    sut.stopTimer()
    let initialTime = sut.timeElapsed

    // Then
    let expectation = XCTestExpectation(description: "Timer should not increment when stopped")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
      XCTAssertEqual(self.sut.timeElapsed, initialTime)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 2)
  }

  // MARK: - Next Level Tests

  func testNextLevelReset() {
    // Given
    sut.startGame()
    let initialGrid = sut.grid
    let coordinates = sut.grid.findWordCoordinates("CAT")!
    _ = sut.validateWord(in: coordinates)

    // When
    sut.startNextLevel()

    // Then
    XCTAssertNotEqual(sut.grid, initialGrid)
    XCTAssertEqual(sut.timeElapsed, 0)
    XCTAssertEqual(sut.foundWordCount, 0)
    XCTAssertTrue(sut.foundWords.isEmpty)
  }

  func testNextLevelStateTransition() {
    // Given
    sut.startGame()
    let coordinates = sut.grid.findWordCoordinates("CAT")!
    _ = sut.validateWord(in: coordinates)

    // When
    sut.handleEvent(.complete)
    sut.startNextLevel()

    // Then
    XCTAssertEqual(sut.currentState, .playing(PlayingState(manager: sut)))
  }
}
