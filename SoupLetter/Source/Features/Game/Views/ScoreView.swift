import SwiftUI

struct ScoreView: View {
  @State var viewModel: GameViewModel

  var canRequestHint: Bool {
    viewModel.canRequestHint
  }

  var foundWordsCount: Int {
    viewModel.foundWordCount
  }

  var totalWordsCount: Int {
    viewModel.totalWords
  }

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading) {
        Text(
          "Words (\(foundWordsCount)/\(totalWordsCount))"
        )
        .bold()
        .font(.title)
        WordListView(viewModel: viewModel)
      }
      Spacer()
      HStack {
        VStack(alignment: .trailing) {
          HStack(alignment: .lastTextBaseline) {
            Text("Time:")
              .bold()
              .font(.system(size: 22))
            Text(viewModel.formattedTime)
              .monospacedDigit()
              .bold()
              .font(.system(size: 42))
          }
          HStack(alignment: .top, spacing: 16) {
            Spacer()
            HintButtonView(enabled: canRequestHint, onHintClicked: onHintClicked)
            PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
          }
        }
      }
    }
  }

  private func onHintClicked() {
    viewModel.showHintPopup()
  }
  func onHintRequested() {
    viewModel.hideHintPopup()
    guard let viewController = UIApplication.shared.rootViewController() else {
      return
    }
    Task.detached {
      await viewModel.requestHint(on: viewController)
    }
  }
}
#if DEBUG
  #Preview {
    ScoreView(viewModel: getViewModel(gridSize: 5, wordCount: 5))
  }
#endif
