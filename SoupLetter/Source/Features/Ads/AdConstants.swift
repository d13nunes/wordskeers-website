import Foundation

/// Constants related to advertisements
enum AdConstants {
  /// Ad unit IDs for different ad formats
  enum UnitID {
    #if DEBUG
      /// Test interstitial ad unit ID for development
      static let interstitial = "ca-app-pub-3940256099942544/4411468910"
      static let rewarded = "ca-app-pub-3940256099942544/1712485313"
      static let banner = "ca-app-pub-3940256099942544/2934735716"
      static let rewardedInterstitial = "ca-app-pub-3940256099942544/6978759866"
    #else
      /// Production interstitial ad unit ID
      static let interstitial = "ca-app-pub-2232295072431002/3832920916"
      static let rewarded = "ca-app-pub-2232295072431002/2715920992"
      static let banner = "ca-app-pub-2232295072431002/9508893193"
      static let rewardedInterstitial = "ca-app-pub-2232295072431002/9107348180"
    #endif
  }

  /// Configuration for when to show ads
  enum Frequency {
    /// Minimum time between interstitial ads (in seconds)
    static let minimumInterval: TimeInterval = 30  // 30 seconds

    /// Minimum time between rewarded interstitial ads (in seconds)
    static let minimumRewardedInterstitialInterval: TimeInterval = 30  // 30 seconds

    /// Number of game completions before showing an ad
    static let gameCompletionsBeforeAd = 3
  }

  enum RewardedVideoLocation {
    case store
    case dailyReward
  }
}
