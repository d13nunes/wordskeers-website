import Foundation
import SwiftUI

/// ViewModel for the daily rewards screen
@Observable
class DailyRewardsViewModel {
  /// The daily rewards service
  private let rewardsService: DailyRewardsService

  /// Loading state for ad viewing
  var isLoading = false

  /// Whether to show the ad success message
  var showAdSuccess = false

  /// Whether to show the ad error message
  var showAdError = false

  /// Whether to show notification permission success message
  var showNotificationSuccess = false

  /// Whether to show notification permission error message
  var showNotificationError = false

  /// Whether to show the settings prompt message
  var showSettingsPrompt = false

  /// Whether to show the coins toast animation
  var showCoinsToast = false

  /// Amount of coins to show in the toast
  var coinsToastAmount = 0

  /// Timer for updating the countdown
  private var timer: Timer?

  /// Formatted time until next reward is available
  private(set) var timeUntilNextReward: String = ""

  /// Whether notifications are currently enabled
  private(set) var areNotificationsEnabled: Bool = false

  /// Whether we should show the notifications button
  private(set) var shouldShowNotificationsButton: Bool = false

  /// Access to the rewards state
  var rewardsState: DailyRewardsState {
    rewardsService.rewardsState
  }

  /// Initialize the view model
  /// - Parameter rewardsService: The daily rewards service
  init(rewardsService: DailyRewardsService) {
    self.rewardsService = rewardsService
  }

  /// Called when the view appears
  @MainActor
  func onAppear() {
    rewardsService.refreshDailyRewards()
    analytics.trackEvent(.dailyRewardsOpened)
    startTimer()
    checkNotificationStatus()
  }

  /// Called when the view disappears
  @MainActor
  func onDisappear() {
    stopTimer()
  }

  /// Check if notifications are enabled and update UI state
  @MainActor
  private func checkNotificationStatus() {
    Task {
      areNotificationsEnabled = await rewardsService.areNotificationsEnabled()

      // Only show notifications button if notifications aren't enabled
      // and at least one reward has been collected
      updateNotificationButtonVisibility()
    }
  }

  /// Update the visibility of the notification button based on current state
  @MainActor
  private func updateNotificationButtonVisibility() {
    // Only show the button if:
    // 1. At least one reward has been collected
    // 2. Notifications are not currently enabled
    shouldShowNotificationsButton =
      rewardsState.rewardsCollectedToday > 0 && !areNotificationsEnabled
  }

  /// Start a timer to update the countdown
  @MainActor
  private func startTimer() {
    stopTimer()
    updateTimeUntilNextReward()

    // Create a timer that updates every second
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.updateTimeUntilNextReward()
    }

    // Make sure the timer continues even when scrolling
    RunLoop.current.add(timer!, forMode: .common)
  }

  /// Stop the timer
  @MainActor
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  /// Update the formatted time until next reward
  @MainActor
  private func updateTimeUntilNextReward() {
    timeUntilNextReward = rewardsService.getTimeUntilNextReward()
  }

  /// Claim a specific reward
  /// - Parameter id: The ID of the reward to claim
  @MainActor
  func claimReward(with id: UUID) {
    // Try to find the reward first
    guard let reward = rewardsState.currentRewards.first(where: { $0.id == id }) else {
      return
    }

    // If the reward requires an ad, we need to handle it differently
    if reward.requiresAd {
      Task {
        await claimRewardWithAd(with: id)
      }
      return
    }

    // For free rewards, just claim directly
    let success = rewardsService.claimReward(with: id)

    if success {
      // Show coins toast animation
      showCoinsToastForReward(reward)
    }

    // Update timer immediately after claiming
    updateTimeUntilNextReward()

    // Update notification button visibility since a reward was claimed
    updateNotificationButtonVisibility()
  }

  /// Claim a reward that requires watching an ad
  /// - Parameter id: The ID of the reward to claim
  @MainActor
  private func claimRewardWithAd(with id: UUID) async {
    guard let viewController = UIApplication.shared.rootViewController() else {
      showAdError = true
      return
    }

    guard let reward = rewardsState.currentRewards.first(where: { $0.id == id }) else {
      return
    }

    isLoading = true

    let result = await rewardsService.claimRewardWithAd(with: id, on: viewController)

    isLoading = false

    if result {
      // Skip the ad success dialog in favor of the coins toast
      // showAdSuccess = true

      // Show coins toast animation instead
      showCoinsToastForReward(reward)

      updateTimeUntilNextReward()
      updateNotificationButtonVisibility()
    } else {
      showAdError = true
    }
  }

  /// Display the coins toast animation for a claimed reward
  /// - Parameter reward: The claimed reward
  @MainActor
  private func showCoinsToastForReward(_ reward: DailyReward) {
    coinsToastAmount = reward.coins
    showCoinsToast = true
  }

  /// Schedule a notification for when the next reward is available
  @MainActor
  func scheduleNextRewardNotification() async {
    // First check if notifications are enabled
    let notificationsEnabled = await rewardsService.areNotificationsEnabled()

    if !notificationsEnabled {
      // Request permissions if not enabled
      let permissionGranted = await rewardsService.requestNotificationPermission()

      if permissionGranted {
        // Success - schedule the notification
        let scheduledSuccess = await rewardsService.scheduleNextRewardNotification()
        areNotificationsEnabled = true
        updateNotificationButtonVisibility()

        if scheduledSuccess {
          showNotificationSuccess = true
        } else {
          showNotificationError = true
        }
      } else {
        // Permission denied, prompt to settings
        showSettingsPrompt = true
      }
    } else {
      // Notifications are already enabled, just schedule
      let success = await rewardsService.scheduleNextRewardNotification()

      if success {
        showNotificationSuccess = true
      } else {
        showNotificationError = true
      }
    }
  }

  /// Open the app settings to enable notifications
  func openAppSettings() {
    rewardsService.openAppSettings()
  }

  /// Get the calculated next reward date
  var nextRewardDate: Date {
    rewardsService.calculateNextRewardDate()
  }

  // MARK: - Helpers

  /// Get the analytics service
  private var analytics: AnalyticsService {
    rewardsService.analytics
  }
}
