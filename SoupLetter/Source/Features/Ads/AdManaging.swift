import UIKit

protocol AdManaging {
  var isInterstitialReady: Bool { get }
  var isRewardedReady: Bool { get }
  var canShowAds: Bool { get }

  @MainActor
  func onAppActive() async

  @MainActor
  func showInterstitialAd(on viewController: UIViewController) async -> Bool

  @MainActor
  func showRewardedAd(on viewController: UIViewController) async -> Bool
}
