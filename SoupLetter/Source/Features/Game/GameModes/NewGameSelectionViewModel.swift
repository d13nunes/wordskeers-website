import Foundation
import UIKit

enum GameModeCode: Int {
  case undefined = -1
  case classicVeryEasy = 0
  case classicEasy = 1
  case classicMedium = 2
  case classicHard = 3
  case classicVeryHard = 4

  static func getCode(for mode: GameMode, difficulty: Difficulty) -> GameModeCode {
    switch mode {
    case .classic:
      switch difficulty {
      case .veryEasy: return .classicVeryEasy
      case .easy: return .classicEasy
      case .medium: return .classicMedium
      case .hard: return .classicHard
      case .veryHard: return .classicVeryHard
      }
    }
  }
}

enum GameMode: String {
  case classic
}

struct GameConfigurationSetting {
  let gridSize: Int
  let wordsCount: Int?
  let validDirections: Set<Direction>
  let gameMode: GameModeCode
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
  let isFirstGame: Bool
  private let adManager: AdManaging

  init(isFirstGame: Bool, adManager: AdManaging, onStartGame: @escaping (Difficulty) -> Void) {
    self.isFirstGame = isFirstGame
    self.adManager = adManager
    self.onStartGameCallback = onStartGame
  }

  var selectedValidDirections: [Direction] {
    Array(DifficultyConfigMap.config(for: selectedDifficulty).validDirections)
  }

  var selectedGridSize: Int {
    DifficultyConfigMap.config(for: selectedDifficulty).gridSize
  }

  var selectedWordsCount: Int? {
    DifficultyConfigMap.config(for: selectedDifficulty).wordsCount
  }

  var selectedDifficultyGameConfig: GameConfigurationSetting {
    DifficultyConfigMap.config(for: selectedDifficulty)
  }

  @MainActor
  func startGame(on viewController: UIViewController) {
    Task {
      _ = await adManager.showInterstitialAd(on: viewController)
    }
    onStartGameCallback(selectedDifficulty)
  }
}
