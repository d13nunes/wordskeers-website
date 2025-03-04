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
      VStack(alignment: .leading, spacing: 24) {
        createWordsListView(isCompact: true)
        HStack(alignment: .bottom) {
          Text(viewModel.formattedTime)
            .monospacedDigit()
            .bold()
            .font(.system(size: 54))
          Spacer()
          createButtons()
        }
      }
    } else {
      VStack(alignment: .leading, spacing: 24) {
        createWordsListView(isCompact: false)
        HStack(alignment: .bottom) {
          Text(viewModel.formattedTime)
            .monospacedDigit()
            .bold()
            .foregroundStyle(.primary.opacity(0.8))
            .font(.system(size: 64))
          Spacer()
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

  private var scoreTitle: String {
    "\(viewModel.gameConfiguration.subCategory)".capitalized
  }
  private var progress: Double {
    Double(foundWordsCount) / Double(totalWordsCount)
  }

  private func createWordsListView(isCompact: Bool) -> some View {
    VStack(alignment: .leading, spacing: isCompact ? 6 : 16) {
      Text(scoreTitle)
        .bold()
        .font(.title)
      WordListView(viewModel: viewModel)
    }
  }

  private func onHintClicked() {
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
    ScoreView(
      viewModel: getViewModel(gridSize: 15, wordCount: 10)
    )
    .padding(.horizontal)

  }
#endif
