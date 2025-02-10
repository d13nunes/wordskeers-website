import Foundation
import SwiftUI

/// Service responsible for handling user input and gesture recognition
@Observable class UserInputHandler {
  /// Currently selected cell coordinates
  private(set) var selectedCells: [(Int, Int)] = []

  /// The current word formed by selected cells
  private(set) var currentWord: String = ""

  /// The size of the grid
  private let gridSize: Int

  /// The grid content
  private let grid: [[Character]]

  /// Minimum distance between cells to consider them connected
  private let minDistance: CGFloat = 20

  init(gridSize: Int, grid: [[Character]]) {
    self.gridSize = gridSize
    self.grid = grid
  }

  /// Handles the start of a drag gesture
  func handleDragStart(at coordinate: (Int, Int)) {
    guard isValidCoordinate(coordinate) else { return }
    selectedCells = [coordinate]
    updateCurrentWord()
  }

  /// Handles the continuation of a drag gesture
  func handleDragChange(at coordinate: (Int, Int)) {
    guard isValidCoordinate(coordinate),
      let lastCell = selectedCells.last,
      coordinate != lastCell,
      isAdjacent(coordinate, to: lastCell)
    else { return }

    // If dragging back to previous cell, remove the last selection
    if selectedCells.count > 1 && coordinate == selectedCells[selectedCells.count - 2] {
      selectedCells.removeLast()
    } else if !selectedCells.contains(where: { $0 == coordinate }) {
      selectedCells.append(coordinate)
    }

    updateCurrentWord()
  }

  /// Handles the end of a drag gesture
  func handleDragEnd() -> String {
    let word = currentWord
    selectedCells = []
    currentWord = ""
    return word
  }

  /// Checks if a coordinate is valid within the grid
  private func isValidCoordinate(_ coordinate: (Int, Int)) -> Bool {
    coordinate.0 >= 0 && coordinate.0 < gridSize && coordinate.1 >= 0 && coordinate.1 < gridSize
  }

  /// Checks if two coordinates are adjacent (including diagonally)
  private func isAdjacent(_ coord1: (Int, Int), to coord2: (Int, Int)) -> Bool {
    let dx = abs(coord1.0 - coord2.0)
    let dy = abs(coord1.1 - coord2.1)
    return dx <= 1 && dy <= 1 && !(dx == 0 && dy == 0)
  }

  /// Updates the current word based on selected cells
  private func updateCurrentWord() {
    currentWord =
      selectedCells
      .map { grid[$0.0][$0.1] }
      .map(String.init)
      .joined()
  }

  /// Converts a point in the view's coordinate space to a grid coordinate
  func gridCoordinate(from point: CGPoint, in size: CGSize) -> (Int, Int)? {
    let cellWidth = size.width / CGFloat(gridSize)
    let cellHeight = size.height / CGFloat(gridSize)

    let row = Int(point.y / cellHeight)
    let col = Int(point.x / cellWidth)

    guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else {
      return nil
    }

    return (row, col)
  }

  /// Returns whether a cell is currently selected
  func isCellSelected(_ coordinate: (Int, Int)) -> Bool {
    selectedCells.contains(where: { $0 == coordinate })
  }

  /// Returns the selection order of a cell (-1 if not selected)
  func cellSelectionOrder(_ coordinate: (Int, Int)) -> Int {
    selectedCells.firstIndex(where: { $0 == coordinate }) ?? -1
  }
}
