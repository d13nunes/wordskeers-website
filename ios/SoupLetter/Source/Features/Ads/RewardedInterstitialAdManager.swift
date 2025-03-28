import Foundation
import GoogleMobileAds
import UIKit

final class RewardedInterstitialAdManager: NSObject {

  @Published private(set) var adState: AdState = .notLoaded {
    didSet {
      print("📢 [RewardedInterstitial] State changed: \(oldValue) -> \(adState)")
    }
  }

  private var rewardedInterstitialAd: RewardedInterstitialAd?
  private var completionHandler: ((Bool) -> Void)?

  override init() {
    super.init()
    Task {
      await load()
    }
  }

  private func load() async {
    let request = Request()
    // Assuming this ad unit ID exists or will be created
    let adUnitID = AdConstants.UnitID.rewardedInterstitial

    do {
      let ad = try await RewardedInterstitialAd.load(with: adUnitID, request: request)
      self.rewardedInterstitialAd = ad
      self.adState = .loaded
    } catch {
      print("📢 [RewardedInterstitial] Failed to load ad with error: \(error.localizedDescription)")
      await load()
    }
  }

  @MainActor
  func showAd(on viewController: UIViewController) async -> Bool {
    guard let rewardedInterstitialAd = rewardedInterstitialAd else {
      print("📢 [RewardedInterstitial] Ad not ready")
      return false
    }

    rewardedInterstitialAd.fullScreenContentDelegate = self

    let didReceiveReward = await withCheckedContinuation { continuation in
      rewardedInterstitialAd.present(from: viewController) {
        // User earned reward
        print(
          "📢 [RewardedInterstitial] User earned reward \(rewardedInterstitialAd.adReward.description)"
        )
        print(
          "📢 [RewardedInterstitial] User earned reward \(rewardedInterstitialAd.responseInfo.description)"
        )
        let wasRewarded = rewardedInterstitialAd.adReward.amount.intValue > 0
        continuation.resume(returning: wasRewarded)
      }
    }
    Task.detached {
      await self.load()
    }
    return didReceiveReward
  }
}

// MARK: - GADFullScreenContentDelegate
extension RewardedInterstitialAdManager: FullScreenContentDelegate {
  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    completionHandler?(false)
    completionHandler = nil
    Task {
      await load()
    }
  }

  func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("📢 [RewardedInterstitial] Failed to present ad with error: \(error.localizedDescription)")
    completionHandler?(false)
    completionHandler = nil
    Task {
      await load()
    }
  }
}
