import SwiftUI

/// A view that displays the player's coin balance
struct CoinBalanceView: View {
  let wallet: Wallet
  var onBuyPressed: (() -> Void)

  var body: some View {
    Button(action: {
      onBuyPressed()
    }) {
      HStack(spacing: 8) {
        // Coin icon
        Image(systemName: "coin.fill")
          .font(.headline)
          .foregroundStyle(.yellow)

        // Coin amount
        Text("\(wallet.coins)")
          .font(.title)
          .fontWeight(.semibold)
        Spacer()
          .frame(width: 4)
        // Buy button
        Image(systemName: "plus.circle.fill")
          .font(.headline)
          .foregroundStyle(.green)
          .accessibilityLabel("Buy more coins")

      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background {
        Capsule()
          .fill(Color(.secondarySystemBackground))
      }
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
