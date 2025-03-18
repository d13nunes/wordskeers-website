import SwiftUI

struct DailyRewardBadge: View {
  @State var animate: Bool
  var onPressed: () -> Void

  @State private var scale: CGFloat = 1.0

  var body: some View {
    Button(action: onPressed) {
      HStack(alignment: .center, spacing: 8) {
        Image("Gift")
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundStyle(AppColors.red)
          .scaleEffect(scale)
          .animation(
            .easeInOut(duration: 1.0)
              .repeatForever(autoreverses: true),
            value: scale
          )
        Text("Daily Rewards")
          .font(
            Font.custom("Inter", size: 14)
              .weight(.medium)
          )
          .multilineTextAlignment(.center)
          .foregroundColor(.black)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .frame(height: 40)
      .background(.white)
      .cornerRadius(8)

      .onAppear {
        if animate {
          scale = 1.2
        }
      }
      .onChange(of: animate) { _, newValue in
        scale = newValue ? 1.2 : 0.95
      }
      .accessibilityLabel("Daily Rewards")
    }
  }
}

#if DEBUG
  #Preview {
    ZStack {
      AppColors.background
        .ignoresSafeArea()
      DailyRewardBadge(animate: true, onPressed: { print("Pressed") })
    }
  }
#endif
