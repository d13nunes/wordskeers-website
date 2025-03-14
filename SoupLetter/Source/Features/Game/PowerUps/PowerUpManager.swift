import Combine
import Foundation
import UIKit

/// Manages the power-ups for the word search game
@Observable class PowerUpManager {
  // MARK: - Properties

  /// Currently active power-up type
  private(set) var activePowerUpType: PowerUpType = .none

  /// For word power-up: the positions that should be revealed
  private(set) var hintedPositions: [Position] = []
  private(set) var hintedWord: WordData?

  /// For rotate board power-up: the rotation angle degrees
  private(set) var boardRotation: Int = 0

  private(set) var powerUpsActivated: [PowerUpType: Int] = [:]
  var powerUpsActivatedCount: Int {
    powerUpsActivated.reduce(0) { $0 + $1.value }
  }

  /// Ad manager for showing rewarded ads when using power-ups
  private let adManager: AdManaging
  private let analytics: AnalyticsService
  private var enabledPowerUps: [PowerUpType]
  private var words: [WordData]
  private(set) var powerUps: [PowerUp] = []
  private let wallet: Wallet

  init(adManager: AdManaging, analytics: AnalyticsService, wallet: Wallet) {
    self.analytics = analytics
    self.adManager = adManager
    self.wallet = wallet

    self.enabledPowerUps = []
    self.words = []
    self.powerUpsActivated = [:]
    self.powerUps = []
  }

  @MainActor
  func setupPowerUps(enabledPowerUps: [PowerUpType], words: [WordData]) {
    hintedPositions = []
    boardRotation = 0
    activePowerUpType = .none
    self.enabledPowerUps = enabledPowerUps
    self.words = words
    powerUpsActivated = enabledPowerUps.reduce(into: [PowerUpType: Int]()) {
      $0[$1] = 0
    }
    powerUps = enabledPowerUps.map { createPowerUp(type: $0) }
  }

  private func createPowerUp(type: PowerUpType) -> PowerUp {
    switch type {
    case .hint:
      return HintPowerUp(setHintedPositions: setHinted, wallet: wallet)
    case .directional:
      return DirectionPowerUp(setHintedWord: setHinted, wallet: wallet)
    case .fullWord:
      return FullWordPowerUp(setHintedPositions: setHinted, wallet: wallet)
    case .rotateBoard:
      return RotateBoardPowerUp(doRotation: doRotation, wallet: wallet)
    case .none:
      fatalError("PowerUpManager: PowerUpType.none is not a valid power-up type")
    }
  }

  @MainActor
  func requestPowerUp(
    type: PowerUpType,
    undiscoveredWords: [WordData],
    on viewController: UIViewController
  ) async -> Bool {
    let powerUp = powerUps.first(where: { $0.type == type })!
    return await requestPowerUp(
      powerUp: powerUp,
      undiscoveredWords: undiscoveredWords,
      on: viewController
    )
  }

  // MARK: - Public Methods
  /// Request to use a power-up
  /// - Parameters:
  ///   - type: The type of power-up to use
  ///   - words: Array of word data for the current game
  ///   - viewController: The view controller to present the ad on
  /// - Returns: Whether the power-up was successfully activated
  @MainActor
  func requestPowerUp(
    powerUp: PowerUp,
    undiscoveredWords: [WordData],
    on viewController: UIViewController
  ) async -> Bool {
    // Check if power-up is available
    guard powerUp.isAvailable else {
      return false
    }
    guard wallet.coins >= powerUp.price else {
      return false
    }
    wallet.removeCoins(powerUp.price)
    let wasUsed = await powerUp.use(undiscoveredWords: undiscoveredWords)
    if wasUsed {
      activePowerUpType = powerUp.type
      powerUpsActivated[powerUp.type] = (powerUpsActivated[powerUp.type] ?? 0) + 1
      analytics.trackEvent(powerUp.type.analyticsEvent, parameters: [:])
    }
    return wasUsed
  }

  /// Clears the currently active power-up
  @MainActor
  func clearActivePowerUp() {
    activePowerUpType = .none
    hintedPositions = []
    hintedWord = nil
  }

  private func setHinted(_ positions: [Position]) {
    hintedPositions = positions
  }

  private func setHinted(_ word: WordData) {
    hintedWord = word
  }

  private func doRotation(of degrees: Int) {
    boardRotation = (boardRotation + degrees) % 360
  }
}
