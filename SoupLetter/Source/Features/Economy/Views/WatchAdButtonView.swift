import SwiftUI

class AdForCoinsButtonViewModel {
  private(set) var isDisabled: Bool = false
  let coinAmount: Int

  private let adManager: AdManaging
  private let analytics: AnalyticsService
  private let wallet: Wallet

  init(coinAmount: Int, adManager: AdManaging, analytics: AnalyticsService, wallet: Wallet) {
    self.coinAmount = coinAmount
    self.adManager = adManager
    self.analytics = analytics
    self.wallet = wallet
  }

  @MainActor
  func onClicked(on viewController: UIViewController) async {
    isDisabled = true
    let result = await adManager.showRewardedAd(on: viewController)
    if result {
      wallet.addCoins(coinAmount)
    }
    isDisabled = false
  }
}

struct AdForCoinsButtonView: View {
  let viewModel: AdForCoinsButtonViewModel

  init(viewModel: AdForCoinsButtonViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      Button(action: {
        Task { @MainActor in
          guard let viewController = UIApplication.shared.rootViewController() else {
            return
          }
          await viewModel.onClicked(on: viewController)
        }
      }) {
        Image(systemName: "play.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
          .padding(.all, 8)
      }
      .buttonStyle(.borderedProminent)
      .disabled(viewModel.isDisabled)
      .animation(.easeIn(duration: 0.34), value: viewModel.isDisabled)
      Text("\(viewModel.coinAmount)")
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.all, 4)
        .background(Color.white.opacity(0.1))
        .cornerRadius(4)
        .offset(x: 24, y: 18)
    }
  }
}

#if DEBUG
  #Preview {
    AdForCoinsButtonView(
      viewModel: .init(
        coinAmount: 100, adManager: MockAdManager(), analytics: ConsoleAnalyticsManager(),
        wallet: Wallet.forTesting()))
  }
#endif
