import SwiftUI

struct DirectionToggleView: View {
  @State var viewModel: GameModeSelectionViewModel

  var body: some View {
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

  private func directionGroupButton(for directionGroup: [Direction]) -> some View {
    let isSelected = directionGroup.allSatisfy { viewModel.allowedDirections.contains($0) }
    return Button {
      directionGroup.forEach { viewModel.toggleDirection($0) }
    } label: {
      Text(directionGroup.map { Directions.getSymbol(for: $0) }.joined(separator: " "))
    }
    .background(isSelected ? .blue : .clear)

  }
}

#Preview {
  DirectionToggleView(viewModel: GameModeSelectionViewModel())
}
