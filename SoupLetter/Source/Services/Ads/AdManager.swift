import Combine
import Foundation
import UIKit

@Observable
final class AdManager {
  static let shared = AdManager()

  // MARK: - Publishers
  var isInterstitialReady: Bool {
    interstitialAdManager.state == .loaded
  }
  var isRewardedReady: Bool {
    rewardedAdManager.adState == .loaded
  }

  private let interstitialAdManager = InterstitialAdManager()
  private let rewardedAdManager = RewardedAdManager()

  @MainActor
  func onGameComplete(on viewController: UIViewController) async -> Bool {
    return await interstitialAdManager.showAd(on: viewController)
  }

  @MainActor
  func showRewardedAd(on viewController: UIViewController) async -> Bool {
    return await rewardedAdManager.showAd(on: viewController)
  }
}
