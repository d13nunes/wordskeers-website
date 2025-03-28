import SwiftUI

/// A view representing a single daily reward card
struct DailyRewardsView: View {
  /// The view model
  @State var viewModel: DailyRewardsViewModel

  /// Initializes the view with a view model
  /// - Parameter viewModel: The daily rewards view model
  init(viewModel: DailyRewardsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    VStack(spacing: 16) {
      Spacer()
      // Title
      Text("Daily Rewards")
        .font(.title)
        .fontWeight(.bold)
      BalanceBigView(wallet: viewModel.wallet)
        .padding(.horizontal, 16)
      VStack(spacing: 16) {  // Notification button if needed
        if viewModel.rewardsState.rewardsCollectedToday > 0,
          let time = viewModel.timeUntilNextReward
        {
          timerCardView(time: time)
        }
        let rewards = viewModel.rewardsState.currentRewards
        let claimedRewards = rewards.filter { $0.claimed }
        let unlockedRewards =
          viewModel.rewardsState.rewardsCollectedToday == 0
          ? rewards.filter {
            !$0.requiresAd && !$0.claimed
          }.first
          : rewards.filter {
            $0.requiresAd && !$0.claimed
          }.first

        let lockedRewards = viewModel.rewardsState.currentRewards.filter {
          $0.id != unlockedRewards?.id && $0.requiresAd && !$0.claimed
        }
        ForEach(claimedRewards) { reward in
          claimedRewardCardView(reward: reward)
        }
        ForEach(lockedRewards) { reward in
          lockedRewardCardView(reward: reward)
        }
        if let unlockedReward = unlockedRewards {
          unclaimedRewardCardView(reward: unlockedReward)
        }
        if viewModel.shouldShowNotificationsButton {
          notificationButtonView()
        }
      }
      .padding()
    }
    .overlay {
      CoinsToastView(
        coinAmount: viewModel.coinsToastAmount,
        isVisible: $viewModel.showCoinsToast
      )
    }
    .alert("Enable Notifications", isPresented: $viewModel.showSettingsPrompt) {
      Button("Cancel", role: .cancel) {}
      Button("Settings") {
        viewModel.openAppSettings()
      }
    } message: {
      Text("Please enable notifications in your device settings to receive reminders.")
    }
    .onAppear {
      viewModel.onAppear()
    }
    .onDisappear {
      viewModel.onDisappear()
    }
  }

  private func claimedRewardCardView(reward: DailyReward) -> some View {
    let ligthGreen = Color(red: 0.82, green: 0.98, blue: 0.9)
    return CardView(
      title: "\(reward.coins) coins",
      details: "Collected",
      icon: "Checked",
      iconColor: .black,
      iconBackgroundColor: ligthGreen,
      backgroundColor: Color(red: 0.98, green: 0.98, blue: 0.98),
      textColor: Color(red: 0.61, green: 0.64, blue: 0.69),
      rightContent: AnyView(
        Text("Claimed")
          .pillStyle(
            foregroundColor: Color(red: 0.06, green: 0.73, blue: 0.51),
            backgroundColor: Color(red: 0.82, green: 0.98, blue: 0.9))
      ),
      onClick: {}
    ).disabled(true)
  }

  private func unclaimedRewardCardView(reward: DailyReward) -> some View {
    let buttonText = reward.requiresAd ? "Watch Ad" : "Collect Now"
    let buttonColor = reward.requiresAd ? AppColors.green : AppColors.blue
    return CardView(
      title: "\(reward.coins) coins",
      details: "Free Coins",
      icon: "Coins",
      iconColor: .black,
      iconBackgroundColor: Color(red: 1, green: 0.95, blue: 0.78),
      backgroundColor: Color(red: 0.98, green: 0.75, blue: 0.14).opacity(0.1),
      textColor: Color(red: 0.12, green: 0.16, blue: 0.22),
      rightContent: AnyView(
        Text(buttonText)
          .pillStyle(
            foregroundColor: .white,
            backgroundColor: buttonColor.opacity(0.8)
          )
      ),
      onClick: {
        viewModel.claimReward(with: reward.id)
      }
    )
  }

  private func lockedRewardCardView(reward: DailyReward) -> some View {
    return CardView(
      title: "??? coins",
      details: "Collect other rewards",
      icon: "Lock",
      iconColor: .black,
      iconBackgroundColor: nil,
      backgroundColor: Color(red: 0.98, green: 0.98, blue: 0.98),
      textColor: Color(red: 0.61, green: 0.64, blue: 0.69),
      rightContent: AnyView(
        Text("Locked")
          .pillStyle(
            foregroundColor: Color(red: 0.61, green: 0.64, blue: 0.69),
            backgroundColor: Color(red: 0.9, green: 0.91, blue: 0.92)
          )
      ),
      onClick: {}
    ).disabled(true)
  }

  func timeText(time: String, timeUnit: String) -> some View {

    return VStack(alignment: .center, spacing: 0) {
      Text("\(time)")
        .font(.system(size: 20, weight: .bold))
        .multilineTextAlignment(.center)
        .foregroundColor(AppColors.blue)
        .monospacedDigit()
        .padding(.bottom, -2)
      Text("\(timeUnit)")
        .font(Font.custom("Inter", size: 12))
        .multilineTextAlignment(.center)
        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.5))
    }
  }

  private func timerCardView(time: TimeComponent) -> some View {
    return CardView(
      title: "Next Rewards In",
      details: "",
      icon: "Clock",
      iconColor: .black,
      iconBackgroundColor: nil,
      backgroundColor: Color(red: 0.98, green: 0.98, blue: 0.98),
      textColor: Color(red: 0.12, green: 0.16, blue: 0.22),
      rightContent: AnyView(
        HStack(spacing: 2) {
          timeText(time: time.leftUnitValue, timeUnit: time.leftUnitDescription)
          Text(":")
            .font(
              Font.custom("Inter", size: 16)
                .weight(.bold)
            )
            .foregroundColor(AppColors.blue)
            .padding(.trailing, 2)
            .blinking(duration: 1.0)
          timeText(time: time.rightUnitValue, timeUnit: time.rightUnitDescription)
        }
        .padding(.trailing, 2)
      ),
      onClick: {}
    ).disabled(true)
  }

  private func notificationButtonView() -> some View {
    return CardView(
      title: "Enable Notifications",
      details: "Get daily rewards reminders",
      icon: "Bell",
      iconColor: .black,
      iconBackgroundColor: nil,
      backgroundColor: Color(red: 0.98, green: 0.98, blue: 0.98),
      textColor: Color(red: 0.12, green: 0.16, blue: 0.22),
      rightContent: AnyView(
        Text("Enable")
          .pillStyle(
            foregroundColor: .white,
            backgroundColor: AppColors.blue
          )
      ),
      onClick: {
        Task {
          await viewModel.scheduleNextRewardNotification()
        }
      }
    )
  }
}

#if DEBUG
  // MARK: - Preview
  #Preview {
    // Create a mock ViewModel with preview data
    let service = DailyRewardsService(
      wallet: Wallet.forTesting(),
      adManager: MockAdManager(),
      analytics: ConsoleAnalyticsManager(),
      notificationService: MockNotificationService()
    )
    service.reset()

    let viewModel = DailyRewardsViewModel(rewardsService: service)
    let testRewards = [
      DailyReward(coins: 100, claimed: false, requiresAd: false),
      DailyReward(coins: 200, claimed: true, requiresAd: false),
      DailyReward(coins: 300, claimed: false, requiresAd: false),
      DailyReward(coins: 400, claimed: false, requiresAd: true),
    ]
    return DailyRewardsView(viewModel: viewModel)
    // VStack {
    // nextTimerCardView()
    // claimedRewardCardView(reward: testRewards[0])
    // lockedRewardCardView(reward: testRewards[1])
    // unclaimedRewardCardView(reward: testRewards[2])
    // unclaimedRewardCardView(reward: testRewards[3])
    // notificationButtonView()
    // }
  }
#endif
