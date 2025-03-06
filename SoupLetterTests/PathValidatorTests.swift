import XCTest

@testable import SoupLetter

final class PathValidatorTests: XCTestCase {
  // Test configurations
  private let gridSize = 5

  // Test data structure
  struct PathTestCase {
    let name: String
    let start: Position
    let end: Position
    let allowedDirections: Set<Direction>
    let expectedValid: Bool
    let expectedPositions: [Position]
  }

  // Test cases
  private let testCases: [PathTestCase] = [
    // Horizontal right
    PathTestCase(
      name: "Horizontal right",
      start: Position(row: 2, col: 1),
      end: Position(row: 2, col: 3),
      allowedDirections: [Direction(dx: 1, dy: 0)],
      expectedValid: true,
      expectedPositions: [
        Position(row: 2, col: 1),
        Position(row: 2, col: 2),
        Position(row: 2, col: 3),
      ]
    ),
    // Horizontal left
    PathTestCase(
      name: "Horizontal left",
      start: Position(row: 2, col: 3),
      end: Position(row: 2, col: 1),
      allowedDirections: [Direction(dx: -1, dy: 0)],
      expectedValid: true,
      expectedPositions: [
        Position(row: 2, col: 3),
        Position(row: 2, col: 2),
        Position(row: 2, col: 1),
      ]
    ),
    // Vertical down
    PathTestCase(
      name: "Vertical down",
      start: Position(row: 1, col: 2),
      end: Position(row: 3, col: 2),
      allowedDirections: [Direction(dx: 0, dy: 1)],
      expectedValid: true,
      expectedPositions: [
        Position(row: 1, col: 2),
        Position(row: 2, col: 2),
        Position(row: 3, col: 2),
      ]
    ),
    // Diagonal
    PathTestCase(
      name: "Diagonal down-right",
      start: Position(row: 1, col: 1),
      end: Position(row: 3, col: 3),
      allowedDirections: [Direction(dx: 1, dy: 1)],
      expectedValid: true,
      expectedPositions: [
        Position(row: 1, col: 1),
        Position(row: 2, col: 2),
        Position(row: 3, col: 3),
      ]
    ),
    // Invalid direction
    PathTestCase(
      name: "Invalid direction",
      start: Position(row: 1, col: 1),
      end: Position(row: 3, col: 3),
      allowedDirections: [Direction.horizontal],
      expectedValid: false,
      expectedPositions: []
    ),
    // Same position - should not be valid since it's not a path
    PathTestCase(
      name: "Same position",
      start: Position(row: 2, col: 2),
      end: Position(row: 2, col: 2),
      allowedDirections: [Direction(dx: 1, dy: 0)],
      expectedValid: false,
      expectedPositions: []
    ),
  ]

  func testAllPaths() {
    for testCase in testCases {
      let validator = PathValidator(
        allowedDirections: testCase.allowedDirections,
        gridSize: gridSize
      )

      // Test path validity
      let isValid = validator.isValidPath(from: testCase.start, to: testCase.end)
      XCTAssertEqual(
        isValid,
        testCase.expectedValid,
        "Failed validity check for test case: \(testCase.name)"
      )

      // Test positions in path
      let positions = validator.getPositionsInPath(from: testCase.start, to: testCase.end)
      XCTAssertEqual(
        positions,
        testCase.expectedPositions,
        "Failed positions check for test case: \(testCase.name)"
      )
    }
  }
}
