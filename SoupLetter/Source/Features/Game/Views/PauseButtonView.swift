import SwiftUI

struct PauseButtonView: View {
  let onPauseClicked: () -> Void

  var body: some View {
    Button(action: onPauseClicked) {
      Image(systemName: "pause.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 64, height: 44)
        .padding(.all, 8)
    }
    .buttonStyle(.borderedProminent)
  }
}
