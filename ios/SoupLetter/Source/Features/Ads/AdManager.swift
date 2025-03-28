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

  var isRewardedInterstitialReady: Bool {
    rewardedInterstitialAdManager.adState == .loaded
  }

  var canShowAds: Bool {
    return !UserDefaults.standard.bool(forKey: "remove_ads_purchased")
  }

  var canShowInterstitialBasedOnFrequency: Bool {
    let timeSinceLastAd = Date().timeIntervalSince(lastInterstitialShownTime)
    return timeSinceLastAd >= AdConstants.Frequency.minimumInterval
  }

  private var isAdMobInitialized = false

  // Timestamps for when ads were last shown
  private var lastInterstitialShownTime: Date = Date()

  private let interstitialAdManager = InterstitialAdManager()
  private let rewardedAdManager = RewardedAdManager()
  private let rewardedInterstitialAdManager = RewardedInterstitialAdManager()
  private let analyticsManager: AnalyticsService

  private let consentService: AdvertisingConsentService

  init(analyticsManager: AnalyticsService, consentService: AdvertisingConsentService) {
    self.analyticsManager = analyticsManager
    self.consentService = consentService
  }

  private func getCanShowAds() -> Bool {
    return !UserDefaults.standard.bool(forKey: "remove_ads_purchased")
  }

  // Private implementation of the frequency check
  private func checkInterstitialFrequency() -> Bool {
    return canShowInterstitialBasedOnFrequency
  }

  @MainActor
  func onAppActive() async {
    await consentService.initialize()
    initializeAdMob()
  }

  private func initializeAdMob() {
    // For testing
    #if DEBUG
      print("📢 [AdMob] Initializing with test device identifiers: GADSimulatorID")
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
  func showInterstitialAd(on viewController: UIViewController) async -> Bool {
    guard canShowAds else { return false }

    // Check frequency limit
    guard checkInterstitialFrequency() else {
      print("📢 [Interstitial] Ad not shown due to frequency limit")
      analyticsManager.trackEvent(
        .adInterstitialFailed,
        parameters:
          AnalyticsParamsCreator.adEvent(
            adType: "interstitial",
            location: "game_complete",
            errorReason: "frequency_limit"))
      return false
    }

    // Track ad requested event
    analyticsManager.trackEvent(
      .adInterstitialRequested,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "interstitial", location: "game_complete"))

    let result = await interstitialAdManager.showAd(on: viewController)

    // Track ad impression or failure
    if result {
      // Update the last shown timestamp
      lastInterstitialShownTime = Date()

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

  @MainActor
  func showRewardedInterstitial(on viewController: UIViewController) async -> Bool {
    guard canShowAds else { return false }

    analyticsManager.trackEvent(
      .adRewardedInterstitialRequested,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "rewarded_interstitial", location: "in_game"))

    let result = await rewardedInterstitialAdManager.showAd(on: viewController)

    if result {
      // Update the last shown timestamp
      lastInterstitialShownTime = Date()

      analyticsManager.trackEvent(
        .adRewardedInterstitialImpression,
        parameters:
          AnalyticsParamsCreator.adEvent(adType: "rewarded_interstitial", location: "in_game"))
      analyticsManager.trackEvent(
        .adRewardedInterstitialCompleted,
        parameters:
          AnalyticsParamsCreator.adEvent(
            adType: "rewarded_interstitial", location: "in_game", rewardGranted: true))
    } else {
      analyticsManager.trackEvent(
        .adRewardedInterstitialFailed,
        parameters:
          AnalyticsParamsCreator.adEvent(
            adType: "rewarded_interstitial", location: "in_game",
            errorReason: "not_implemented_or_failed"))
    }

    analyticsManager.trackEvent(
      .adRewardedInterstitialClosed,
      parameters:
        AnalyticsParamsCreator.adEvent(adType: "rewarded_interstitial", location: "in_game"))

    return result
  }
}
