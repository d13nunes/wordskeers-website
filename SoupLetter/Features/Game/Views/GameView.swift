import SwiftUI

/// The main game view
struct GameView: View {
  @Bindable private var viewModel: GameViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @GestureState private var dragLocation: CGPoint?
  @State private var selectedCells: [(Int, Int)] = []
  @State private var showingPauseMenu = false
  @State private var showingCompletionView = false
  @State private var lastValidWord: String?
  @State private var showingToast = false
  @State private var toastMessage = ""

  init(viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 20) {
        // Game stats header
        gameHeader
          .padding(.horizontal)

        // Letter grid
        letterGrid(in: geometry)
          .padding(.horizontal)

        // Found words list
        foundWordsList
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
        if showingPauseMenu {
          PauseMenuView(showingPauseMenu: $showingPauseMenu, onResume: viewModel.resumeGame)
        }
        if showingCompletionView {
          CompletionView(
            formattedTime: viewModel.formattedTime,
            onNextLevel: {
              showingCompletionView = false
              viewModel.startNextLevel()
            }
          )
        }
      }
      .onChange(of: viewModel.gameState) { _, newState in
        if newState == .complete {
          withAnimation {
            showingCompletionView = true
          }
        }
      }
      .onAppear {
        viewModel.startGame()
      }
    }
  }

  // MARK: - Game Header

  private var gameHeader: some View {
    HStack {
      Text(viewModel.formattedTime)
        .font(.headline)
        .monospacedDigit()

      Spacer()

      Button {
        withAnimation {
          showingPauseMenu = true
          viewModel.pauseGame()
        }
      } label: {
        Image(systemName: "pause.circle.fill")
          .font(.title)
      }
      .accessibilityLabel("Pause game")
    }
  }

  // MARK: - Letter Grid

  private func letterGrid(in geometry: GeometryProxy) -> some View {
    let gridSize = viewModel.grid.count
    let spacing: CGFloat = 8
    let availableWidth = min(geometry.size.width - 40, geometry.size.height - 200)
    let cellSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)

    return Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
      ForEach(0..<gridSize, id: \.self) { row in
        GridRow {
          ForEach(0..<gridSize, id: \.self) { col in
            letterCell(at: (row, col), size: cellSize)
          }
        }
      }
    }
    .gesture(dragGesture(in: geometry))
  }

  private func letterCell(at coordinate: (Int, Int), size: CGFloat) -> some View {
    let isSelected = selectedCells.contains(where: { $0 == coordinate })
    let letter = String(viewModel.grid[coordinate.0][coordinate.1])

    return Text(letter)
      .font(.system(size: size * 0.5, weight: .bold, design: .rounded))
      .frame(width: size, height: size)
      .background {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.systemBackground))
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
      }
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.accentColor, lineWidth: 2)
      }
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .fill(viewModel.cellColor(for: coordinate, isSelected: isSelected))
      }
      .scaleEffect(viewModel.cellScale(for: coordinate, isSelected: isSelected))
      .animation(.spring(response: 0.3), value: isSelected)
  }

  // MARK: - Found Words List

  private var foundWordsList: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Found Words (\(viewModel.foundWordCount)/\(viewModel.totalWords))")
        .font(.headline)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(viewModel.foundWords, id: \.self) { word in
            Text(word)
              .font(.subheadline)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background {
                Capsule()
                  .fill(Color.green.opacity(0.2))
              }
              .overlay {
                Capsule()
                  .stroke(Color.green, lineWidth: 1)
              }
          }
        }
        .padding(.horizontal, 4)
      }
      .frame(height: 40)
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

  // MARK: - Gesture Handling

  private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .updating($dragLocation) { value, state, _ in
        state = value.location
      }
      .onChanged { value in
        handleDrag(at: value.location, in: geometry)
      }
      .onEnded { _ in
        handleDragEnd()
      }
  }

  private func handleDrag(at point: CGPoint, in geometry: GeometryProxy) {
    let gridSize = viewModel.grid.count
    let spacing: CGFloat = 8
    let availableWidth = min(geometry.size.width - 40, geometry.size.height - 200)
    let cellSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)

    let row = Int((point.y) / (cellSize + spacing))
    let col = Int((point.x) / (cellSize + spacing))

    guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return }

    let coordinate = (row, col)

    if selectedCells.isEmpty {
      selectedCells = [coordinate]
    } else if let lastCell = selectedCells.last,
      coordinate != lastCell,
      abs(coordinate.0 - lastCell.0) <= 1 && abs(coordinate.1 - lastCell.1) <= 1
    {
      if selectedCells.count > 1 && coordinate == selectedCells[selectedCells.count - 2] {
        selectedCells.removeLast()
      } else if !selectedCells.contains(where: { $0 == coordinate }) {
        selectedCells.append(coordinate)
      }
    }
  }

  private func handleDragEnd() {
    guard !selectedCells.isEmpty else { return }
    let selectedPositions = selectedCells

    Task {
      if viewModel.checkIfIsWord(in: selectedPositions) {
        // TODO run animation
        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
      }
    }
    selectedCells = []
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
  let configuration = GameConfiguration(gridSize: 10, words: ["Hello", "World"])
  let gameManager = GameStateManager(configuration: configuration)
  GameView(viewModel: GameViewModel(gameManager: gameManager))
}
