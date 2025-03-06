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
    Array(DifficultyConfigMap.config(for: selectedDifficulty).validDirections)
  }

  var selectedGridSize: Int {
    DifficultyConfigMap.config(for: selectedDifficulty).gridSize
  }

  var selectedWordsCount: Int {
    DifficultyConfigMap.config(for: selectedDifficulty).wordsCount
  }

  var selectedDifficultyGameConfig: GameConfigurationSetting {
    DifficultyConfigMap.config(for: selectedDifficulty)
  }

  func startGame() {
    onStartGameCallback(selectedDifficulty)
  }
}
