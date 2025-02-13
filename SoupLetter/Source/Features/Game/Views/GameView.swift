import SwiftUI

/// The main game view
struct GameView: View {
  @Bindable private var viewModel: GameViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var selectedCells: [(Int, Int)] = []
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
          selectedCells: $selectedCells,
          geometry: geometry,
          cellColor: viewModel.cellColor,
          onDragEnd: { selectedPositions in
            Task {
              if viewModel.checkIfIsWord(in: selectedPositions) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
              }
            }
          }
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
      if viewModel.showingPauseMenu {
        PauseMenuView(
          showingPauseMenu: $viewModel.showingPauseMenu,
          onResumeClicked: {
            print("resume clicked")
            viewModel.hidePauseMenu()
            viewModel.resumeGame()
          },
          onNewGameClicked: {
            print("new game clicked")
            viewModel.hidePauseMenu()
            viewModel.startNewGame()
          }
        )
      }
      if viewModel.showingCompletionView {
        CompletionView(
          formattedTime: viewModel.formattedTime,
          onNextLevel: {
            viewModel.startNewGame()
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
#Preview {
  GameView(viewModel: getViewModel(gridSize: 5, wordCount: 5))
}
