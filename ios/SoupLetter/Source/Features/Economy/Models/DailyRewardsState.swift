import Foundation
import SwiftUI

let resetTimeInterval: TimeInterval = 4 * 60 * 60  // 4 hours in seconds

/// Represents the state of the daily rewards system
@Observable class DailyRewardsState: Codable {
  /// The date when the player last claimed a daily reward
  var lastClaimDate: Date?

  /// The date when the first reward was claimed (starting the timer for reset)
  var firstRewardClaimDate: Date?

  /// The currently available rewards
  var currentRewards: [DailyReward]

  /// The ID of the reward that was selected/claimed by the player
  var selectedRewardID: UUID?

  /// Whether the player can claim a reward today
  var canClaimToday: Bool

  /// Number of rewards collected today (0-3)
  var rewardsCollectedToday: Int = 0

  var showDailyRewardsBadge: Bool {
    return canClaimToday || rewardsCollectedToday < 3
  }

  enum CodingKeys: String, CodingKey {
    case lastClaimDate, firstRewardClaimDate, currentRewards, selectedRewardID,
      rewardsCollectedToday
  }

  /// Initialize a new daily rewards state
  /// - Parameters:
  ///   - lastClaimDate: The date when the player last claimed a reward
  ///   - firstRewardClaimDate: The date when the first reward was claimed
  ///   - currentRewards: The currently available rewards
  ///   - selectedRewardID: The ID of the selected reward
  ///   - rewardsCollectedToday: Number of rewards collected today
  init(
    lastClaimDate: Date? = nil,
    firstRewardClaimDate: Date? = nil,
    currentRewards: [DailyReward] = [],
    selectedRewardID: UUID? = nil,
    rewardsCollectedToday: Int = 0
  ) {
    self.lastClaimDate = lastClaimDate
    self.firstRewardClaimDate = firstRewardClaimDate
    self.currentRewards = currentRewards
    self.selectedRewardID = selectedRewardID
    self.rewardsCollectedToday = rewardsCollectedToday
    self.canClaimToday = Self.checkCanClaimToday(lastClaimDate: lastClaimDate)
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    lastClaimDate = try container.decodeIfPresent(Date.self, forKey: .lastClaimDate)
    firstRewardClaimDate = try container.decodeIfPresent(Date.self, forKey: .firstRewardClaimDate)
    currentRewards = try container.decode([DailyReward].self, forKey: .currentRewards)
    selectedRewardID = try container.decodeIfPresent(UUID.self, forKey: .selectedRewardID)
    rewardsCollectedToday =
      try container.decodeIfPresent(Int.self, forKey: .rewardsCollectedToday) ?? 0

    // Initialize canClaimToday after other properties are set
    let decodedLastClaimDate = try container.decodeIfPresent(Date.self, forKey: .lastClaimDate)
    canClaimToday = Self.checkCanClaimToday(lastClaimDate: decodedLastClaimDate)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(lastClaimDate, forKey: .lastClaimDate)
    try container.encodeIfPresent(firstRewardClaimDate, forKey: .firstRewardClaimDate)
    try container.encode(currentRewards, forKey: .currentRewards)
    try container.encodeIfPresent(selectedRewardID, forKey: .selectedRewardID)
    try container.encode(rewardsCollectedToday, forKey: .rewardsCollectedToday)
  }

  /// Check if the player can claim a reward today
  /// - Parameter lastClaimDate: The date when the player last claimed a reward
  /// - Returns: Whether the player can claim a reward today
  static func checkCanClaimToday(lastClaimDate: Date?) -> Bool {
    guard let lastClaimDate else { return true }

    // Check if the last claim was made before today's reset time
    let calendar = Calendar.current
    let now = Date()

    // Check if the dates are different days
    return !calendar.isDate(lastClaimDate, inSameDayAs: now)
  }

  /// Refresh the claim status based on the current date
  func refreshClaimStatus() {
    canClaimToday = checkResetCollectionStage()
    print("can claim today: \(canClaimToday)")
  }

  /// Check if we need to reset the rewards collection stage based on a timer
  /// - Returns: Whether the collection stage was reset
  func checkResetCollectionStage() -> Bool {
    var needsReset = true
    if let firstRewardDate = firstRewardClaimDate {
      // Check if it's been more than 4 hours since the first reward was claimed
      let now = Date()
      let timeInterval = now.timeIntervalSince(firstRewardDate)
      let resetTimeInterval: TimeInterval = resetTimeInterval

      needsReset = timeInterval >= resetTimeInterval
    }
    if needsReset {
      // Reset collection stage
      rewardsCollectedToday = 0
      firstRewardClaimDate = nil
      return true
    }

    return false
  }
}
