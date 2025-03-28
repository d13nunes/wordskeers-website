import Combine
import Foundation
import UIKit

/// Manages the hint system for the word search game

@Observable class HintManager {
  // MARK: - Properties

  private(set) var positions: [Position] = []

  var canRequestHint: Bool {
    adManager.isRewardedReady && positions.isEmpty
  }

  private let adManager: AdManaging

  // MARK: - Initialization

  init(adManager: AdManaging) {
    self.adManager = adManager

  }
  // MARK: - Public Methods
  @MainActor
  func requestHint(words: [WordData], on viewController: UIViewController) async -> Bool {
    guard canRequestHint else {
      return false
    }
    let wasRewarded = await adManager.showRewardedAd(on: viewController)
    guard wasRewarded else {
      return false
    }
    guard let word = words.filter({ !$0.isFound }).randomElement() else {
      return false
    }
    setHint(position: word.position)
    return true
  }

  @MainActor
  func setHint(position: Position) {
    positions = [position]
  }

  @MainActor
  func clearHint() {
    positions = []
  }
}
