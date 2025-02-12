import SwiftUI
import UIKit

extension UIApplication {
  func rootViewController() -> UIViewController? {
    guard let windowScene = connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else {
      return nil
    }
    return window.rootViewController
  }
}
