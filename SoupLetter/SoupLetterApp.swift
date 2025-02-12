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

  let configuration = GameConfiguration(
    gridSize: 10,
    words: [
      "Knife", "Spice", "Grill", "Whisk", "Oven", "Stir", "Boil", "Sauté", "Baste", "Steam", "Chop",
      "Bake", "Dough", "Pantry", "Broil", "Spoon", "Zest", "Simmer", "Peel", "Roast",
    ])

  let gameManager: GameStateManager
  let adManager = AdManager.shared
  init() {
    self.gameManager = GameStateManager(configuration: configuration)
  }

  var body: some Scene {
    WindowGroup {
      GeometryReader { geometry in
        VStack {
          GameView(viewModel: GameViewModel(gameManager: gameManager))
          // Spacer()
          // AdBannerView(
          //   adUnitID: "ca-app-pub-3940256099942544/2934735716",
          //   width: geometry.size.width
          // )
        }
      }
    }
  }
}
