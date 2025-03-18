import SwiftUI

/// The main game view
struct GameView: View {
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  @Bindable private var viewModel: GameViewModel

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {

    let isSmallScreen = isSmallScreen()
    let isCompact = horizontalSizeClass == .compact
    let horizontalPadding = isSmallScreen ? 6.0 : isCompact ? 12.0 : 120.0
    let bottomPadding = isSmallScreen ? 0.0 : isCompact ? 8.0 : 16.0
    let spacing: CGFloat = isSmallScreen ? 4 : 8

    VStack(spacing: 0) {
      VStack(spacing: 0) {
        GameHeaderView(viewModel: viewModel)

          .padding(.horizontal, 12)
        VStack(alignment: .center, spacing: spacing) {
          Spacer()
          ScoreView(viewModel: viewModel)
          BoardView(viewModel: viewModel)
            .layoutPriority(100)

          if !viewModel.powerUpManager.powerUps.isEmpty {
            HStack {
              Spacer()
              PowerUpsStackView(viewModel: viewModel)
            }
            .padding(.bottom, bottomPadding)
          }
          if !isCompact {
            Spacer()
          }
        }
        .padding(.horizontal, horizontalPadding)

        if viewModel.canShowBannerAd {
          // Banner Ad at the bottom with fixed size
          StandardBannerView()
            .frame(width: .infinity, height: 50)
        }
      }
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

    }

    .background(AppColors.background)
    .sheet(isPresented: $viewModel.isShowingStoreView) {
      let message = viewModel.showNotEnoughCoinsAlert

      CoinStoreView(
        showNotEnoughCoinsMessage: message,
        storeService: viewModel.storeService,
        wallet: viewModel.wallet,
        analytics: viewModel.analytics
      )
      .onDisappear {
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
        gridSize: 6, wordCount: 1
      ))
  }
#endif
