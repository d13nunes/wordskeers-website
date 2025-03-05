import Foundation

struct GameConfigurationSetting {
  let gridSize: Int
  let wordsCount: Int
  let validDirections: Set<Direction>
}

enum Difficulty: String {
  case veryEasy = "Very Easy"
  case easy = "Easy"
  case medium = "Medium"
  case hard = "Hard"
  case veryHard = "Very Hard"
}
@Observable final class NewGameSelectionViewModel {
  var selectedDifficulty: Difficulty = .easy
  let availableDifficulties: [Difficulty] = [.veryEasy, .easy, .medium, .hard]
  private let onStartGameCallback: (Difficulty) -> Void

  init(onStartGame: @escaping (Difficulty) -> Void) {
    self.onStartGameCallback = onStartGame
  }

  var selectedValidDirections: [Direction] {
    Array(difficultyGameConfig[selectedDifficulty]!.validDirections)
  }

  var selectedGridSize: Int {
    difficultyGameConfig[selectedDifficulty]!.gridSize
  }

  var selectedWordsCount: Int {
    difficultyGameConfig[selectedDifficulty]!.wordsCount
  }

  var selectedDifficultyGameConfig: GameConfigurationSetting {
    difficultyGameConfig[selectedDifficulty]!
  }

  private let difficultyGameConfig: [Difficulty: GameConfigurationSetting] = [
    .veryEasy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: 6,
      validDirections: Directions.veryEasy
    ),
    .easy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: 8,
      validDirections: Directions.easy
    ),
    .medium: GameConfigurationSetting(
      gridSize: 10,
      wordsCount: 15,
      validDirections: Directions.medium
    ),
    .hard: GameConfigurationSetting(
      gridSize: 16,
      wordsCount: 20,
      validDirections: Directions.hard
    ),
    .veryHard: GameConfigurationSetting(
      gridSize: 20,
      wordsCount: 25,
      validDirections: Directions.veryHard
    ),
  ]

  func startGame() {
    onStartGameCallback(selectedDifficulty)
  }
}
