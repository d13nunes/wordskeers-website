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
struct MainApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  let adManager: AdManaging = AdManagerProvider.shared
  var configuration: GameConfiguration?
  init() {
    self.wordStore = WordListStore()
    self.gameConfigurationFactory = GameConfigurationFactory(wordStore: wordStore)
    let configuration = gameConfigurationFactory.createRandomConfiguration()
    self.gameViewModel = GameViewModel(
      gameManager: GameManager(configuration: configuration),
      gameConfigurationFactory: gameConfigurationFactory,
      adManager: adManager
    )

  }

  @State private var showSplash = false
  private let wordStore: WordListStore
  private let gameConfigurationFactory: GameConfigurationFactory
  private let gameViewModel: GameViewModel
  var body: some Scene {
    WindowGroup {
      if showSplash {
        SplashView()
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
              withAnimation {
                showSplash = false
              }
            }
          }
      } else {
        GameView(viewModel: gameViewModel)
      }
    }
  }
}
