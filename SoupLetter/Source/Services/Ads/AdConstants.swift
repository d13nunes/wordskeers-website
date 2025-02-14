import Foundation

/// Constants related to advertisements
enum AdConstants {
  /// Ad unit IDs for different ad formats
  enum UnitID {
    #if DEBUG
      /// Test interstitial ad unit ID for development
      static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    #else
      /// Production interstitial ad unit ID
      static let interstitial = "ca-app-pub-2232295072431002/3832920916"
    #endif
  }

  /// Configuration for when to show ads
  enum Frequency {
    /// Minimum time between interstitial ads (in seconds)
    static let minimumInterval: TimeInterval = 180  // 3 minutes

    /// Number of game completions before showing an ad
    static let gameCompletionsBeforeAd = 3
  }
}
