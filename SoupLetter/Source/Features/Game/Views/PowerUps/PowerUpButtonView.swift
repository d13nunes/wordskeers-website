import SwiftUI

struct PowerUpButtonView: View {
  let enabled: Bool
  let icon: String
  let price: String
  let onClicked: () -> Void

  var isDisabled: Bool {
    !enabled
  }

  var body: some View {
    ZStack {
      Button(action: onClicked) {
        Image(systemName: icon)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
          .padding(.all, 8)
      }
      .buttonStyle(.borderedProminent)
      .disabled(isDisabled)
      .animation(.easeIn(duration: 0.34), value: isDisabled)
      Text(price)
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.all, 4)
        .background(Color.white.opacity(0.1))
        .cornerRadius(4)
        .offset(x: 24, y: 18)
    }
  }
}

#if DEBUG
  #Preview {
    PowerUpButtonView(enabled: true, icon: "lightbulb.fill", price: "100") {
      print("clicked")
    }
  }
#endif
