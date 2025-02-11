import Foundation

/// Protocol defining behavior for each game state
protocol GameStateProtocol {
  /// Handles state transitions based on events
  func handleEvent(_ event: GameEvent, manager: GameStateManager) -> GameState?

  /// Called when entering this state
  func enter()

  /// Called when exiting this state
  func exit()
}
