import Combine
import Foundation
import UIKit

@Observable
final class AdManager: AdManaging {

  // MARK: - Publishers
  var isInterstitialReady: Bool {
    interstitialAdManager.state == .loaded
  }
  var isRewardedReady: Bool = false
  // var isRewardedReady: Bool {
  //   rewardedAdManager.adState == .loaded
  // }

  private let interstitialAdManager = InterstitialAdManager()
  // private let rewardedAdManager = RewardedAdManager()
  private let analyticsManager: AnalyticsService

  init(analyticsManager: AnalyticsService) {
    self.analyticsManager = analyticsManager
  }

  @MainActor
  func onGameComplete(on viewController: UIViewController) async -> Bool {
    // Track ad requested event
    analyticsManager.trackEvent(
      .adInterstitialRequested,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "interstitial", location: "game_complete"))

    let result = await interstitialAdManager.showAd(on: viewController)

    // Track ad impression or failure
    if result {
      analyticsManager.trackEvent(
        .adInterstitialImpression,
        parameters:
          AnalyticsParamsCreator.adEvent(adType: "interstitial", location: "game_complete"))
    } else {
      analyticsManager.trackEvent(
        .adInterstitialFailed,
        parameters:
          AnalyticsParamsCreator.adEvent(adType: "interstitial", location: "game_complete"))
    }

    // Track ad closed event (we don't know exactly when it closes, so this is an approximation)
    analyticsManager.trackEvent(
      .adInterstitialClosed,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "interstitial", location: "game_complete"))

    return result
  }

  @MainActor
  func showRewardedAd(on viewController: UIViewController) async -> Bool {
    // Track ad requested event
    analyticsManager.trackEvent(
      .adRewardedRequested,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "rewarded", location: "in_game"))

    // Currently returns false as rewarded ads are not implemented
    let result = false  // await rewardedAdManager.showAd(on: viewController)

    // Track failure for now since rewarded ads are not implemented
    analyticsManager.trackEvent(
      .adRewardedFailed,
      parameters:
        AnalyticsParamsCreator.adEvent(
          adType: "rewarded", location: "in_game",
          errorReason: "not_implemented"))

    if result {
      analyticsManager.trackEvent(
        .adRewardedImpression,
        parameters:
          AnalyticsParamsCreator.adEvent(adType: "rewarded", location: "in_game"))
      analyticsManager.trackEvent(
        .adRewardedCompleted,
        parameters:
          AnalyticsParamsCreator.adEvent(
            adType: "rewarded", location: "in_game", rewardGranted: true))
    }

    analyticsManager.trackEvent(
      .adRewardedClosed,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "rewarded", location: "in_game"))

    return result
  }
}
