import SwiftUI

struct ScoreView: View {
  @State var viewModel: GameViewModel

  var foundWordsCount: Int {
    viewModel.foundWordCount
  }

  var totalWordsCount: Int {
    viewModel.totalWords
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(
          "Found Words (\(foundWordsCount)/\(totalWordsCount))"
        )
        .font(.headline)
        Text(viewModel.formattedTime)
        Spacer()
        Button(action: {
          viewModel.showHint()
        }) {
          Image(systemName: "lightbulb.fill")
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.canRequestHint == false)

        Button(action: viewModel.onShowPauseMenu) {
          Image(systemName: "pause.circle.fill")
        }
        .buttonStyle(.borderedProminent)
      }
      WordListView(viewModel: viewModel)
    }

    .padding(.all)
  }
}
#if DEBUG
  #Preview {
    ScoreView(viewModel: getViewModel(gridSize: 5, wordCount: 5))
  }
#endif
