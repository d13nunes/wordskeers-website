import Foundation

/// State representing active gameplay
final class PlayingState: GameStateProtocol {
  private weak var manager: GameStateManager?

  init(manager: GameStateManager?) {
    self.manager = manager
  }

  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState? {
    switch event {
    case .pause: return .paused(PausedState())
    case .complete: return .completed(CompletedState())
    default: return nil
    }
  }

  func enter() {
    manager?.startTimer()
  }

  func exit() {
    manager?.stopTimer()
  }
}
