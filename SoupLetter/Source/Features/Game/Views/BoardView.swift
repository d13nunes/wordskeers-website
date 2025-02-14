import SwiftUI

struct BoardView: View {
  let grid: [[String]]
  @Binding var selectedCells: [(Int, Int)]
  let geometry: GeometryProxy
  let cellColor: ((Int, Int), Bool) -> Color
  let onDragEnd: ([(Int, Int)]) -> Void

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
            letterCell(at: (row, col), size: cellSize)
          }
        }
      }
    }
    .gesture(dragGesture(in: geometry))
    .onAppear {
      print("selectedCells: \(selectedCells)")
      print("grid: \(geometry.size)")
      print("grid: \(geometry.frame(in: .local))")
    }

  }

  private func letterCell(at coordinate: (Int, Int), size: CGFloat) -> some View {
    let isSelected = selectedCells.contains(where: { $0 == coordinate })
    let letter = String(grid[coordinate.0][coordinate.1])
    let cornerRadius = size * 0.15

    return Text(letter)
      .font(.system(size: size * 0.7, weight: .bold, design: .rounded))
      .frame(width: size, height: size)
      .background {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(cellColor(coordinate, isSelected))
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
      }
      // .overlay {
      //   RoundedRectangle(cornerRadius: cornerRadius)
      //     .stroke(Color.accentColor, lineWidth: 2)
      // }
      .scaleEffect(isSelected ? 1.05 : 1)
      .animation(.spring(response: 0.3), value: isSelected)
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
      @State private var selectedCells: [(Int, Int)] = []
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

      func cellColor(at coordinate: (Int, Int), isSelected: Bool) -> Color {
        isSelected ? Color.blue : Color.clear
      }

      var body: some View {
        GeometryReader { geometry in
          BoardView(
            grid: grid,
            selectedCells: $selectedCells,
            geometry: geometry,
            cellColor: cellColor,
            onDragEnd: { _ in }
          )
        }
        .padding(.horizontal)
      }
    }

    return PreviewWrapper()
  }
#endif
