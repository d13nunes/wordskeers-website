import Foundation
import SwiftUI

/// Represents a single daily reward option
@Observable class DailyReward: Identifiable, Codable {
  /// Unique identifier for the reward
  var id: UUID

  /// The amount of coins this reward provides
  var coins: Int

  /// Whether this reward has been claimed by the player
  var claimed: Bool

  /// Whether this reward requires an ad to be claimed
  var requiresAd: Bool

  /// Whether the reward has been doubled by watching an ad
  var doubledWithAd: Bool

  enum CodingKeys: String, CodingKey {
    case id, coins, claimed, requiresAd, doubledWithAd
  }

  /// Initialize a new daily reward
  /// - Parameters:
  ///   - id: Unique identifier (defaults to a new UUID)
  ///   - coins: The amount of coins this reward provides
  ///   - claimed: Whether this reward has been claimed (defaults to false)
  ///   - requiresAd: Whether this reward requires an ad to be claimed (defaults to false)
  ///   - doubledWithAd: Whether this reward has been doubled (defaults to false)
  init(
    id: UUID = UUID(),
    coins: Int,
    claimed: Bool = false,
    requiresAd: Bool = false,
    doubledWithAd: Bool = false
  ) {
    self.id = id
    self.coins = coins
    self.claimed = claimed
    self.requiresAd = requiresAd
    self.doubledWithAd = doubledWithAd
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    coins = try container.decode(Int.self, forKey: .coins)
    claimed = try container.decode(Bool.self, forKey: .claimed)
    requiresAd = try container.decodeIfPresent(Bool.self, forKey: .requiresAd) ?? false
    doubledWithAd = try container.decode(Bool.self, forKey: .doubledWithAd)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(coins, forKey: .coins)
    try container.encode(claimed, forKey: .claimed)
    try container.encode(requiresAd, forKey: .requiresAd)
    try container.encode(doubledWithAd, forKey: .doubledWithAd)
  }
}
