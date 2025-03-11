import Foundation
import SwiftUI

/// Represents the player's wallet containing their currencies
@Observable class Wallet {
  /// The current amount of coins the player has
  private(set) var coins: Int

  /// Initialize a new wallet
  /// - Parameter coins: Initial coin amount (defaults to 0)
  private init(coins: Int = 0) {
    self.coins = coins
  }

  /// Add coins to the wallet
  /// - Parameter amount: The amount of coins to add
  /// - Returns: The new coin balance
  @discardableResult
  func addCoins(_ amount: Int) -> Int {
    coins += max(0, amount)
    saveWallet()
    return coins
  }

  /// Remove coins from the wallet
  /// - Parameter amount: The amount of coins to remove
  /// - Returns: True if the player had enough coins and they were successfully removed
  @discardableResult
  func removeCoins(_ amount: Int) -> Bool {
    guard amount > 0, coins >= amount else { return false }

    coins -= amount
    saveWallet()
    return true
  }

  /// Check if the player has enough coins for a purchase
  /// - Parameter amount: The amount to check
  /// - Returns: True if the player has enough coins
  func hasEnoughCoins(_ amount: Int) -> Bool {
    return coins >= amount
  }

  // MARK: - Persistence

  /// Save the wallet to UserDefaults
  private func saveWallet() {
    UserDefaults.standard.set(coins, forKey: "player_coins")
  }

  /// Load the wallet from UserDefaults
  static func loadWallet() -> Wallet {
    let coins = UserDefaults.standard.integer(forKey: "player_coins")
    return Wallet(coins: coins)
  }

  #if DEBUG
    static func forTesting() -> Wallet {
      return Wallet(coins: 1000)
    }
  #endif
}
