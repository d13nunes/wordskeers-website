import SwiftUI

struct BoardView: View {
  typealias GetCellColor = (_ position: Position, _ isSelected: Bool) -> Color

  let grid: [[String]]
  @State var hintPositions: [Position] = []
  @State var selectionHandler: SelectionHandler

  let geometry: GeometryProxy
  let getCellColor: GetCellColor

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
    let isHint = hintPositions.contains(position)
    let isSelected = !isHint && selectionHandler.selectedCells.contains(position)
    let color = getCellColor(position, isSelected)
    let letter = grid[row][col]
    return LetterCell(
      size: size,
      cornerRadius: 0,
      color: color,
      letter: letter
    )
    .scaleEffect(isSelected ? 1.05 : 1)
    .animation(.spring(response: 0.3), value: isSelected)
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
    _ = selectionHandler.handleDrag(at: position)
  }

  private func handleDragEnd() {
    selectionHandler.endDrag()
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
    let gridSize = grid.count
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
  #Preview {

    struct PreviewWrapper: View {
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
          let selectionHandler = SelectionHandler(
            allowedDirections: Directions.all,
            gridSize: grid.count
          )
          GeometryReader { geometry in
            BoardView(
              grid: grid,
              hintPositions: hintPositions,
              selectionHandler: selectionHandler,
              geometry: geometry,
              getCellColor: getCellColor
            )
          }

          .padding(.horizontal)
        }
      }
    }

    return PreviewWrapper()
  }
#endif
