import Foundation

/// Represents possible game state transitions
enum GameEvent {
  case start
  case pause
  case resume
  case complete
  case nextLevel
}

/// Represents the current state of the game
enum GameState: Equatable {
  case loading(LoadingState)
  case playing(PlayingState)
  case paused(PausedState)
  case completed(CompletedState)

  /// Returns the underlying state object
  var state: GameStateProtocol {
    switch self {
    case .loading(let state): return state
    case .playing(let state): return state
    case .paused(let state): return state
    case .completed(let state): return state
    }
  }

  static func == (lhs: GameState, rhs: GameState) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading): return true
    case (.playing, .playing): return true
    case (.paused, .paused): return true
    case (.completed, .completed): return true
    default: return false
    }
  }
}
