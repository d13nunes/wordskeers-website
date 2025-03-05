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

  private var analyticsManager: AnalyticsManager
  private let adManager: AdManaging

  init() {
    let analyticsProvider = FirebaseAnalyticsManager()
    self.analyticsManager = AnalyticsManager(provider: analyticsProvider)
    self.adManager = AdManager(
      analyticsManager: analyticsManager,
      consentService: AdvertisingConsentService()
    )
    self.wordStore = WordListStore()

    self.gameConfigurationFactory = GameConfigurationFactoryV2()
    let configuration = gameConfigurationFactory.createConfiguration(difficulty: .easy)
    self.gameViewModel = GameViewModel(
      gameManager: GameManager(gridGenerator: configuration),
      gameConfigurationFactory: gameConfigurationFactory,
      adManager: adManager,
      analytics: analyticsManager
    )

  }

  private let wordStore: WordListStore
  private let gameConfigurationFactory: GameConfigurationFactoring
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
      if firstTime, case .active = newPhase {
        Task {
          await adManager.onAppActive()
        }
      }
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
