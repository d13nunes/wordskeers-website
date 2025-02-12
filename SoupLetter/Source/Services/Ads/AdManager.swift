import Foundation
import UIKit

final class AdManager {
  static let shared = AdManager()

  private let interstitialAdManager = InterstitialAdManager()

  func onGameComplete(completion: @escaping () -> Void) {
    let viewController = UIApplication.shared.rootViewController()
    guard let viewController else {
      print("No root view controller found")
      return
    }
    interstitialAdManager.showAd(on: viewController, completion: completion)
  }
}
