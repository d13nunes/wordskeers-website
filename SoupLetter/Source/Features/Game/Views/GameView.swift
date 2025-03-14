import SwiftUI

/// The main game view
struct GameView: View {
  @Bindable private var viewModel: GameViewModel
  @Environment(\.scenePhase) private var scenePhase

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        VStack(alignment: .leading, spacing: 12) {
          ScoreView(viewModel: viewModel)
          BoardView(viewModel: viewModel)
          if viewModel.powerUpManager.powerUps.isEmpty {
            HStack {
              Spacer()
              PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
            }
          } else {
            HStack {
              PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
              Spacer()
              PowerUpsStackView(viewModel: viewModel)
            }
          }
        }
      }
      .frame(maxHeight: .infinity, alignment: .bottom)  // Forces alignment at bottom
      .padding(.horizontal)
      .padding(.vertical)
      .overlay {
        ZStack {
          if let newGameViewModel = viewModel.newGameSelectionViewModel {

            NewGameSelectionView(viewModel: newGameViewModel)
          }
          if viewModel.isShowingPauseMenu {
            PauseMenuView(
              onResumeClicked: {
                viewModel.hidePauseMenu()
                viewModel.resumeGame()
              },
              onNewGameClicked: {
                viewModel.hidePauseMenu()
                guard let viewController = UIApplication.shared.rootViewController() else {
                  return
                }
                Task.detached {
                  await viewModel.startNewGame(on: viewController)
                }
              }
            )
          }
          if viewModel.isShowingCompletionView {
            CompletionView(
              formattedTime: viewModel.getGameOverViewFormattedTime(),
              onNextLevel: {
                guard let viewController = UIApplication.shared.rootViewController() else {
                  return
                }

                Task.detached {
                  await viewModel.completionCollectCoins(double: false, on: viewController)
                }
              },
              doubleRewardWithAd: {
                guard let viewController = UIApplication.shared.rootViewController() else {
                  return
                }
                Task.detached {
                  await viewModel.completionCollectCoins(double: true, on: viewController)
                }
              }
            )
          }
          CoinsToastView(
            coinAmount: viewModel.coinsToastAmount,
            isVisible: $viewModel.showCoinsToast
          )

        }
      }

      if viewModel.canShowBannerAd {
        // Banner Ad at the bottom with fixed size
        StandardBannerView()
          .frame(height: 50)
          .background(Color(.systemBackground))
      }
    }
    .sheet(isPresented: $viewModel.isShowingStoreView) {
      let message = viewModel.showNotEnoughCoinsAlert

      CoinStoreView(
        showNotEnoughCoinsMessage: message,
        storeService: viewModel.storeService,
        wallet: viewModel.wallet,
        analytics: viewModel.analytics
      )
      .onAppear {
        viewModel.showNotEnoughCoinsAlert = false
      }
    }
    .sheet(isPresented: $viewModel.isShowingDailyRewardsView) {
      NavigationStack {
        DailyRewardsView(
          viewModel: DailyRewardsViewModel(
            rewardsService: viewModel.dailyRewardsService
          )
        )
      }
    }
    .onAppear {
      viewModel.onViewAppear()
    }
    .onDisappear {
      viewModel.onViewDisappear()
    }
    .onChange(of: scenePhase) { _, newPhase in
      switch newPhase {
      case .active:
        viewModel.onViewAppear()
      default:
        viewModel.onViewDisappear()
      }
    }
  }
}

// MARK: - Toast View

#if DEBUG
  #Preview {
    GameView(
      viewModel: getViewModel(
        gridSize: 3, wordCount: 20
      ))
  }
#endif
