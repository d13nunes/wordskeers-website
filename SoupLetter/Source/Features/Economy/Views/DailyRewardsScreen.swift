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

        if viewModel.rewardsState.canClaimToday {
          // Show the three reward options
          availableRewardsView
        } else if let selectedID = viewModel.rewardsState.selectedRewardID,
          let selectedReward = viewModel.rewardsState.currentRewards.first(where: {
            $0.id == selectedID
          })
        {
          // Show claimed reward and double option
          claimedRewardView(selectedReward)
        } else {
          // Show countdown to next reward
          waitingForNextRewardView
        }

        Spacer()
      }
      .padding()
    }
    .navigationTitle("Daily Rewards")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      viewModel.onAppear()
    }
    .onDisappear {
      viewModel.onDisappear()
    }
    .alert("Coins Doubled!", isPresented: $viewModel.showAdSuccess) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("You've doubled your daily reward!")
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
  }

  /// View displaying available rewards to claim
  private var availableRewardsView: some View {
    VStack(spacing: 24) {
      Text("Pick your daily reward!")
        .font(.headline)
        .padding(.bottom)

      HStack(spacing: 16) {
        ForEach(viewModel.rewardsState.currentRewards) { reward in
          mysteryRewardView(reward)
        }
      }
      .padding(.horizontal)
    }
  }

  /// View for a single mystery reward option
  private func mysteryRewardView(_ reward: DailyReward) -> some View {
    Button {
      viewModel.claimReward(with: reward.id)
    } label: {
      VStack {
        Image(systemName: "gift.fill")
          .font(.system(size: 40))
          .foregroundColor(.yellow)

        Text("Mystery\nCoins")
          .font(.subheadline)
          .fontWeight(.medium)
          .multilineTextAlignment(.center)
      }
      .frame(width: 100, height: 120)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.white)
          .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
      )
    }
    .buttonStyle(.plain)
    .sensoryFeedback(.impact, trigger: true)
    .accessibility(label: Text("Mystery reward box"))
    .accessibility(hint: Text("Tap to claim your daily reward"))
  }

  /// View displaying a claimed reward with option to double
  private func claimedRewardView(_ reward: DailyReward) -> some View {
    VStack(spacing: 24) {
      Text("You received:")
        .font(.headline)

      VStack(spacing: 8) {
        Image(systemName: "coin.fill")
          .font(.system(size: 50))
          .foregroundColor(.yellow)
          .symbolEffect(.bounce, options: .repeating, value: reward.claimed)

        Text("\(reward.coins) Coins")
          .font(.title3)
          .fontWeight(.bold)

        if reward.doubledWithAd {
          HStack {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(.green)
            Text("Reward Doubled!")
          }
          .font(.subheadline)
          .padding(.top, 4)
        }
      }
      .frame(minWidth: 180, minHeight: 160)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.white)
          .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
      )

      if !reward.doubledWithAd {
        Button {
          Task {
            await viewModel.doubleRewardWithAd()
          }
        } label: {
          HStack {
            Image(systemName: "play.rectangle.fill")
            Text("Double Coins")
          }
          .frame(minWidth: 200)
          .padding()
          .background(
            Capsule()
              .fill(Color.yellow)
          )
          .foregroundColor(.black)
          .fontWeight(.semibold)
        }
        .disabled(viewModel.isLoading)
        .overlay {
          if viewModel.isLoading {
            ProgressView()
          }
        }
        .accessibilityLabel("Double coins by watching an ad")
      }

      // Next reward countdown
      VStack(spacing: 12) {
        HStack {
          Image(systemName: "clock.fill")
            .foregroundColor(.blue)
          Text("Next reward in:")
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
      .accessibilityLabel("Next reward available in \(viewModel.timeUntilNextReward)")

      // Notification reminder button
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

  /// View displaying countdown until next reward is available
  private var waitingForNextRewardView: some View {
    VStack(spacing: 20) {
      Image(systemName: "calendar.badge.clock")
        .font(.system(size: 70))
        .symbolRenderingMode(.multicolor)
        .foregroundStyle(.blue, .yellow)
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
        Text("Come back tomorrow for more rewards!")
      }
      .font(.callout)
      .foregroundColor(.secondary)
      .padding(.top, 8)

      // Notification reminder button
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
    static var previews: some View {
      NavigationStack {
        DailyRewardsView(
          viewModel: DailyRewardsViewModel(
            rewardsService: DailyRewardsService(
              wallet: Wallet.forTesting(),
              adManager: MockAdManager(),
              analytics: ConsoleAnalyticsManager()
            )
          )
        )
      }
    }
  }
#endif
