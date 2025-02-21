import SwiftUI

enum DirectionsViewStyle: CaseIterable {
  case horizontal
  case vertical
  case square
}

struct DirectionsView: View {
  let style: DirectionsViewStyle

  @State var directions: [Direction]

  var body: some View {
    switch style {
    case .square:
      squareButton
    case .horizontal:
      horizontalButton
    case .vertical:
      verticalButton
    }
  }

  private var squareButton: some View {
    HStack {
      VStack {
        directionGroupButton(for: Directions.directionGroups[0])
        directionGroupButton(for: Directions.directionGroups[1])
      }
      VStack {
        directionGroupButton(for: Directions.directionGroups[2])
        directionGroupButton(for: Directions.directionGroups[3])
      }
    }
  }

  private var horizontalButton: some View {
    HStack {
      ForEach(directions, id: \.self) { direction in
        Text(Directions.getSymbol(for: direction))
      }
    }
  }

  private var verticalButton: some View {
    VStack {
      ForEach(directions, id: \.self) { direction in
        Text(Directions.getSymbol(for: direction))
      }
    }
  }

  private func directionGroupButton(for directionGroup: [Direction]) -> some View {
    let isSelected = directionGroup.allSatisfy { directions.contains($0) }

    return Text(directionGroup.map { Directions.getSymbol(for: $0) }.joined(separator: " "))
      .background(isSelected ? .blue : .clear)

  }
}

#Preview {
  DirectionsView(
    style: .horizontal,
    directions: [
      Directions.up,
      Directions.down,
      Directions.left,
      Directions.right,
    ]
  )
}
