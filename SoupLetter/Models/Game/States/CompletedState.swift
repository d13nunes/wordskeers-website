import Foundation

/// State representing a completed game level
final class CompletedState: SoupLetter.GameStateProtocol {
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    default:
      manager.resetGameState()
      return .playing(PlayingState(manager: manager))
    }
  }

  func enter() {}
  func exit() {}
}
