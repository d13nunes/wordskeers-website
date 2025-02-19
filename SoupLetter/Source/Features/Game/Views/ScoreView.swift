import SwiftUI

struct ScoreView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
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
    if horizontalSizeClass == .compact {
      VStack(alignment: .trailing) {
        createWordsListView(isCompact: true)
        HStack(alignment: .bottom) {
          Text(viewModel.formattedTime)
            .monospacedDigit()
            .bold()
            .font(.system(size: 54))
            .offset(y: 8)
          Spacer()
          createButtons()
        }
      }
    } else {
      HStack(alignment: .top, spacing: 24) {
        createWordsListView(isCompact: false)
        VStack(alignment: .trailing) {
          HStack(alignment: .lastTextBaseline) {
            Text(viewModel.formattedTime)
              .monospacedDigit()
              .bold()
              .font(.system(size: 42))
          }
          createButtons()
        }
      }
      .padding(.horizontal)
    }

  }

  private func createButtons() -> some View {
    HStack(alignment: .top, spacing: 16) {
      HintButtonView(enabled: canRequestHint, onHintClicked: onHintClicked)
      PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
    }
  }

  private func createWordsListView(isCompact: Bool) -> some View {
    VStack(alignment: .leading, spacing: isCompact ? 6 : 16) {
      Text(
        "Words (\(foundWordsCount)/\(totalWordsCount))"
      )
      .bold()
      .font(.title)
      WordListView(viewModel: viewModel)
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
    ScoreView(viewModel: getViewModel(gridSize: 15, wordCount: 25)).padding(.horizontal)

  }
#endif
