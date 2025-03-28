import SwiftUI

struct HintButtonView: View {
  let enabled: Bool
  let onHintClicked: () -> Void

  var isDisabled: Bool {
    !enabled
  }

  var body: some View {
    ZStack {
      Button(action: onHintClicked) {
        Image(systemName: "lightbulb.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
          .padding(.all, 8)
      }
      .buttonStyle(.borderedProminent)
      .disabled(isDisabled)
      .animation(.easeIn(duration: 0.34), value: isDisabled)
      Image(systemName: "play.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
        .foregroundColor(.green)
        .cornerRadius(4)
        .offset(x: 24, y: 18)
    }
  }
}

#if DEBUG
  #Preview {
    HintButtonView(enabled: true, onHintClicked: {})
  }
#endif
