import Foundation

/// State representing the game loading phase
final class LoadingState: GameStateProtocol {
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .start: return .playing(PlayingState(manager: manager))
    default: return nil
    }
  }

  func enter() {}
  func exit() {}
}
