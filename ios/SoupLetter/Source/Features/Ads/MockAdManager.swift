#if DEBUG
  import UIKit
  final class MockAdManager: AdManaging {
    var isInterstitialReady: Bool
    var isRewardedReady: Bool
    var isRewardedInterstitialReady: Bool

    var canShowAds: Bool = true

    init() {
      isInterstitialReady = true
      isRewardedReady = true
      isRewardedInterstitialReady = true
    }

    func onAppActive() async {
      isInterstitialReady = true
      isRewardedReady = true
      isRewardedInterstitialReady = true
    }

    func showInterstitialAd(on viewController: UIViewController) async -> Bool {
      isInterstitialReady = false
      isInterstitialReady = true
      return true
    }

    func showRewardedAd(on viewController: UIViewController) async -> Bool {
      isRewardedReady = false
      isRewardedReady = true
      return true
    }

    func showRewardedInterstitial(on viewController: UIViewController) async -> Bool {
      isRewardedInterstitialReady = false
      isRewardedInterstitialReady = true
      return true
    }
  }
#endif
