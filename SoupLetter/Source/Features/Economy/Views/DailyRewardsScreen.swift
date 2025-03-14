import SwiftUI

/// Screen for displaying and interacting with daily rewards
struct DailyRewardsView: View {
  /// The view model
  @Bindable private var viewModel: DailyRewardsViewModel

  /// Initialize the screen
  /// - Parameter viewModel: The view model
  init(viewModel: DailyRewardsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      // Background
      Color(.systemGroupedBackground)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        // Header
        Text("Daily Rewards")
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding(.top)

        if viewModel.rewardsState.rewardsCollectedToday >= 3 {
          // All rewards collected
          allRewardsCollectedView
        } else if viewModel.rewardsState.currentRewards.isEmpty {
          // No rewards available yet
          waitingForNextRewardView
        } else {
          // Show available rewards
          availableRewardsView
        }

        Spacer()
      }
      .padding()

      CoinsToastView(
        coinAmount: viewModel.coinsToastAmount,
        isVisible: $viewModel.showCoinsToast
      )
    }
    // .coinToast(
    //   isPresented: $viewModel.showCoinsToast,
    //   coinAmount: viewModel.coinsToastAmount
    // )
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.onAppear()
    }
    .onDisappear {
      viewModel.onDisappear()
    }
    .alert("Reward Collected!", isPresented: $viewModel.showAdSuccess) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("You've successfully claimed your reward!")
    }
    .alert("Failed to show ad", isPresented: $viewModel.showAdError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Please try again later.")
    }
    .alert("Notification Scheduled!", isPresented: $viewModel.showNotificationSuccess) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("We'll notify you when your next reward is ready.")
    }
    .alert("Notification Error", isPresented: $viewModel.showNotificationError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Please make sure notifications are allowed for this app in your device settings.")
    }
    .alert("Enable Notifications", isPresented: $viewModel.showSettingsPrompt) {
      Button("Cancel", role: .cancel) {}
      Button("Settings") {
        viewModel.openAppSettings()
      }
    } message: {
      Text("Please enable notifications in your device settings to receive reminders.")
    }
  }

  /// View displaying available rewards to claim
  private var availableRewardsView: some View {
    VStack(spacing: 24) {
      Text("Collect your daily rewards!")
        .font(.headline)
        .padding(.bottom)

      HStack(spacing: 16) {
        ForEach(viewModel.rewardsState.currentRewards) { reward in
          rewardView(reward)
        }
      }
      .padding(.horizontal)

      // Next reward countdown if at least one reward was collected
      if viewModel.rewardsState.rewardsCollectedToday > 0 {
        VStack(spacing: 12) {
          HStack {
            Image(systemName: "clock.fill")
              .foregroundColor(.blue)
            Text("Collection resets in:")
              .font(.headline)
          }
          Text(viewModel.timeUntilNextReward)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundColor(.blue)
            .frame(height: 30)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
          RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(0.8))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Collection resets in \(viewModel.timeUntilNextReward)")
      }

      // Notification reminder button - only show after first reward is collected and if notifications aren't enabled
      if viewModel.shouldShowNotificationsButton {
        Button {
          Task {
            await viewModel.scheduleNextRewardNotification()
          }
        } label: {
          HStack {
            Image(systemName: "bell.fill")
            Text("Remind Me When Ready")
          }
          .frame(minWidth: 200)
          .padding()
          .background(
            Capsule()
              .fill(Color.blue.opacity(0.2))
          )
          .foregroundColor(.blue)
          .fontWeight(.medium)
        }
        .padding(.top, 8)
        .accessibilityLabel("Schedule a notification for when your next reward is ready")
      }
    }
  }

  /// View for a single reward option
  private func rewardView(_ reward: DailyReward) -> some View {
    VStack {
      // Different appearance based on reward status
      if reward.claimed {
        // Claimed reward
        getRewardView(
          rewardId: reward.id,
          iconName: "checkmark.circle.fill",
          iconColor: .green,
          buttonText: nil,
          buttonColor: .green.opacity(0.2),
          isButtonDisabled: true,
          accessibilityLabel: "Reward of \(reward.coins) coins collected"
        )
      } else if reward.requiresAd && viewModel.rewardsState.rewardsCollectedToday == 0 {
        // Ad reward that can't be claimed yet (first reward not claimed)
        getRewardView(
          rewardId: reward.id,
          iconName: "lock.fill",
          iconColor: .gray,
          buttonText: nil,
          buttonColor: .gray.opacity(0.2),
          isButtonDisabled: true,
          accessibilityLabel: "Locked reward. Collect the first reward to unlock"
        )
      } else {
        // Claimable reward
        getRewardView(
          rewardId: reward.id,
          iconName: reward.requiresAd ? "video.fill" : "gift.fill",
          iconColor: reward.requiresAd ? .green : .red,
          buttonText: reward.requiresAd ? "Watch Ad" : "Collect",
          buttonColor: reward.requiresAd ? Color.green : Color.blue,
          isButtonDisabled: false,
          accessibilityLabel: reward.requiresAd
            ? "Reward box. Tap to watch ad and claim"
            : "Free reward box. Tap to claim"
        )
      }
    }
    .frame(width: 100, height: 120)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    )
  }

  private func getRewardView(
    rewardId: UUID,
    iconName: String,
    iconColor: Color,
    buttonText: String?,
    buttonColor: Color,
    isButtonDisabled: Bool,
    accessibilityLabel: String
  ) -> some View {
    return Button {
      viewModel.claimReward(with: rewardId)
    } label: {
      VStack {
        Spacer()
        Image(systemName: iconName)
          .font(.system(size: 48))
          .foregroundColor(iconColor)
        Spacer()
        if let buttonText = buttonText {
          HStack {
            Spacer()
            Text(buttonText)
              .font(.caption2)
              .foregroundStyle(.white)
              .multilineTextAlignment(.center)
              .padding(.vertical, 8)
            Spacer()
          }
          .customButtonBackground(color: buttonColor)
          .padding(.horizontal, 8)
          .padding(.bottom, 8)
        }
      }
    }
    .disabled(isButtonDisabled)
    .buttonStyle(.plain)
    .sensoryFeedback(.impact, trigger: true)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityLabel)
  }

  /// View displaying when all rewards have been collected
  private var allRewardsCollectedView: some View {
    return VStack(spacing: 24) {
      Image(systemName: "trophy.fill")
        .font(.system(size: 70))
        .foregroundStyle(.yellow)
        .padding(.bottom, 8)

      Text("All Rewards Collected!")
        .font(.title3)
        .fontWeight(.bold)

      Text("Come back in:")
        .font(.headline)

      Text(viewModel.timeUntilNextReward)
        .font(.system(size: 40, weight: .bold, design: .monospaced))
        .foregroundColor(.blue)
        .minimumScaleFactor(0.5)
        .padding(.horizontal)

      HStack {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
        Text("You've claimed all available rewards")
      }
      .font(.callout)
      .padding(.top, 8)

      // Notification reminder button if needed
      if viewModel.shouldShowNotificationsButton {
        Button {
          Task {
            await viewModel.scheduleNextRewardNotification()
          }
        } label: {
          HStack {
            Image(systemName: "bell.fill")
            Text("Remind Me When Ready")
          }
          .frame(minWidth: 220)
          .padding()
          .background(
            Capsule()
              .fill(Color.blue.opacity(0.2))
          )
          .foregroundColor(.blue)
          .fontWeight(.medium)
        }
        .padding(.top, 16)
        .accessibilityLabel("Schedule a notification for when your next reward is ready")
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    )
    .padding(.horizontal)
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "All rewards collected. Next rewards available in \(viewModel.timeUntilNextReward)")
  }

  /// View displaying countdown until next reward is available
  private var waitingForNextRewardView: some View {
    VStack(spacing: 20) {
      Image(systemName: "calendar.badge.clock")
        .font(.system(size: 70))
        .symbolRenderingMode(.multicolor)
        .foregroundStyle(.blue, .red)
        .padding(.bottom, 8)

      Text("Next reward available in:")
        .font(.headline)

      Text(viewModel.timeUntilNextReward)
        .font(.system(size: 40, weight: .bold, design: .monospaced))
        .foregroundColor(.blue)
        .minimumScaleFactor(0.5)
        .padding(.horizontal)

      HStack {
        Image(systemName: "hourglass")
          .symbolEffect(.pulse, options: .repeating)
        Text("Come back soon for your rewards!")
      }
      .font(.callout)
      .foregroundColor(.secondary)
      .padding(.top, 8)

      // Notification reminder button if needed
      if viewModel.shouldShowNotificationsButton {
        Button {
          Task {
            await viewModel.scheduleNextRewardNotification()
          }
        } label: {
          HStack {
            Image(systemName: "bell.fill")
            Text("Remind Me When Ready")
          }
          .frame(minWidth: 220)
          .padding()
          .background(
            Capsule()
              .fill(Color.blue.opacity(0.2))
          )
          .foregroundColor(.blue)
          .fontWeight(.medium)
        }
        .padding(.top, 16)
        .accessibilityLabel("Schedule a notification for when your next reward is ready")
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    )
    .padding(.horizontal)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("Next reward available in \(viewModel.timeUntilNextReward)")
  }
}

#if DEBUG
  struct DailyRewardsView_Previews: PreviewProvider {
    static let dailyRewardsService = DailyRewardsService(
      wallet: Wallet.forTesting(),
      adManager: MockAdManager(),
      analytics: ConsoleAnalyticsManager(),
      notificationService: MockNotificationService()
    )
    static var previews: some View {
      NavigationStack {
        Button("reset") {
          dailyRewardsService.reset()
        }
        DailyRewardsView(
          viewModel: DailyRewardsViewModel(
            rewardsService: dailyRewardsService
          )
        )
      }
    }
  }
#endif
