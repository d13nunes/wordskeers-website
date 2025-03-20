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

    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .bottom) {
        Text(scoreTitle)
          .font(
            Font.custom("Inter", size: 32)
              .weight(.bold)
          )
          .frame(maxHeight: isSmallScreen() ? 32 : 64, alignment: .leading)
          .multilineTextAlignment(.leading)
          .lineLimit(2)
          .minimumScaleFactor(0.3)
          .padding(.leading, 8)
          .padding(.bottom, -8)
        Spacer()
        PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
      }
      WordListView(viewModel: viewModel)
    }
  }

  private var scoreTitle: String {
    "\(viewModel.gameConfiguration.category)".capitalized
  }
  private var progress: Double {
    Double(foundWordsCount) / Double(totalWordsCount)
  }

  private var timerView: some View {
    HStack(spacing: 8) {
      Image("Clock")
        .frame(width: 12, height: 12)
      Text(viewModel.formattedTime)
        .monospacedDigit()
        .font(
          Font.custom("Inter", size: 16)
            .weight(.medium)
        )
    }
  }

}

#if DEBUG
  #Preview {
    ZStack {
      AppColors.background
      ScoreView(
        viewModel: getViewModel(gridSize: 15, wordCount: 50)
      )
      .padding(.horizontal)
    }
  }
#endif
