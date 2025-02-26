import SwiftUI

struct BoardView: View {
  typealias GetCellColor = (_ position: Position, _ isSelected: Bool) -> Color

  @State var viewModel: GameViewModel

  @GestureState private var dragLocation: CGPoint?
  @State private var newlySelectedCells: Set<Position> = []

  var body: some View {
    GeometryReader { geometry in

      let gridSize = viewModel.grid.count
      let spacing: CGFloat = CGFloat(getSpacing(for: gridSize))
      let availableWidth = min(geometry.size.width, geometry.size.height)
      let cellSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)
      let grid = viewModel.grid
      Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
        ForEach(0..<gridSize, id: \.self) { row in
          GridRow {
            ForEach(0..<gridSize, id: \.self) { col in
              createLetterView(grid: grid, row: row, col: col, size: cellSize)
            }
          }
        }
      }
      .gesture(dragGesture(in: geometry))
      .frame(width: geometry.size.width, height: geometry.size.width)
    }
    .aspectRatio(1, contentMode: .fit)
  }

  private func createLetterView(grid: [[String]], row: Int, col: Int, size: CGFloat) -> some View {
    let position = Position(row: row, col: col)
    let isHint = viewModel.hintManager.positions.contains(position)
    let isSelected = !isHint && viewModel.selectionHandler.selectedCells.contains(position)
    let isDiscovered = viewModel.discoveredCells.contains(position)
    let color = viewModel.cellColor(at: position, isSelected: isSelected)
    let letter = grid[row][col]
    let cornerRadius = size * 0.1
    return LetterCell(
      size: size,
      cornerRadius: cornerRadius,
      color: color,
      letter: letter,
      isDiscovered: isDiscovered
    )
    .scaleEffect(isSelected ? 1.1 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2), value: isSelected)
    .wiggle(active: isHint)
  }

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
    guard let position = convertPointToPosition(point, in: geometry) else { return }
    _ = viewModel.selectionHandler.handleDrag(at: position)
  }

  private func handleDragEnd() {
    viewModel.selectionHandler.endDrag()
  }

  private func getSpacing(for gridSize: Int) -> Int {
    let maxGridSize = 18
    let minGridSize = 6
    if gridSize <= minGridSize {
      return 8
    } else if gridSize >= maxGridSize {
      return 4
    } else {
      return 8 - ((gridSize - minGridSize) / (maxGridSize - minGridSize)) * (8 - 4)
    }
  }

  private func convertPointToPosition(_ point: CGPoint, in geometry: GeometryProxy) -> Position? {
    let gridSize = viewModel.grid.count
    let spacing: CGFloat = CGFloat(getSpacing(for: gridSize))
    let availableWidth = min(geometry.size.width, geometry.size.height)
    let cellSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)

    let row = Int((point.y) / (cellSize + spacing))
    let col = Int((point.x) / (cellSize + spacing))

    guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return nil }

    return Position(row: row, col: col)
  }
}
#if DEBUG
  struct PreviewWrapper: View {

    @State var viewModel = getViewModel(gridSize: 10, wordCount: 10)
    @State private var hintManager: HintManager = HintManager(adManager: MockAdManager())
    @State var boardSize = 10

    var body: some View {
      VStack {
        HStack {
          Button("Hint") {
            Task { @MainActor in
              let success = await viewModel.hintManager.requestHint(
                words: viewModel.words, on: UIApplication.shared.rootViewController()!
              )
              print("Hint requested: \(success)")
            }
          }
          Button("Increase Board Size") {
            boardSize += 1
            createNewGame()
          }
          Button("Decrease Board Size") {
            boardSize -= 1
            createNewGame()
          }
        }

        BoardView(viewModel: viewModel)
          .padding(.horizontal)
      }
    }

    func createNewGame() {
      let configuration = viewModel.gameConfigurationFactory.createRandomConfiguration(
        setting: GameConfigurationSetting(
          gridSize: boardSize, wordsCount: boardSize, validDirections: Directions.all)
      )
      let gameManager = GameManager(configuration: configuration)
      viewModel.createNewGame(gameManager: gameManager)
    }
  }
  #Preview {
    PreviewWrapper()
  }
#endif
