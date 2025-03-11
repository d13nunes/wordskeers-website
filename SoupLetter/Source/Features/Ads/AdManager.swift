import Combine
import Foundation
import GoogleMobileAds
import UIKit

@Observable
final class AdManager: AdManaging {

  // MARK: - Publishers
  var isInterstitialReady: Bool {
    interstitialAdManager.state == .loaded
  }

  var isRewardedReady: Bool {
    rewardedAdManager.adState == .loaded
  }

  private var isAdMobInitialized = false

  private let interstitialAdManager = InterstitialAdManager()
  private let rewardedAdManager = RewardedAdManager()
  private let analyticsManager: AnalyticsService

  private let consentService: AdvertisingConsentService

  init(analyticsManager: AnalyticsService, consentService: AdvertisingConsentService) {
    self.analyticsManager = analyticsManager
    self.consentService = consentService
  }

  @MainActor
  func onAppActive() async {
    await consentService.initialize()
    initializeAdMob()
  }

  private func initializeAdMob() {
    // For testing
    #if DEBUG
      MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["GADSimulatorID"]
    #endif

    analyticsManager.trackEvent(.adMobInitializing)
    // Initialize the Google Mobile Ads SDK
    MobileAds.shared.start { [weak self] status in

      // Handle initialization status
      if status.adapterStatusesByClassName.count > 0 {
        debugPrint("AdMob: Successfully initialized")
        self?.analyticsManager.trackEvent(.adMobInitializedSuccessfully)
        self?.isAdMobInitialized = true
      } else {
        debugPrint("AdMob: Initialization incomplete")
        self?.analyticsManager.trackEvent(.adMobInitializationFailed)
        self?.isAdMobInitialized = false
      }
    }
  }
  @MainActor
  func onGameComplete(on viewController: UIViewController) async -> Bool {
    guard shouldShowAds() else { return false }
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
    analyticsManager.trackEvent(
      .adRewardedRequested,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "rewarded", location: "in_game"))

    // Currently returns false as rewarded ads are not implemented
    let result = await rewardedAdManager.showAd(on: viewController)

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

  private func shouldShowAds() -> Bool {
    // Check UserDefaults for remove ads purchased state
    return !UserDefaults.standard.bool(forKey: "remove_ads_purchased")
  }
}
