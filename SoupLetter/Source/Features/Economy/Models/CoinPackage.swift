import Foundation
import StoreKit

/// Represents a coin package that can be purchased with real money
struct CoinPackage: CoinStoreInfoing, Identifiable, Equatable {
  /// Unique identifier for the coin package
  let id: String

  /// Display name of the coin package
  let name: String

  /// Number of coins included in the package
  let coinAmount: Int

  /// Price display string (e.g., "$0.99")
  var priceText: String = ""

  /// The StoreKit product associated with this package
  var product: Product?

  /// Bonus percentage (if applicable)
  let bonusPercentage: Int

  /// Reference to the actual StoreKit product ID
  let productId: String

  /// Whether the package is the most popular choice
  let isMostPopular: Bool

  /// Whether the package is the best value
  let isBestValue: Bool

  /// Whether the package is purchased with a rewarded video
  let isRewardedVideo: Bool

  /// Initialize a new coin package
  init(
    id: String,
    name: String,
    coinAmount: Int,
    bonusPercentage: Int = 0,
    productId: String,
    isMostPopular: Bool = false,
    isBestValue: Bool = false,
    isRewardedVideo: Bool = false
  ) {
    self.id = id
    self.name = name
    self.coinAmount = coinAmount
    self.bonusPercentage = bonusPercentage
    self.productId = productId
    self.isMostPopular = isMostPopular
    self.isBestValue = isBestValue
    self.isRewardedVideo = isRewardedVideo
  }

  /// Total number of coins including any bonus
  var totalCoins: Int {
    let bonus = Int(Double(coinAmount) * (Double(bonusPercentage) / 100.0))
    return coinAmount + bonus
  }

  /// Static function to create the default coin packages
  static func defaultPackages() -> [CoinPackage] {
    [
      CoinPackage(
        id: "small_coin_pack",
        name: "Starter Pack",
        coinAmount: 100,
        productId: "com.wordseekr.coinpack.100"
      ),
      CoinPackage(
        id: "medium_coin_pack",
        name: "Popular Pack",
        coinAmount: 300,
        bonusPercentage: 10,
        productId: "com.wordseekr.coinpack.300",
        isMostPopular: true
      ),
      CoinPackage(
        id: "large_coin_pack",
        name: "Premium Pack",
        coinAmount: 700,
        bonusPercentage: 20,
        productId: "com.wordseekr.coinpack.700",
        isBestValue: true
      ),
      CoinPackage(
        id: "huge_coin_pack",
        name: "Mega Pack",
        coinAmount: 1500,
        bonusPercentage: 30,
        productId: "com.wordseekr.coinpack.1500"
      ),
    ]
  }
}
