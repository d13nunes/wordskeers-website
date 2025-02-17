// MARK: - AdState

/// Represents the current state of the ad
enum AdState: Equatable {
  case notLoaded
  case loading
  case loaded
  case presenting
  case error(Error)

  static func == (lhs: AdState, rhs: AdState) -> Bool {
    switch (lhs, rhs) {
    case (.notLoaded, .notLoaded): return true
    case (.loading, .loading): return true
    case (.loaded, .loaded): return true
    case (.presenting, .presenting): return true
    case (.error, .error): return true
    default: return false
    }
  }
}
