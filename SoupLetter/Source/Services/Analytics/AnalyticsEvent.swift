import Foundation

/// Constants for analytics event names and parameters
public enum AnalyticsEvent: String {
  // MARK: - Event Names
  case gameStarted = "game_started"
  case gamePaused = "game_paused"
  case gameResumed = "game_resumed"
  case gameQuit = "game_quit"
  case gameCompleted = "game_completed"
  case gameWordFound = "game_word_found"
  case gameHintUsed = "game_hint_used"

  // MARK: - Ad Events
  case adMobInitializing = "ad_init_started"
  case adMobInitializedSuccessfully = "ad_init_succeeded"
  case adMobInitializationFailed = "ad_init_failed"

  case adInterstitialRequested = "ad_interstitial_requested"
  case adInterstitialImpression = "ad_interstitial_impression"
  case adInterstitialFailed = "ad_interstitial_failed"
  case adInterstitialClosed = "ad_interstitial_closed"

  case adRewardedRequested = "ad_rewarded_requested"
  case adRewardedImpression = "ad_rewarded_impression"
  case adRewardedFailed = "ad_rewarded_failed"
  case adRewardedCompleted = "ad_rewarded_completed"
  case adRewardedClosed = "ad_rewarded_closed"

  // MARK: - App Events
  case appStarted = "app_started"
  case appActive = "app_active"
  case appInactive = "app_inactive"
  case appBackgrounded = "app_backgrounded"
  case appUnknown = "app_unknown"
}

enum AnalyticsParams: String {
  case gridSize = "grid_size"
  case wordCount = "word_count"
  case timeSpent = "time_spent"
  case wordLength = "word_length"
  case wordsLeft = "words_left"

  // MARK: - Ad Parameters
  case gridId = "grid_id"
  case adType = "ad_type"
  case adLocation = "ad_location"
  case errorReason = "error_reason"
  case rewardGranted = "reward_granted"
}

struct AnalyticsParamsCreator {
  static func gameState(
    gridId: Int64,
    config: GameConfiguration,
    wordsLeft: Int,
    timeElapsed: TimeInterval
  ) -> [String: Any] {
    return [
      AnalyticsParams.gridId.rawValue: gridId,
      AnalyticsParams.gridSize.rawValue: config.gridSize,
      AnalyticsParams.wordCount.rawValue: config.words.count,
      AnalyticsParams.timeSpent.rawValue: timeElapsed,
      AnalyticsParams.wordsLeft.rawValue: wordsLeft,
    ]
  }

  static func wordFound(
    gridId: Int64,
    config: GameConfiguration,
    word: String,
    wordsLeft: Int,
    timeElapsed: TimeInterval
  ) -> [String: Any] {
    return [
      AnalyticsParams.gridId.rawValue: gridId,
      AnalyticsParams.gridSize.rawValue: config.gridSize,
      AnalyticsParams.wordCount.rawValue: config.words.count,
      AnalyticsParams.timeSpent.rawValue: timeElapsed,
      AnalyticsParams.wordsLeft.rawValue: wordsLeft,
      AnalyticsParams.wordLength.rawValue: word.count,
    ]
  }

  // MARK: - Ad Analytics
  static func adEvent(
    adType: String,
    location: String,
    errorReason: String? = nil,
    rewardGranted: Bool? = nil
  ) -> [String: Any] {
    var params: [String: Any] = [
      AnalyticsParams.adType.rawValue: adType,
      AnalyticsParams.adLocation.rawValue: location,
    ]

    if let errorReason {
      params[AnalyticsParams.errorReason.rawValue] = errorReason
    }

    if let rewardGranted {
      params[AnalyticsParams.rewardGranted.rawValue] = rewardGranted
    }

    return params
  }
}
