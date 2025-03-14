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
        .fontWeight(.bold)
        .foregroundColor(.white)
        .padding(.all, 4)
        .background(.yellow)
        .cornerRadius(6)
        .offset(x: 22, y: 20)
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
