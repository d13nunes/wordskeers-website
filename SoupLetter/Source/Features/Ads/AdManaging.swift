import UIKit

protocol AdManaging {
  var isInterstitialReady: Bool { get }
  var isRewardedReady: Bool { get }

  @MainActor
  func onAppActive() async

  @MainActor
  func onGameComplete(on viewController: UIViewController) async -> Bool

  @MainActor
  func showRewardedAd(on viewController: UIViewController) async -> Bool
}
