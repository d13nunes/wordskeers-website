import SwiftUI

/// The main game view
struct GameView: View {
  @Bindable private var viewModel: GameViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var hintCell: Position?
  @State private var showingToast = false
  @State private var toastMessage = ""
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
          grid: viewModel.grid,
          hintPositions: viewModel.hintPositions,
          selectionHandler: viewModel.selectionHandler,
          geometry: geometry,
          getCellColor: { viewModel.cellColor(at: $0, isSelected: $1) }
        )
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(Color(.systemBackground))
    .overlay(alignment: .top) {
      if showingToast {
        toastView
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
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

  // MARK: - Toast View

  private var toastView: some View {
    Text(toastMessage)
      .font(.subheadline)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
      .background {
        Capsule()
          .fill(Color(.systemBackground))
          .shadow(radius: 5)
      }
      .padding(.top, 10)
  }

  private func showToast(_ message: String) {
    toastMessage = message
    withAnimation {
      showingToast = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        showingToast = false
      }
    }
  }
}

#if DEBUG
  #Preview {
    GameView(viewModel: getViewModel(gridSize: 15, wordCount: 15))
  }
#endif
