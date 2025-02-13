import Foundation
import UIKit

@MainActor
final class AdManager {
  static let shared = AdManager()

  private let interstitialAdManager = InterstitialAdManager()

  func onGameComplete() async {
    return await withCheckedContinuation { continuation in
      let viewController = UIApplication.shared.rootViewController()
      guard let viewController else {
        print("No root view controller found")
        return
      }
      interstitialAdManager.showAd(on: viewController) {
        continuation.resume()
      }
    }
  }
}
