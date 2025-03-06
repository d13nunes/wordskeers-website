import SwiftUI

@Observable final class GameModeSelectionViewModel {
  // MARK: - Properties
  var selectedCategory: String = "Random"
  var availableCategories: [String] = ["Random", "Animals", "Food", "Sports", "Cities", "Flowers"]
  var gridSize: Int = 15
  var wordCount: Int = 5
  var allowedDirections: Set<Direction> = Set(Direction.all)

  // MARK: - Constants
  let minGridSize = 5
  let maxGridSize = 20
  let minWordCount = 2

  private let _onStartGame: (GameConfigurationSetting) -> Void

  init(onStartGame: @escaping (GameConfigurationSetting) -> Void) {
    self._onStartGame = onStartGame
  }

  var maxWordCount: Int {
    // Simple heuristic: grid size squared divided by 10
    // This can be adjusted based on actual game requirements
    return max(minWordCount, (gridSize * gridSize) / 10)
  }

  // MARK: - Actions
  func startGame() {
    _onStartGame(
      GameConfigurationSetting(
        gridSize: gridSize,
        wordsCount: wordCount,
        validDirections: allowedDirections
      ))
  }

  func toggleDirection(_ directionGroup: Direction) {
    if allowedDirections.contains(directionGroup) {
      // Ensure at least one direction remains selected
      guard allowedDirections.count > 1 else { return }
      allowedDirections.remove(directionGroup)
    } else {
      allowedDirections.insert(directionGroup)
    }
  }
}
