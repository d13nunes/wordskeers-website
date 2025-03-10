import SwiftUI

/// A class that manages cell selection behavior in a grid-based game using a state machine pattern.
///
/// The SelectionHandler validates and tracks selections based on allowed directions and grid constraints.
/// Selection is performed by dragging from a start position, with the path updating in real-time
/// as the drag continues.
///
@Observable
final class SelectionHandler {
  // MARK: - Selection State

  var onDragStarted: (@MainActor () -> Void)?
  var onDragEnd: (@MainActor ([Position]) -> Void)?

  /// Represents the current state of the selection process
  private enum SelectionState {
    /// No active selection
    case idle
    /// Active drag selection in progress
    case dragging(from: Position)
  }

  // MARK: - Properties

  /// Current state of the selection process
  private var state: SelectionState = .idle

  /// Validates paths between positions based on allowed directions and grid constraints
  private var pathValidator: PathValidator

  /// Currently selected cell positions in the grid
  private(set) var selectedCells: [Position] = []

  // MARK: - Initialization

  /// Creates a new SelectionHandler with specified movement constraints
  /// - Parameters:
  ///   - allowedDirections: Set of directions in which selection paths can be made
  ///   - gridSize: Size of the grid (assumes square grid)
  init(allowedDirections: Set<Direction>, gridSize: Int) {
    self.pathValidator = PathValidator(allowedDirections: allowedDirections, gridSize: gridSize)
  }

  // MARK: - Public Methods

  /// Updates the selection constraints and resets current selection
  /// - Parameters:
  ///   - validDirections: New set of allowed directions for path validation
  ///   - gridSize: New size of the grid
  @MainActor
  func update(validDirections: Set<Direction>, gridSize: Int) {
    pathValidator = PathValidator(allowedDirections: validDirections, gridSize: gridSize)
    reset()
  }

  /// Handles drag selection at the given position
  /// - Parameter position: The current position in the grid
  /// - Returns: `true` if the selection is valid, `false` otherwise
  @MainActor
  func handleDrag(at position: Position) -> Bool {
    switch state {
    case .idle:
      // Start new drag
      selectedCells = [position]
      state = .dragging(from: position)
      onDragStarted?()
      return true

    case .dragging(let start):
      // Update existing drag
      if pathValidator.isValidPath(from: start, to: position) {
        selectedCells = pathValidator.getPositionsInPath(from: start, to: position)
        return true
      }
      return false
    }
  }

  /// Ends the current drag selection
  @MainActor
  func endDrag() {
    onDragEnd?(selectedCells)
    reset()
  }

  /// Resets the selection state, clearing all selected cells
  @MainActor
  func reset() {
    state = .idle
    selectedCells = []
  }
}
