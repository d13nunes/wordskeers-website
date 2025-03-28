protocol CoinStoreInfoing {
  var name: String { get }
  var totalCoins: Int { get }
  var priceText: String { get }
  var isMostPopular: Bool { get }
  var isBestValue: Bool { get }
  var bonusPercentage: Int { get }
  var isRewardedVideo: Bool { get }
}
