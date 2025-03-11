import Foundation

struct RewardedVideoProduct: CoinStoreInfoing {

  let name: String
  let coinAmount: Int
  let isRewardedVideo: Bool = true
  var totalCoins: Int { coinAmount }
  var priceText: String { "\(coinAmount)" }
  let isMostPopular: Bool = false
  let isBestValue: Bool = false
  let bonusPercentage: Int = 0
}
