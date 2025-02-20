import SwiftUI

struct GameModeSelectionView: View {
  @State var viewModel: GameModeSelectionViewModel

  var body: some View {
    VStack(spacing: 32) {
      titleSection
      categorySection
      gridSizeSection
      wordCountSection
      directionsSection
      picker
      Spacer()
      playButton
    }
    .padding()
  }

  private var picker: some View {
    Picker(selection: $viewModel.selectedCategory, label: Text("Category")) {
      ForEach(viewModel.availableCategories, id: \.self) { category in
        Text(category).tag(category)
      }
    }.pickerStyle(.segmented)
  }

  private var titleSection: some View {
    VStack(alignment: .center) {
      Text("Game Mode")
        .font(.subheadline)
        .padding(.top)
      Text("Custom")
        .font(.largeTitle.bold())
        .padding(.bottom)
    }
  }

  private var categorySection: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Category")
        .font(.headline)
      HStack(alignment: .firstTextBaseline) {
        Text(viewModel.selectedCategory)
        Spacer()
        Button {
          viewModel.selectedCategory = viewModel.availableCategories.randomElement() ?? "Random"
        } label: {
          Image(systemName: "arrow.triangle.2.circlepath")
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom)
      }
    }
  }

  private var gridSizeSection: some View {
    VStack(alignment: .leading) {
      Text("Grid Size")
        .font(.headline)

      HStack {
        Text("\(viewModel.minGridSize)")
        Slider(
          value: .init(
            get: { Double(viewModel.gridSize) },
            set: { viewModel.gridSize = Int($0) }
          ),
          in: Double(viewModel.minGridSize)...Double(viewModel.maxGridSize),
          step: 1
        )
        .sensoryFeedback(.selection, trigger: viewModel.gridSize)
        Text("\(viewModel.maxGridSize)")
      }

      Text("Selected size: \(viewModel.gridSize)×\(viewModel.gridSize)")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  private var wordCountSection: some View {
    VStack(alignment: .leading) {
      Text("Words Count")
        .font(.headline)

      Stepper(
        value: $viewModel.wordCount,
        in: viewModel.minWordCount...viewModel.maxWordCount
      ) {
        Text("\(viewModel.wordCount) words")
      }
    }
  }

  private var directionsSection: some View {
    VStack(alignment: .leading) {
      Text("Directions")
        .font(.headline)

      DirectionToggleView(viewModel: viewModel)
    }
  }

  private var playButton: some View {
    Button(action: viewModel.startGame) {
      Text("Play")
        .font(.title3.bold())
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .padding(.top)
  }
}

#Preview {
  GameModeSelectionView(viewModel: GameModeSelectionViewModel())
}
