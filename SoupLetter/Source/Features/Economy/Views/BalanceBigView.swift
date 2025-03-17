import SwiftUI

struct BalanceBigView: View {
  let wallet: Wallet

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .center, spacing: 12) {
        CoinBadge()
          .frame(width: 24, height: 24)
        Text("\(wallet.coins)")
          .font(
            Font.custom("Inter", size: 30)
              .weight(.bold)
          )
          .multilineTextAlignment(.center)
          .foregroundColor(AppColors.storeText)
      }
      Text("Current Balance")
        .font(Font.custom("Inter", size: 14))
        .multilineTextAlignment(.center)
        .foregroundColor(Color(red: 0.42, green: 0.45, blue: 0.5))
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(25)
    .storeStyle()
  }
}
