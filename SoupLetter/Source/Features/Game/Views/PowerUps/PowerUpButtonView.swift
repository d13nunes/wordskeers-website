import SwiftUI

struct PowerUpButtonViewModel {
  let enabled: Bool
  let color: Color
  let icon: String
  let description: String
  let price: String

  func withPrice(_ price: Int) -> PowerUpButtonViewModel {
    return PowerUpButtonViewModel(
      enabled: enabled,
      color: color,
      icon: icon,
      description: description,
      price: "\(price)"
    )
  }

  static let hintLetter = PowerUpButtonViewModel(
    enabled: true,
    color: Color(red: 0.73, green: 0.11, blue: 0.11),
    icon: "PowerUpLetter",
    description: "Find Letter",
    price: "100"
  )

  static let hintFullWord = PowerUpButtonViewModel(
    enabled: true,
    color: Color(red: 0.05, green: 0.45, blue: 0.56),
    icon: "PowerUpWord",
    description: "Find Word",
    price: "100"
  )
  static let hintDirection = PowerUpButtonViewModel(
    enabled: true,
    color: Color(red: 0.76, green: 0.25, blue: 0.05),
    icon: "PowerUpDirection",
    description: "Direction",
    price: "100"
  )

  static let rotateBoard = PowerUpButtonViewModel(
    enabled: true,
    color: Color(red: 0.02, green: 0.47, blue: 0.34),
    icon: "PowerUpRotate",
    description: "Rotate",
    price: "100"
  )

  static func getViewModel(powerUp: PowerUp) -> PowerUpButtonViewModel {
    switch powerUp.type {
    case .hint:
      return hintLetter.withPrice(powerUp.price)
    case .fullWord:
      return hintFullWord.withPrice(powerUp.price)
    case .directional:
      return hintDirection.withPrice(powerUp.price)
    case .rotateBoard:
      return rotateBoard.withPrice(powerUp.price)
    case .none:
      return hintLetter.withPrice(powerUp.price)
    }
  }
}
struct PowerUpButtonView: View {
  let viewModel: PowerUpButtonViewModel
  let onClicked: () -> Void

  var isDisabled: Bool {
    !viewModel.enabled
  }

  var body: some View {
    Button(action: onClicked) {
      VStack(spacing: 0) {
        Image(viewModel.icon)
          .renderingMode(.template)
          .foregroundColor(viewModel.color)
          .frame(width: 14, height: 14)
          .padding(.top, 8)
          .padding(.bottom, 6)
        HStack(alignment: .center, spacing: 2) {
          CoinBadge()
            .frame(width: 8, height: 8)
          Text(viewModel.price)
            .font(Font.custom("Inter", size: 10))
            .multilineTextAlignment(.center)
            .foregroundColor(viewModel.color)
            .frame(alignment: .top)
        }
        .padding(.horizontal, 0)
        .frame(alignment: .bottom)
        Text(viewModel.description)
          .font(
            Font.custom("Inter", size: 10)
              .weight(.medium)
          )
          .multilineTextAlignment(.center)
          .foregroundColor(viewModel.color)
      }
      .padding(.bottom, 6)
      .frame(width: 70)
      .background(viewModel.color.opacity(0.1))
      .roundedCornerRadius()
    }
    .disabled(isDisabled)
    .animation(.easeIn(duration: 0.34), value: isDisabled)

  }
}

#if DEBUG
  #Preview {
    PowerUpButtonView(
      viewModel: .hintLetter
    ) {
      print("clicked")
    }
  }
#endif
