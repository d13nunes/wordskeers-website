import SwiftUI

struct PauseButtonView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let onPauseClicked: () -> Void

  var body: some View {

    Button(action: onPauseClicked) {
      VStack(spacing: 0) {
        Image("Pause")
          .resizable()
          //.renderingMode(.template)
          .foregroundColor(.black)
          .frame(width: 15, height: 24)
          .padding(.top, 8)
          .padding(.bottom, 6)
        Text("Pause")
          .font(
            Font.custom("Inter", size: 10)
              .weight(.medium)
          )
          .multilineTextAlignment(.center)
          .foregroundColor(.black)
      }
      .padding(.bottom, 6)
      .frame(width: 70, height: 57)
      .background(.white)
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
