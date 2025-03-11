import Foundation
import UIKit

/// Extension to provide ad-related functionality
extension AdManaging {
  /// Checks if ads should be shown based on purchases
  /// - Returns: True if ads should be shown, false if they have been disabled through purchase
  func shouldShowAds() -> Bool {
    // Check UserDefaults for remove ads purchased state
    return !UserDefaults.standard.bool(forKey: "remove_ads_purchased")
  }

  /// Show an interstitial ad at game completion only if ads are enabled
  /// - Parameters:
  ///   - viewController: The view controller to present the ad on
  /// - Returns: True if the ad was shown or ads are disabled
  @MainActor
  func onGameCompleteIfEnabled(on viewController: UIViewController) async -> Bool {
    // Skip showing ads if user purchased remove ads
    guard shouldShowAds() else {
      return true
    }

    // Otherwise show the ad normally
    return await onGameComplete(on: viewController)
  }
}
