//
//  SoupLetterApp.swift
//  SoupLetter
//
//  Created by Diogo Nunes on 10/02/2025.
//

import GoogleMobileAds
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    MobileAds.shared.start()
    return true
  }
}
@main
struct SoupLetterApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  let adManager = AdManager.shared
  var configuration: GameConfiguration?
  init() {
  }

  @State var path: [GameConfiguration] = []

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: $path) {
        CategorySelectionView { configuration in
          path.append(configuration)

        }
        .navigationDestination(for: GameConfiguration.self) { configuration in
          GameView(
            viewModel: GameViewModel(
              gameManager: GameStateManager(configuration: configuration)
            ),
            path: $path
          )
        }
      }
    }
  }
}
