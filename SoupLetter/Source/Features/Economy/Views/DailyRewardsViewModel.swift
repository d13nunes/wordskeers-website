import Foundation
import SwiftUI

/// ViewModel for the daily rewards screen
@Observable class DailyRewardsViewModel {
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

  /// Timer for updating the countdown
  private var timer: Timer?

  /// Formatted time until next reward is available
  private(set) var timeUntilNextReward: String = ""

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
  }

  /// Called when the view disappears
  @MainActor
  func onDisappear() {
    stopTimer()
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
  func claimReward(with id: UUID) {
    rewardsService.claimReward(with: id)

    // Update timer immediately after claiming
    Task { @MainActor in
      updateTimeUntilNextReward()
    }
  }

  /// Double the reward by watching an ad
  /// - Returns: Whether the reward was successfully doubled
  @MainActor
  func doubleRewardWithAd() async {
    guard let viewController = UIApplication.shared.rootViewController() else {
      showAdError = true
      return
    }
    isLoading = true

    let result = await rewardsService.doubleRewardWithAd(on: viewController)

    if result {
      showAdSuccess = true
    } else {
      showAdError = true
    }
  }

  /// Schedule a notification for when the next reward is available
  /// - Returns: Whether the notification was scheduled successfully
  @MainActor
  func scheduleNextRewardNotification() async {
    let success = await rewardsService.scheduleNextRewardNotification()

    if success {
      showNotificationSuccess = true
    } else {
      showNotificationError = true
    }
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
