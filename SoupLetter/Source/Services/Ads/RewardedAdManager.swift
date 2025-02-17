import Foundation
import GoogleMobileAds
import UIKit

final class RewardedAdManager: NSObject {

  @Published private(set) var adState: AdState = .notLoaded {
    didSet {
      print("📢 [Rewarded] State changed: \(oldValue) -> \(adState)")
    }
  }

  private var rewardedAd: RewardedAd?
  private var completionHandler: ((Bool) -> Void)?

  override init() {
    super.init()
    Task {
      await load()
    }
  }

  private func load() async {
    let request = Request()
    let adUnitID = AdConstants.UnitID.rewarded

    do {
      let ad = try await RewardedAd.load(with: adUnitID, request: request)
      self.rewardedAd = ad
      self.adState = .loaded
    } catch {
      print("📢 [Rewarded] Failed to load ad with error: \(error.localizedDescription)")
      await load()
    }
  }

  @MainActor
  func showAd(on viewController: UIViewController) async -> Bool {
    guard let rewardedAd = rewardedAd else {
      print("📢 [Rewarded] Ad not ready")
      return false
    }

    rewardedAd.fullScreenContentDelegate = self

    let didRecieveReward = await withCheckedContinuation { continuation in
      rewardedAd.present(from: viewController) {
        // User earned reward
        print("📢 [Rewarded] User earned reward \(rewardedAd.adReward.description)")
        print("📢 [Rewarded] User earned reward \(rewardedAd.responseInfo.description)")
        let wasRewarded = rewardedAd.adReward.amount.intValue > 0
        continuation.resume(returning: wasRewarded)
      }
    }
    Task.detached {
      await self.load()
    }
    return didRecieveReward
  }
}

// MARK: - GADFullScreenContentDelegate
extension RewardedAdManager: FullScreenContentDelegate {
  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    completionHandler?(false)
    completionHandler = nil
    Task {
      await load()
    }
  }

  func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("📢 [Rewarded] Failed to present ad with error: \(error.localizedDescription)")
    completionHandler?(false)
    completionHandler = nil
    Task {
      await load()
    }
  }
}
