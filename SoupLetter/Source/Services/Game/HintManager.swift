import Combine
import Foundation
import UIKit

/// Manages the hint system for the word search game
@Observable class HintManager {
  // MARK: - Properties

  private(set) var hintPosition: Position?

  var canRequestHint: Bool {
    adManager.isRewardedReady && hintPosition == nil
  }

  private let adManager: AdManager

  // MARK: - Initialization

  init(adManager: AdManager) {
    self.adManager = adManager

  }
  // MARK: - Public Methods
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
    hintPosition = word.position
    return true
  }

  func clearHint() {
    hintPosition = nil
  }
}
