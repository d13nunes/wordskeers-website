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

  case appStarted
  case appActive
  case appInactive
  case appBackgrounded
  case appUnknown
}

enum AnalyticsParams: String {
  case gridSize = "grid_size"
  case wordCount = "word_count"
  case timeSpent = "time_spent"
  case wordLength = "word_length"
  case wordsLeft = "words_left"
}

struct AnalyticsParamsCreator {
  static func gameState(
    config: GameConfiguration,
    wordsLeft: Int,
    timeElapsed: TimeInterval
  ) -> [String: Any] {
    return [
      AnalyticsParams.gridSize.rawValue: config.gridSize,
      AnalyticsParams.wordCount.rawValue: config.words.count,
      AnalyticsParams.timeSpent.rawValue: timeElapsed,
      AnalyticsParams.wordsLeft.rawValue: wordsLeft,
    ]
  }

  static func wordFound(
    config: GameConfiguration,
    word: String,
    wordsLeft: Int,
    timeElapsed: TimeInterval
  ) -> [String: Any] {
    return [
      AnalyticsParams.gridSize.rawValue: config.gridSize,
      AnalyticsParams.wordCount.rawValue: config.words.count,
      AnalyticsParams.timeSpent.rawValue: timeElapsed,
      AnalyticsParams.wordsLeft.rawValue: wordsLeft,
      AnalyticsParams.wordLength.rawValue: word.count,
    ]
  }
}
