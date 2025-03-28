import Foundation
import GoogleMobileAds
import SwiftUI

/// Service responsible for loading and presenting interstitial ads
final class InterstitialAdManager: NSObject {
  // MARK: - Properties
  /// The current state of the ad
  @Published private(set) var state: AdState = .notLoaded {
    didSet {
      print("📢 [Interstitial] State changed: \(oldValue) -> \(state)")
    }
  }

  /// The interstitial ad instance
  private var interstitial: InterstitialAd?

  /// The last time an ad was shown
  private var lastAdShownDate: Date?

  /// Counter for game completions
  private var gameCompletionsCount = 0

  // MARK: - Initialization

  override init() {
    super.init()
    loadAd()
  }

  // MARK: - Public Methods

  /// Presents the interstitial ad if one is loaded
  /// - Parameter completion: Called when the ad is dismissed or if it fails to present
  func showAd(on rootViewController: UIViewController) async -> Bool {
    guard let interstitial else {
      print("📢 [Interstitial] Ad not loaded")
      return false
    }

    state = .presenting
    await interstitial.present(from: rootViewController)
    return true
  }

  private func loadAd() {
    print("📢 [Interstitial] Attempting to load new ad")
    state = .loading

    let request = Request()
    InterstitialAd.load(
      with: AdConstants.UnitID.interstitial,
      request: request
    ) { [weak self] ad, error in
      if let error = error {
        print("📢 [Interstitial] Failed to load ad with error: \(error.localizedDescription)")
        self?.state = .error(error)
        return
      }

      print("📢 [Interstitial] Successfully loaded new ad")
      self?.interstitial = ad
      self?.interstitial?.fullScreenContentDelegate = self
      self?.state = .loaded
    }
  }
}

// MARK: - GADFullScreenContentDelegate

extension InterstitialAdManager: FullScreenContentDelegate {
  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("📢 [Interstitial] Ad was dismissed")
    state = .notLoaded
    loadAd()
  }

  func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("📢 [Interstitial] Ad failed to present with error: \(error.localizedDescription)")
    state = .error(error)
    loadAd()
  }
}
