import SwiftUI

struct DailyRewardBadge: View {
  @State var animate: Bool
  var onPressed: () -> Void

  @State private var scale: CGFloat = 1.0

  var body: some View {
    Button(action: onPressed) {
      Image(systemName: "gift.fill")
        .font(.system(size: 26))
        .foregroundColor(.red)
        .padding(8)
        .background(
          Circle()
            .fill(Color(.secondarySystemBackground))
        )
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: scale)
        .onAppear {
          if animate {
            scale = 1.15
          }
        }
        .onChange(of: animate) { _, newValue in
          scale = newValue ? 1.15 : 1.0
        }
    }
    .accessibilityLabel("Daily Rewards")
  }
}

#if DEBUG
  #Preview {
    DailyRewardBadge(animate: true, onPressed: { print("Pressed") })
  }
#endif
