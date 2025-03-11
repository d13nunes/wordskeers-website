import Foundation
import SwiftUI

/// Represents the state of the daily rewards system
@Observable class DailyRewardsState: Codable {
  /// The date when the player last claimed a daily reward
  var lastClaimDate: Date?

  /// The currently available rewards
  var currentRewards: [DailyReward]

  /// The ID of the reward that was selected/claimed by the player
  var selectedRewardID: UUID?

  /// Whether the player can claim a reward today
  var canClaimToday: Bool

  enum CodingKeys: String, CodingKey {
    case lastClaimDate, currentRewards, selectedRewardID
  }

  /// Initialize a new daily rewards state
  /// - Parameters:
  ///   - lastClaimDate: The date when the player last claimed a reward
  ///   - currentRewards: The currently available rewards
  ///   - selectedRewardID: The ID of the selected reward
  init(
    lastClaimDate: Date? = nil,
    currentRewards: [DailyReward] = [],
    selectedRewardID: UUID? = nil
  ) {
    self.lastClaimDate = lastClaimDate
    self.currentRewards = currentRewards
    self.selectedRewardID = selectedRewardID
    self.canClaimToday = Self.checkCanClaimToday(lastClaimDate: lastClaimDate)
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    lastClaimDate = try container.decodeIfPresent(Date.self, forKey: .lastClaimDate)
    currentRewards = try container.decode([DailyReward].self, forKey: .currentRewards)
    selectedRewardID = try container.decodeIfPresent(UUID.self, forKey: .selectedRewardID)

    // Initialize canClaimToday after other properties are set
    let decodedLastClaimDate = try container.decodeIfPresent(Date.self, forKey: .lastClaimDate)
    canClaimToday = Self.checkCanClaimToday(lastClaimDate: decodedLastClaimDate)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(lastClaimDate, forKey: .lastClaimDate)
    try container.encode(currentRewards, forKey: .currentRewards)
    try container.encodeIfPresent(selectedRewardID, forKey: .selectedRewardID)
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
    canClaimToday = Self.checkCanClaimToday(lastClaimDate: lastClaimDate)
  }
}
