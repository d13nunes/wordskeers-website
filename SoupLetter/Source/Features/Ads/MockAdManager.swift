#if DEBUG
  import UIKit
  final class MockAdManager: AdManaging {
    var isInterstitialReady: Bool
    var isRewardedReady: Bool

    init() {
      isInterstitialReady = false
      isRewardedReady = false
    }

    func onAppActive() async {
      isInterstitialReady = true
      isRewardedReady = true
    }

    func onGameComplete(on viewController: UIViewController) async -> Bool {
      isInterstitialReady = false
      isInterstitialReady = true
      return true
    }

    func showRewardedAd(on viewController: UIViewController) async -> Bool {
      isRewardedReady = false
      isRewardedReady = true
      return true
    }
  }
#endif
