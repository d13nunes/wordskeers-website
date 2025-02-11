import Foundation
import GoogleMobileAds
import SwiftUI

/// Service responsible for loading and presenting interstitial ads
final class InterstitialAdManager: NSObject {
  // MARK: - Properties

  /// The current state of the ad
  private(set) var state: AdState = .notLoaded {
    didSet {
      print("📢 [AdManager] State changed: \(oldValue) -> \(state)")
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
  func showAd(on rootViewController: UIViewController, completion: @escaping () -> Void) {
    guard let interstitial else {
      print("Ad not loaded")
      completion()
      return
    }

    state = .presenting
    interstitial.present(from: rootViewController)
  }

  // MARK: - Private Methods

  private var shouldShowAd: Bool {
    // Check if enough time has passed since last ad
    if let lastShown = lastAdShownDate {
      let timeSinceLastAd = Date().timeIntervalSince(lastShown)
      if timeSinceLastAd < AdConstants.Frequency.minimumInterval {
        return false
      }
    }

    // Check if enough games have been completed
    if gameCompletionsCount < AdConstants.Frequency.gameCompletionsBeforeAd {
      return false
    }

    // Check if an ad is loaded
    return state == .loaded
  }

  private func loadAd() {
    print("📢 [AdManager] Attempting to load new ad")
    state = .loading

    let request = Request()
    InterstitialAd.load(
      with: AdConstants.UnitID.interstitial,
      request: request
    ) { [weak self] ad, error in
      if let error = error {
        print("📢 [AdManager] Failed to load ad with error: \(error.localizedDescription)")
        self?.state = .error(error)
        return
      }

      print("📢 [AdManager] Successfully loaded new ad")
      self?.interstitial = ad
      self?.interstitial?.fullScreenContentDelegate = self
      self?.state = .loaded
    }
  }
}

// MARK: - GADFullScreenContentDelegate

extension InterstitialAdManager: FullScreenContentDelegate {
  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("📢 [AdManager] Ad was dismissed")
    state = .notLoaded
    loadAd()
  }

  func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    print("📢 [AdManager] Ad failed to present with error: \(error.localizedDescription)")
    state = .error(error)
    loadAd()
  }
}

// MARK: - AdState

extension InterstitialAdManager {
  /// Represents the current state of the ad
  enum AdState: Equatable {
    case notLoaded
    case loading
    case loaded
    case presenting
    case error(Error)

    static func == (lhs: AdState, rhs: AdState) -> Bool {
      switch (lhs, rhs) {
      case (.notLoaded, .notLoaded): return true
      case (.loading, .loading): return true
      case (.loaded, .loaded): return true
      case (.presenting, .presenting): return true
      case (.error, .error): return true
      default: return false
      }
    }
  }
}
