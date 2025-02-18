import SwiftUI

struct BoardView: View {
  let grid: [[String]]
  @Binding var selectedCells: [Position]
  @State var hintPositions: [Position] = []
  typealias GetCellColor = (_ position: Position, _ isSelected: Bool) -> Color

  let geometry: GeometryProxy
  let getCellColor: GetCellColor
  let onDragEnd: ([Position]) -> Void

  @GestureState private var dragLocation: CGPoint?

  var body: some View {
    let gridSize = grid.count
    let spacing: CGFloat = CGFloat(getSpacing(for: gridSize))
    let availableWidth = min(geometry.size.width, geometry.size.height)
    let cellSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)
    Grid(horizontalSpacing: spacing, verticalSpacing: spacing) {
      ForEach(0..<gridSize, id: \.self) { row in
        GridRow {
          ForEach(0..<gridSize, id: \.self) { col in
            createLetterView(row: row, col: col, size: cellSize)
          }
        }
      }
    }
    .gesture(dragGesture(in: geometry))
  }

  private func createLetterView(row: Int, col: Int, size: CGFloat) -> some View {

    let position = Position(row: row, col: col)
    let isSelected = selectedCells.contains(position)
    let state = getState(row: row, col: col)
    let color = getCellColor(position, isSelected)
    let letter = grid[row][col]
    return LetterCell(
      size: size,
      state: state,
      cornerRadius: 0,
      color: color,
      letter: letter
    )
  }

  private func getState(row: Int, col: Int) -> LetterCellState {
    let position = Position(row: row, col: col)
    if hintPositions.contains(position) {
      return .hint
    } else if selectedCells.contains(position) {
      return .selected
    }
    return .none
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
    let gridSize = grid.count
    let spacing: CGFloat = CGFloat(getSpacing(for: gridSize))
    let availableWidth = min(geometry.size.width, geometry.size.height)
    let cellSize = (availableWidth - (spacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)

    let row = Int((point.y) / (cellSize + spacing))
    let col = Int((point.x) / (cellSize + spacing))

    guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return }

    let coordinate = Position(row: row, col: col)
    if selectedCells.isEmpty {
      selectedCells = [coordinate]
    } else if let lastCell = selectedCells.last,
      coordinate != lastCell,
      abs(coordinate.row - lastCell.row) <= 1 && abs(coordinate.col - lastCell.col) <= 1
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
    onDragEnd(selectedPositions)
    selectedCells = []
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
}
#if DEBUG
  #Preview {

    struct PreviewWrapper: View {
      @State private var discoveredCells: [Position] = []
      let grid = [
        ["A", "B", "C", "D", "E", "F", "F", "F"],
        ["G", "H", "I", "J", "K", "L", "L", "L"],
        ["M", "N", "O", "P", "Q", "R", "R", "R"],
        ["S", "T", "U", "V", "W", "X", "X", "X"],
        ["Y", "Z", "A", "B", "C", "D", "D", "D"],
        ["E", "F", "G", "H", "I", "J", "J", "J"],
        ["Y", "Z", "A", "B", "C", "D", "D", "D"],
        ["E", "F", "G", "H", "I", "J", "J", "J"],
      ]

      func getCellColor(at coordinate: Position, isSelected: Bool) -> Color {
        if isSelected {
          return .blue
        } else if hintPositions.contains(coordinate) {
          return .yellow
        }
        return Color.clear
      }

      @State var clean = false
      @State var row = 0
      @State var col = 0
      @State private var hintPositions: [Position] = []
      var body: some View {
        VStack {
          Button("Hint") {
            clean.toggle()
            if clean {
              hintPositions.append(
                Position(row: row, col: col))
            } else {
              hintPositions.removeAll()
            }
            row += 1
            row %= grid.count
            col += 1
            col %= grid[0].count
          }
          GeometryReader { geometry in
            BoardView(
              grid: grid,
              selectedCells: $discoveredCells,
              hintPositions: hintPositions,
              geometry: geometry,
              getCellColor: getCellColor,
              onDragEnd: { _ in }
            )
          }

          .padding(.horizontal)
        }
      }
    }

    return PreviewWrapper()
  }
#endif

extension View {
  typealias WiggleProperties = (angleDegree: CGFloat, scale: CGFloat)

  func wiggle(trigger: Bool) -> some View {
    let totalDuration = 1.0
    return self.keyframeAnimator(
      initialValue: WiggleProperties(0, 1),
      repeating: trigger
    ) { content, value in
      content
        .rotationEffect(.degrees(value.angleDegree))
        .scaleEffect(.init(width: 1, height: value.scale), anchor: .bottom)
    } keyframes: { _ in
      KeyframeTrack(\.angleDegree) {
        SpringKeyframe(0, duration: 0.2 * totalDuration)
        CubicKeyframe(10, duration: 0.2 * totalDuration)
        CubicKeyframe(-10, duration: 0.6 * totalDuration)
        CubicKeyframe(10, duration: 0.25 * totalDuration)
        SpringKeyframe(0, duration: 0.25 * totalDuration)
      }

      KeyframeTrack(\.scale) {
        CubicKeyframe(0.9, duration: 0.2 * totalDuration)
        CubicKeyframe(1.2, duration: 0.4 * totalDuration)
        CubicKeyframe(0.95, duration: 0.4 * totalDuration)
        CubicKeyframe(1, duration: 0.5 * totalDuration)
      }
    }
  }
}
