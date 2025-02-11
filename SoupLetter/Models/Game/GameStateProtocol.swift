import Foundation

/// Protocol defining behavior for each game state
protocol GameStateProtocol {
  /// Called when entering this state
  func enter()

  /// Called when exiting this state
  func exit()
}
