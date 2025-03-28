import Foundation
import SwiftUI
import UserNotifications

/// Service responsible for managing daily rewards
@Observable
class DailyRewardsService {
  /// Key for UserDefaults storage
  private let dailyRewardsStateKey = "daily_rewards_state"

  /// The current state of daily rewards
  private(set) var rewardsState: DailyRewardsState

  /// The player's wallet
  let wallet: Wallet

  /// The ad manager for rewarded videos
  private let adManager: AdManaging

  /// The notification service for scheduling notifications
  private let notificationService: NotificationServicing

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

  /// Whether to show the daily rewards badge
  var showDailyRewardsBadge: Bool {
    rewardsState.showDailyRewardsBadge
  }

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
    notificationService: NotificationServicing = NotificationService(),
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
    // Generate 3 rewards with the first one being free and the others requiring ads
    let tiers = [
      10...50,  // Small reward
      50...100,  // Medium reward
      100...200,  // Large reward
    ]
    return [
      createRandomReward(requiresAd: false, tier: tiers[0]),
      createRandomReward(requiresAd: true, tier: tiers[1]),
      createRandomReward(requiresAd: true, tier: tiers[2]),
    ]
  }

  /// Create a random reward with coin values in different tiers
  /// - Parameter requiresAd: Whether this reward requires watching an ad to claim
  /// - Returns: A daily reward with random coin value
  private func createRandomReward(requiresAd: Bool, tier: ClosedRange<Int>) -> DailyReward {
    // Generate random coin values in different tiers
    let coinValue = Int.random(in: tier)

    return DailyReward(
      coins: coinValue,
      requiresAd: requiresAd
    )
  }

  /// Refresh the daily rewards state
  /// Generate new rewards if needed and check if the player can claim today
  func refreshDailyRewards() {
    rewardsState.refreshClaimStatus()

    // Check if we need to reset the collection stage based on timer
    let resetOccurred = rewardsState.checkResetCollectionStage()

    if rewardsState.canClaimToday && rewardsState.currentRewards.isEmpty {
      rewardsState.currentRewards = generateDailyRewards()
      saveRewardsState()
    } else if resetOccurred {
      // If a reset occurred, we need to regenerate rewards
      rewardsState.currentRewards = generateDailyRewards()
      saveRewardsState()
    }
  }

  /// Calculate the date when the next reward will be available
  /// - Returns: The date when the next reward will be available
  func calculateNextRewardDate() -> Date {
    // If there's an active collection stage timer, use that instead of the daily reset
    if let firstRewardDate = rewardsState.firstRewardClaimDate {
      // Collection stage resets after 4 hours
      return firstRewardDate.addingTimeInterval(resetTimeInterval)  // 4 hours in seconds
    }

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

  /// Check if notifications are enabled for the app
  /// - Returns: Whether notifications are enabled
  func areNotificationsEnabled() async -> Bool {
    return await notificationService.checkNotificationPermission()
  }

  /// Request notification permissions if not already granted
  /// - Returns: Whether the permissions were granted
  func requestNotificationPermission() async -> Bool {
    return await notificationService.requestNotificationPermission()
  }

  /// Open the app settings to enable notifications
  func openAppSettings() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      return
    }

    UIApplication.shared.open(settingsUrl)
  }

  /// Claim a specific reward
  /// - Parameter id: The ID of the reward to claim
  /// - Returns: Whether the claim was successful
  @discardableResult
  func claimReward(with id: UUID) -> Bool {
    guard rewardsState.canClaimToday || rewardsState.rewardsCollectedToday > 0,
      let index = rewardsState.currentRewards.firstIndex(where: { $0.id == id })
    else {
      return false
    }

    let reward = rewardsState.currentRewards[index]

    // Cannot claim rewards that require ads using this method
    if reward.requiresAd {
      return false
    }

    // Mark the reward as claimed
    rewardsState.currentRewards[index].claimed = true
    rewardsState.selectedRewardID = id
    rewardsState.lastClaimDate = Date()
    rewardsState.rewardsCollectedToday += 1

    // If this is the first reward, start the collection timer
    if rewardsState.rewardsCollectedToday == 1 {
      rewardsState.firstRewardClaimDate = Date()
    }

    // If all rewards have been collected, reset canClaimToday to false
    if rewardsState.rewardsCollectedToday >= 3 {
      rewardsState.canClaimToday = false
    }

    Task {
      let isNotificationsEnabled = await areNotificationsEnabled()
      if isNotificationsEnabled {
        await scheduleNextRewardNotification()
      }
    }

    // Save to persistence
    saveRewardsState()

    // Apply the reward to the player's wallet
    wallet.addCoins(reward.coins)

    // Track analytics
    analytics.trackEvent(.dailyRewardClaimed(coins: reward.coins))

    return true
  }

  /// Claim a reward that requires watching an ad
  /// - Parameters:
  ///   - id: The ID of the reward to claim
  ///   - viewController: The view controller to present the ad on
  /// - Returns: Whether the reward was successfully claimed
  @MainActor
  func claimRewardWithAd(with id: UUID, on viewController: UIViewController) async -> Bool {
    guard rewardsState.canClaimToday || rewardsState.rewardsCollectedToday > 0,
      let index = rewardsState.currentRewards.firstIndex(where: { $0.id == id })
    else {
      return false
    }

    let reward = rewardsState.currentRewards[index]

    // Ensure this reward requires an ad and isn't already claimed
    guard reward.requiresAd && !reward.claimed else {
      return false
    }

    // Show rewarded ad
    let adResult = await adManager.showRewardedAd(on: viewController)

    if adResult {
      // Mark the reward as claimed
      rewardsState.currentRewards[index].claimed = true
      rewardsState.selectedRewardID = id
      rewardsState.lastClaimDate = Date()
      rewardsState.rewardsCollectedToday += 1

      // If this is the first reward, start the collection timer
      if rewardsState.rewardsCollectedToday == 1 {
        rewardsState.firstRewardClaimDate = Date()
      }

      // If all rewards have been collected, reset canClaimToday to false
      if rewardsState.rewardsCollectedToday >= 3 {
        rewardsState.canClaimToday = false
      }

      // Save to persistence
      saveRewardsState()

      // Apply the reward to the player's wallet
      wallet.addCoins(reward.coins)

      // Track analytics
      analytics.trackEvent(.dailyRewardClaimed(coins: reward.coins))

      return true
    }

    return false
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
  func getTimeUntilNextReward() -> TimeComponent? {
    print("Get Time component \(rewardsState.firstRewardClaimDate)")
    // If there's an active collection stage timer, calculate time based on that
    if let firstRewardDate = rewardsState.firstRewardClaimDate {
      let resetTime = firstRewardDate.addingTimeInterval(resetTimeInterval)  // 4 hours after first reward
      let now = Date()
      // If we're past the reset time, rewards should be available
      let components = Calendar.current.dateComponents(
        [.hour, .minute, .second], from: now, to: resetTime)

      if let hours = components.hour, let minutes = components.minute,
        let seconds = components.second
      {
        // Different formatting depending on time remaining
        if hours > 0 {
          return TimeComponent(
            leftUnitValue: String(format: "%02d", hours),
            leftUnitDescription: "hours",
            rightUnitValue: String(format: "%02d", minutes),
            rightUnitDescription: "min"
          )
        }
        return TimeComponent(
          leftUnitValue: String(format: "%02d", minutes),
          leftUnitDescription: "min",
          rightUnitValue: String(format: "%02d", seconds),
          rightUnitDescription: "sec"
        )
      }
    }

    return nil
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

  func reset() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: dailyRewardsStateKey)
    rewardsState = DailyRewardsState()
    saveRewardsState()
  }
}
