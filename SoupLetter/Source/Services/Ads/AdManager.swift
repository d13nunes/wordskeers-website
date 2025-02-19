import Combine
import Foundation
import UIKit

protocol AdManaging {
  var isInterstitialReady: Bool { get }
  var isRewardedReady: Bool { get }

  @MainActor
  func onGameComplete(on viewController: UIViewController) async -> Bool

  @MainActor
  func showRewardedAd(on viewController: UIViewController) async -> Bool
}

#if DEBUG

  private final class MockAdManager: AdManaging {
    var isInterstitialReady: Bool {
      return true
    }
    var isRewardedReady: Bool {
      return true
    }

    func onGameComplete(on viewController: UIViewController) async -> Bool {
      return true
    }

    func showRewardedAd(on viewController: UIViewController) async -> Bool {
      return true
    }
  }
#endif

final class AdManagerProvider {
  static let shared: AdManaging = AdManager()
  // #if DEBUG
  //   static let shared: AdManaging = MockAdManager()
  // #else
  // #endif
}

@Observable
private final class AdManager: AdManaging {
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
