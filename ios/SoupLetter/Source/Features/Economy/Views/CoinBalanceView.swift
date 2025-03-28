import SwiftUI

/// A view that displays the player's coin balance
struct CoinBalanceView: View {
  let wallet: Wallet
  var onBuyPressed: (() -> Void)

  var body: some View {
    Button(action: onBuyPressed) {
      HStack(spacing: 0) {
        // Coin icon
        Image("Coins")
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(AppColors.coinBackground)
          .padding(.trailing, 8)
        Text("\(wallet.coins)")
          .font(
            Font.custom("Inter", size: 16)
              .weight(.medium)
          )
          .padding(.trailing, 4)
        // Buy button
        Image(systemName: "plus.circle.fill")
          .font(.headline)
          .foregroundStyle(.green)
          .accessibilityLabel("Buy more coins")

      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .frame(height: 36)
      .roundedContainer()
    }
    .buttonStyle(.plain)
    .accessibilityLabel("Coin balance: \(wallet.coins)")
    .accessibilityElement(children: .combine)
  }
}

#if DEBUG
  #Preview {
    CoinBalanceView(wallet: Wallet.forTesting(), onBuyPressed: { print("Pressed") })
  }

#endif
