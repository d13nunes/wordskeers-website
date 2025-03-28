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
}
