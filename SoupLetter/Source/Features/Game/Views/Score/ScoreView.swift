import SwiftUI

struct ScoreView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @State var viewModel: GameViewModel

  var powerUps: [PowerUp] {
    viewModel.powerUpManager.powerUps
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
        HStack(alignment: .center, spacing: 12) {
          Spacer()
          Text(viewModel.formattedTime)
            .monospacedDigit()
            .bold()
            .font(.system(size: 32))
          PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
        }
        createWordsListView(isCompact: true)
      }
    } else {
      VStack(alignment: .leading, spacing: 24) {
        createWordsListView(isCompact: false)
        VStack(alignment: .trailing, spacing: 6) {
          HStack(alignment: .center, spacing: 12) {
            Text(viewModel.formattedTime)
              .monospacedDigit()
              .bold()
              .font(.system(size: 54))
            PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
          }
          PowerUpsStackView(viewModel: viewModel)
        }
      }
      .padding(.horizontal)
    }
  }

  private var scoreTitle: String {
    "\(viewModel.gameConfiguration.category)".capitalized
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
}

#if DEBUG
  #Preview {
    ScoreView(
      viewModel: getViewModel(gridSize: 15, wordCount: 10)
    )
    .padding(.horizontal)

  }
#endif
