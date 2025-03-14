import SwiftUI

struct CoinBadge: View {
  var body: some View {
    Image(systemName: "bitcoinsign.circle.fill")
      .resizable()
      .foregroundColor(.yellow)
      .background(.white)
      .clipShape(Circle())

  }
}

#if DEBUG
  #Preview {
    CoinBadge()
  }
#endif
