import Foundation
import StoreKit

/// Represents the Remove Ads in-app purchase product
struct RemoveAdsProduct {
  /// Display name of the product
  let name: String = "Ad-Free Experience"

  /// Description of the product
  let description: String = "Remove all ads permanently"

  /// Price display string (e.g., "$4.99")
  var priceText: String = ""

  /// The StoreKit product associated with this product
  var product: Product?

  /// Reference to the actual StoreKit product ID
  let productIdStandard: String = "com.wordseekr.coinpack.removeads"
  let productIdDiscountedEarlyBird: String = "com.wordseekr.coinpack.removeads60"
  var productId: String {
    productIdDiscountedEarlyBird
  }
  /// Icon name for the product
  let icon: String = "banner.slash"

  /// Whether the product has been purchased
  var isPurchased: Bool = false

  /// Initialize a new Remove Ads product
  init() {}
}
