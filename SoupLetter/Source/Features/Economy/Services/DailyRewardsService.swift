import Foundation
import SwiftUI
import UserNotifications

/// Service responsible for managing daily rewards
@Observable class DailyRewardsService {
  /// Key for UserDefaults storage
  private let dailyRewardsStateKey = "daily_rewards_state"

  /// The current state of daily rewards
  private(set) var rewardsState: DailyRewardsState

  /// The player's wallet
  private let wallet: Wallet

  /// The ad manager for rewarded videos
  private let adManager: AdManaging

  /// The notification service for scheduling notifications
  private let notificationService: NotificationService

  /// The analytics service for tracking events
  let analytics: AnalyticsService

  /// The UserDefaults store
  private let userDefaults: UserDefaults

  /// Key for last claimed reward timestamp
  private let lastClaimTimestampKey = "lastClaimTimestamp"

  /// Key for selected reward ID
  private let selectedRewardIDKey = "selectedRewardID"

  /// Key for if the reward has been doubled
  private let doubledWithAdKey = "doubledWithAd"

  /// Initialize the daily rewards service
  /// - Parameters:
  ///   - wallet: The player's wallet
  ///   - adManager: The ad manager for rewarded videos
  ///   - analytics: The analytics service
  ///   - notificationService: The notification service for scheduling notifications
  ///   - userDefaults: The UserDefaults store
  init(
    wallet: Wallet,
    adManager: AdManaging,
    analytics: AnalyticsService,
    notificationService: NotificationService = NotificationService(),
    userDefaults: UserDefaults = .standard
  ) {
    self.wallet = wallet
    self.adManager = adManager
    self.analytics = analytics
    self.notificationService = notificationService
    self.userDefaults = userDefaults

    // Initialize the rewards state after other properties
    let loadedState = Self.loadRewardsState(from: dailyRewardsStateKey)
    self.rewardsState = loadedState ?? DailyRewardsState()
  }

  /// Generate random daily rewards for the player to choose from
  /// - Returns: Array of three random daily rewards
  func generateDailyRewards() -> [DailyReward] {
    // Generate 3 mystery coin rewards with random values
    return [
      createRandomReward(),
      createRandomReward(),
      createRandomReward(),
    ]
  }

  /// Create a random reward with coin values in different tiers
  /// - Returns: A daily reward with random coin value
  private func createRandomReward() -> DailyReward {
    // Generate random coin values in different tiers
    let tiers = [
      50...100,  // Small reward
      100...200,  // Medium reward
      200...300,  // Large reward
    ]

    let selectedTier = tiers.randomElement() ?? (50...100)
    let coinValue = Int.random(in: selectedTier)

    return DailyReward(coins: coinValue)
  }

  /// Refresh the daily rewards state
  /// Generate new rewards if needed and check if the player can claim today
  func refreshDailyRewards() {
    rewardsState.refreshClaimStatus()

    if rewardsState.canClaimToday && rewardsState.currentRewards.isEmpty {
      rewardsState.currentRewards = generateDailyRewards()
      saveRewardsState()
    }
  }

  /// Calculate the date when the next reward will be available
  /// - Returns: The date when the next reward will be available
  func calculateNextRewardDate() -> Date {
    let calendar = Calendar.current

    // If no claim date yet, the reward is available now
    guard let lastClaimDate = rewardsState.lastClaimDate else {
      return Date()
    }

    // Calculate the start of the next day (midnight)
    guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: lastClaimDate) else {
      return Date()
    }

    return calendar.startOfDay(for: tomorrow)
  }

  /// Schedule a notification for when the next reward will be available
  /// - Returns: Whether the notification was scheduled successfully
  @discardableResult
  func scheduleNextRewardNotification() async -> Bool {
    let nextRewardDate = calculateNextRewardDate()

    // Don't schedule if the date is in the past or too soon
    let now = Date()
    if nextRewardDate.timeIntervalSince(now) < 60 {  // less than a minute
      return false
    }

    return await notificationService.scheduleNextRewardNotification(at: nextRewardDate)
  }

  /// Claim a specific reward
  /// - Parameter id: The ID of the reward to claim
  /// - Returns: Whether the claim was successful
  @discardableResult
  func claimReward(with id: UUID) -> Bool {
    guard rewardsState.canClaimToday,
      let index = rewardsState.currentRewards.firstIndex(where: { $0.id == id })
    else {
      return false
    }

    // Mark the reward as claimed
    rewardsState.currentRewards[index].claimed = true
    rewardsState.selectedRewardID = id
    rewardsState.lastClaimDate = Date()
    rewardsState.canClaimToday = false

    // Save to persistence
    saveRewardsState()

    // Apply the reward to the player's wallet
    let reward = rewardsState.currentRewards[index]
    wallet.addCoins(reward.coins)

    // Track analytics
    analytics.trackEvent(.dailyRewardClaimed(coins: reward.coins))

    // Schedule notification for next reward
    Task {
      await scheduleNextRewardNotification()
    }

    return true
  }

  /// Double the reward by watching an ad
  /// - Parameter viewController: The view controller to present the ad on
  /// - Returns: Whether the reward was successfully doubled
  @MainActor
  func doubleRewardWithAd(on viewController: UIViewController) async -> Bool {
    guard let selectedID = rewardsState.selectedRewardID,
      let index = rewardsState.currentRewards.firstIndex(where: { $0.id == selectedID }),
      rewardsState.currentRewards[index].claimed,
      !rewardsState.currentRewards[index].doubledWithAd
    else {
      return false
    }

    // Show rewarded ad
    let adResult = await adManager.showRewardedAd(on: viewController)

    if adResult {
      // Double the reward
      let reward = rewardsState.currentRewards[index]
      reward.doubledWithAd = true

      // Apply the additional coins (doubling the original amount)
      wallet.addCoins(reward.coins)

      // Save updated state
      saveRewardsState()

      // Track analytics
      analytics.trackEvent(.dailyRewardDoubled(coins: reward.coins))

      return true
    }

    return false
  }

  /// Get the time until the next reward is available
  /// - Returns: Formatted string showing time until next reward
  func getTimeUntilNextReward() -> String {
    guard let lastClaimDate = rewardsState.lastClaimDate else {
      return "Available now!"
    }

    let calendar = Calendar.current
    let now = Date()

    // Find the start of tomorrow
    guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: lastClaimDate),
      let startOfTomorrow = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)
    else {
      return "Available soon"
    }

    // If we're past the reset time (midnight), reward should be available
    if now >= startOfTomorrow {
      return "Available now!"
    }

    let components = calendar.dateComponents(
      [.hour, .minute, .second], from: now, to: startOfTomorrow)

    if let hours = components.hour, let minutes = components.minute, let seconds = components.second
    {
      // Different formatting depending on time remaining
      if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
      } else if minutes > 0 {
        return String(format: "%02d:%02d", minutes, seconds)
      } else {
        return String(format: "%d seconds", seconds)
      }
    }

    return "Available soon"
  }

  // MARK: - Persistence

  /// Save the rewards state to UserDefaults
  private func saveRewardsState() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(rewardsState) {
      UserDefaults.standard.set(encoded, forKey: dailyRewardsStateKey)
    }
  }

  /// Load the rewards state from UserDefaults
  /// - Returns: The loaded rewards state, or nil if none exists
  private static func loadRewardsState(from key: String) -> DailyRewardsState? {
    guard let data = UserDefaults.standard.data(forKey: key) else {
      return nil
    }

    let decoder = JSONDecoder()
    if let decoded = try? decoder.decode(DailyRewardsState.self, from: data) {
      // Check if we need to refresh the claim status
      decoded.refreshClaimStatus()
      return decoded
    }

    return nil
  }

  /// Load the rewards state from UserDefaults
  /// - Returns: The loaded rewards state, or nil if none exists
  private func loadRewardsState() -> DailyRewardsState? {
    return Self.loadRewardsState(from: dailyRewardsStateKey)
  }
}
