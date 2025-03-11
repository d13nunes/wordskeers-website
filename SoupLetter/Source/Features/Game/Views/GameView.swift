import SwiftUI

/// The main game view
struct GameView: View {
  @Bindable private var viewModel: GameViewModel
  @Environment(\.scenePhase) private var scenePhase

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 12) {
        HStack {

          Spacer()
          Button {
            viewModel.showDailyRewardsView()
          } label: {
            Image(systemName: "gift.fill")
              .font(.title2)
              .foregroundColor(.yellow)
              .padding(8)
              .background(
                Circle()
                  .fill(Color.blue.opacity(0.2))
              )
          }
          .accessibilityLabel("Daily Rewards")

          CoinBalanceView(wallet: viewModel.wallet, onBuyPressed: viewModel.showStoreView)
        }
        ScoreView(viewModel: viewModel)
        BoardView(viewModel: viewModel)
        HStack {
          Spacer()
          PowerUpsStackView(viewModel: viewModel)
        }
      }
    }
    .frame(maxHeight: .infinity, alignment: .bottom)  // Forces alignment at bottom
    .padding(.horizontal)
    .padding(.vertical)
    .overlay {
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
              await viewModel.startNewGame(on: viewController)
            }
          }
        )
      }
    }.sheet(isPresented: $viewModel.isShowingStoreView) {
      let showNotEnoughCoinsMessage = viewModel.showNotEnoughCoinsAlert
      viewModel.showNotEnoughCoinsAlert = false
      return CoinStoreView(
        showNotEnoughCoinsMessage: showNotEnoughCoinsMessage,
        storeService: viewModel.storeService,
        wallet: viewModel.wallet,
        analytics: viewModel.analytics
      )
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
        gridSize: 6, wordCount: 20
      ))
  }
#endif
