import SwiftUI

struct NewGameSelectionView: View {
  @State var viewModel: NewGameSelectionViewModel

  var body: some View {
    MenuView("Classic", subtitle: "Game Mode") {
      VStack(alignment: .center) {
        gameDifficultyInfoSection
        // Text("Game Difficulty")
        //   .font(.headline)
        Picker(selection: $viewModel.selectedDifficulty, label: Text("Difficulty")) {
          ForEach(viewModel.availableDifficulties, id: \.self) { difficulty in
            Text(difficulty.rawValue).tag(difficulty)
          }
        }.pickerStyle(.segmented)
          .frame(maxWidth: 400)
        playButton
          .padding(.top, 32)
      }
    }
  }

  private var gameDifficultyInfoSection: some View {
    VStack(alignment: .center, spacing: 0) {

      VStack(alignment: .center, spacing: 0) {
        Text("Find ")
          + Text("\(viewModel.selectedWordsCount) words")
          .bold()
          + Text(" in a ")
          + Text("\(viewModel.selectedGridSize)x\(viewModel.selectedGridSize)")
          .bold()
          + Text(" grid")
        Text("Words can be found in ")
          + Text(
            viewModel.selectedValidDirections
              .map { Directions.getSymbol(for: $0) }
              .joined(separator: " ")
          )
          .bold()
      }
    }
  }

  private var titleSection: some View {
    VStack(alignment: .center) {
      Text("Classic")
        .font(.largeTitle.bold())
        .padding(.top)
      Text("Game Mode")
        .font(.subheadline)
        .padding(.bottom)
    }
  }

  private var difficultySettingsSection: some View {
    GeometryReader { geometry in
      VStack(alignment: .center, spacing: 16) {
        HStack(alignment: .firstTextBaseline) {
          Text("Grid Size")
            .font(.subheadline)
            .frame(width: geometry.size.width / 2, alignment: .trailing)
          Text("\(viewModel.selectedGridSize)x\(viewModel.selectedGridSize)")
            .font(.headline)
            .frame(width: geometry.size.width / 2, alignment: .leading)
        }
        HStack(alignment: .firstTextBaseline) {
          Text("Word Count")
            .font(.subheadline)
            .frame(width: geometry.size.width / 2, alignment: .trailing)
          Text("\(viewModel.selectedWordsCount)")
            .font(.headline)
            .frame(width: geometry.size.width / 2, alignment: .leading)
        }
        HStack(alignment: .firstTextBaseline) {
          Text("Directions")
            .font(.subheadline)
            .frame(width: geometry.size.width / 2, alignment: .trailing)
          HStack(spacing: 2) {
            ForEach(viewModel.selectedValidDirections, id: \.self) { direction in
              Text(Directions.getSymbol(for: direction))
                .font(.headline)
                .padding(4)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
          }
          .frame(width: geometry.size.width / 2, alignment: .leading)
        }
      }
    }
    .frame(height: 108)
  }

  private var playButton: some View {
    MyButton(
      title: "Play",
      style: .destructive,
      action: viewModel.startGame)
  }

}

#Preview {
  NewGameSelectionView(
    viewModel: NewGameSelectionViewModel(
      onStartGame: { setting in
        print("Starting game with setting: \(setting)")
      }
    ))
}
