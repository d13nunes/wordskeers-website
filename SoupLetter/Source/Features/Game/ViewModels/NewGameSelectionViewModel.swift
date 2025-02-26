import Foundation

struct GameConfigurationSetting {
  let gridSize: Int
  let wordsCount: Int
  let validDirections: Set<Direction>
}

@Observable final class NewGameSelectionViewModel {
  enum Difficulty: String {
    case veryEasy = "Very Easy"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case veryHard = "Very Hard"
  }
  var selectedDifficulty: Difficulty = .easy
  let availableDifficulties: [Difficulty] = [.easy, .medium, .hard]
  private let onStartGameCallback: (GameConfigurationSetting) -> Void

  init(onStartGame: @escaping (GameConfigurationSetting) -> Void) {
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
      wordsCount: 3,
      validDirections: Directions.veryEasy
    ),
    .easy: GameConfigurationSetting(
      gridSize: 6,
      wordsCount: 4,
      validDirections: Directions.easy
    ),
    .medium: GameConfigurationSetting(
      gridSize: 10,
      wordsCount: 15,
      validDirections: Directions.medium
    ),
    .hard: GameConfigurationSetting(
      gridSize: 12,
      wordsCount: 20,
      validDirections: Directions.hard
    ),
    .veryHard: GameConfigurationSetting(
      gridSize: 16,
      wordsCount: 30,
      validDirections: Directions.veryHard
    ),
  ]

  func startGame() {
    onStartGameCallback(selectedDifficultyGameConfig)
  }
}
