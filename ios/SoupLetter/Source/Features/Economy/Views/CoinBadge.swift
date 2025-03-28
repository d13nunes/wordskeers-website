import SwiftUI

struct CoinBadge: View {
  var body: some View {
    Image("Coins")
      .renderingMode(.template)
      .resizable()
      .foregroundColor(AppColors.coinBackground)
  }
}

#if DEBUG
  #Preview {
    CoinBadge()
  }
#endif
