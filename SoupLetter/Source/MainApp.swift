//
//  SoupLetterApp.swift
//  SoupLetter
//
//  Created by Diogo Nunes on 10/02/2025.
//

import GoogleMobileAds
import SwiftUI

@main
struct MainApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @Environment(\.scenePhase) private var scenePhase

  @State private var showSplash = false
  @State private var firstTime = true

  private var analyticsManager = AnalyticsManager(service: FirebaseAnalyticsManager())
  private let adManager: AdManaging
  private var configuration: GameConfiguration?

  init() {
    self.adManager = AdManager(analyticsManager: analyticsManager)
    self.wordStore = WordListStore()
    self.gameConfigurationFactory = GameConfigurationFactory(wordStore: wordStore)
    let configuration = gameConfigurationFactory.createRandomConfiguration()
    self.gameViewModel = GameViewModel(
      gameManager: GameManager(configuration: configuration),
      gameConfigurationFactory: gameConfigurationFactory,
      adManager: adManager,
      analytics: analyticsManager
    )

  }

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
    .onChange(of: scenePhase) { _, newPhase in
      trackAppState(scenePhase: newPhase, firstTime: firstTime)
      firstTime = false
    }
  }
}

extension MainApp {
  func trackAppState(scenePhase: ScenePhase, firstTime: Bool) {
    switch scenePhase {
    case .active:
      if firstTime {
        analyticsManager.trackEvent(.appStarted)

      } else {
        analyticsManager.trackEvent(.appActive)
      }
    case .inactive:
      analyticsManager.trackEvent(.appInactive)
    case .background:
      analyticsManager.trackEvent(.appBackgrounded)
    @unknown default:
      analyticsManager.trackEvent(.appUnknown)
    }
  }
}
