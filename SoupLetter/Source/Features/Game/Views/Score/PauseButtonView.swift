import SwiftUI

struct PauseButtonView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let onPauseClicked: () -> Void

  private var width: CGFloat { horizontalSizeClass == .compact ? 44 : 64 }

  var body: some View {
    Button(action: onPauseClicked) {
      HStack(alignment: .center, spacing: 0) {
        Image("Pause")
      }
      .padding(.horizontal, 0)
      .padding(.vertical, 8)
      .frame(width: 42, height: 34)
      .roundedContainer()
    }
  }
}

#if DEBUG
  #Preview {
    HStack {
      HStack(spacing: 8) {
        Image("Clock")
          .frame(width: 12, height: 12)
        Text("00:00")
          .monospacedDigit()
          .font(
            Font.custom("Inter", size: 16)
              .weight(.medium)
          )
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .roundedContainer()
      PauseButtonView(onPauseClicked: {})
    }
    .background(AppColors.background)
  }
#endif
