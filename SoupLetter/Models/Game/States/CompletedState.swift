import Foundation

/// State representing a completed game level
final class CompletedState: SoupLetter.GameStateProtocol {
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .nextLevel:
      manager.startNextLevel()
      return .playing(PlayingState(manager: manager))
    default: return nil
    }
  }

  func enter() {}
  func exit() {}
}
