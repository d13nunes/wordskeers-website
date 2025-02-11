import Foundation

/// State representing a paused game
final class PausedState: GameStateProtocol {
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .resume: return .playing(PlayingState(manager: manager))
    default: return nil
    }
  }

  func enter() {}
  func exit() {}
}
