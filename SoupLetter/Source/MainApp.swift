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
  @State private var showDailyRewards = false

  private var analyticsManager: AnalyticsManager
  private let adManager: AdManaging
  private let databaseService: DatabaseService
  private let gameHistoryService: GameHistoryServicing
  init() {
    let analyticsProvider = FirebaseAnalyticsManager()
    self.analyticsManager = AnalyticsManager(provider: analyticsProvider)
    self.adManager = AdManager(
      analyticsManager: analyticsManager,
      consentService: AdvertisingConsentService()
    )
    self.wordStore = WordListStore()

    // Initialize services
    // Use try? to handle errors gracefully by providing nil if initialization fails
    // Then use nil-coalescing to provide default values or empty implementations
    self.databaseService = try! DatabaseService()
    self.gameHistoryService = try! GameHistoryService()

    self.gameConfigurationFactory = GameConfigurationFactoryV2(gridFetcher: databaseService)
    let configuration = gameConfigurationFactory.createConfiguration(
      configuration: DifficultyConfigMap.config(for: .easy))

    #if DEBUG
      let wallet = Wallet.forTesting()
    #else
      let wallet = Wallet.loadWallet()
    #endif

    self.gameViewModel = GameViewModel(
      gameManager: GameManager(gridGenerator: configuration),
      gameConfigurationFactory: gameConfigurationFactory,
      adManager: adManager,
      analytics: analyticsManager,
      gameHistoryService: gameHistoryService,
      wallet: wallet
    )

    // Listen for notification tap events
    setupNotificationObservers()
  }

  /// Set up observers for notification events
  private func setupNotificationObservers() {
    NotificationCenter.default.addObserver(
      forName: .dailyRewardNotificationTapped,
      object: nil,
      queue: .main
    ) { [self] _ in
      showDailyRewards = true
    }
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
          .onAppear {
            // Refresh daily rewards state when app launches
            gameViewModel.dailyRewardsService.refreshDailyRewards()

            // Handle auto-show of daily rewards from notification if needed
            if showDailyRewards {
              // Will need to be handled by the GameView
              gameViewModel.showDailyRewardsFromNotification = true
              showDailyRewards = false
            }
          }
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

      // Refresh the daily rewards when returning to active state
      if case .active = newPhase, !firstTime {
        gameViewModel.dailyRewardsService.refreshDailyRewards()
      }
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
