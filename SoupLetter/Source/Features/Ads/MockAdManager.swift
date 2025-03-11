#if DEBUG
  import UIKit
  final class MockAdManager: AdManaging {
    var isInterstitialReady: Bool
    var isRewardedReady: Bool

    var canShowAds: Bool = true

    init() {
      isInterstitialReady = true
      isRewardedReady = true
    }

    func onAppActive() async {
      isInterstitialReady = true
      isRewardedReady = true
    }

    func onGameComplete(on viewController: UIViewController) async -> Bool {
      print("!!!!! onGameComplete")
      isInterstitialReady = false
      isInterstitialReady = true
      return true
    }

    func showRewardedAd(on viewController: UIViewController) async -> Bool {
      print("!!!!! showRewardedAd")
      isRewardedReady = false
      isRewardedReady = true
      return true
    }
  }
#endif
