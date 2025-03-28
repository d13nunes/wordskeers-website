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

        MyButton(
          title: "Play",
          style: .destructive,
          action: onStartGame
        )

        .padding(.top, 32)
      }
    }.background(AppColors.background)
  }

  private var gameDifficultyInfoSection: some View {
    VStack(alignment: .center, spacing: 0) {

      VStack(alignment: .center, spacing: 0) {
        Text("Search for words in a ")
          + Text("\(viewModel.selectedGridSize)x\(viewModel.selectedGridSize)")
          .bold()
          + Text(" grid")
        Text("Words can be found in ")
          + Text(
            viewModel.selectedValidDirections
              .map { $0.symbol }
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
              Text(direction.symbol)
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

  private func onStartGame() {
    guard let viewController = self.rootViewController() else {
      return
    }
    viewModel.startGame(on: viewController)
  }
}

#if DEBUG
#Preview {
  NewGameSelectionView(
    viewModel: NewGameSelectionViewModel(
      isFirstGame: true,
      adManager: MockAdManager(),
      onStartGame: { setting in
        print("Starting game with setting: \(setting)")
      }
    ))
}
#endif
