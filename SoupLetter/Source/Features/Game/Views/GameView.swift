import SwiftUI

/// The main game view
struct GameView: View {
  @Bindable private var viewModel: GameViewModel
  @Environment(\.scenePhase) private var scenePhase

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    VStack(alignment: .trailing, spacing: 12) {
      ScoreView(viewModel: viewModel)
        .padding(.horizontal)
      GeometryReader { geometry in
        BoardView(
          viewModel: viewModel,
          geometry: geometry
        )
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(Color(.systemBackground))
    .overlay {
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
          formattedTime: viewModel.formattedTime,
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
      if viewModel.isShowingHintPopup {
        HintPopupView(
          onDismissedClicked: {
            viewModel.hideHintPopup()
          },
          onShowHintClicked: {
            guard let viewController = UIApplication.shared.rootViewController() else {
              return
            }
            Task.detached {
              await viewModel.requestHint(on: viewController)
            }
          }
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
    GameView(viewModel: getViewModel(gridSize: 5, wordCount: 2))
  }
#endif
