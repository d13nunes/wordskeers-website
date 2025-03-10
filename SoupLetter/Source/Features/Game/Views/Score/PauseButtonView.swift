import SwiftUI

struct PauseButtonView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let onPauseClicked: () -> Void

  private var width: CGFloat { horizontalSizeClass == .compact ? 44 : 64 }

  var body: some View {
    Button(action: onPauseClicked) {
      Image(systemName: "pause.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: 44)
        .padding(.all, 8)
    }
    .buttonStyle(.borderedProminent)
  }
}
