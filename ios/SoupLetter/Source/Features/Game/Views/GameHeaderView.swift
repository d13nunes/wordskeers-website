import SwiftUI

struct GameHeaderView: View {
  let viewModel: GameViewModel

  var body: some View {
    HStack(alignment: .top) {
      Spacer()
      if viewModel.showDailyRewardsBadge {
        DailyRewardBadge(animate: true, onPressed: viewModel.showDailyRewardsView)
      }
      CoinBalanceView(wallet: viewModel.wallet, onBuyPressed: viewModel.showStoreView)
    }
  }
}

#if DEBUG
  #Preview {
    ZStack {
      AppColors.background
        .ignoresSafeArea()
      GameHeaderView(
        viewModel: getViewModel(gridSize: 1, wordCount: 1)
       )
      .padding(.horizontal)
    }
  }
#endif
