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
    createWordsListView(isCompact: true)
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
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .roundedContainer()
  }

  private func createWordsListView(isCompact: Bool) -> some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: isCompact ? 6 : 16) {
        HStack(alignment: .bottom) {
          Text(scoreTitle)
            .font(
              Font.custom("Inter", size: 32)
                .weight(.bold)
            )
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .frame(maxHeight: 44, alignment: .leading)
          Spacer()
          timerView
          PauseButtonView(onPauseClicked: viewModel.onShowPauseMenu)
        }
        WordListView(viewModel: viewModel, geometry: geometry)
      }
    }
  }
}

#if DEBUG
  #Preview {
    ZStack {
      AppColors.background
      ScoreView(
        viewModel: getViewModel(gridSize: 15, wordCount: 10)
      )
      .padding(.horizontal)
    }
  }
#endif
