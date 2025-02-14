import SwiftUI
import UIKit

extension UIApplication {
  func rootViewController() -> UIViewController? {
    guard let windowScene = connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    else {
      return nil
    }
    return window.rootViewController
  }
}

enum ButtonStyleType {
  case passive
  case destructive
}

private struct ButtonStyleConstants {
  let cornerRadius: CGFloat = 8
  let padding: EdgeInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
}

private struct ButtonStyle {
  let backgroundColor: Color
  let foregroundColor: Color
  let cornerRadius: CGFloat
  let padding: EdgeInsets
}

private struct ButtonStyleFactory {
  static let constants = ButtonStyleConstants()
  static func style(for style: ButtonStyleType) -> ButtonStyle {
    switch style {
    case .passive:
      return ButtonStyle(
        backgroundColor: .blue,
        foregroundColor: .white,
        cornerRadius: constants.cornerRadius,
        padding: constants.padding)
    case .destructive:
      return ButtonStyle(
        backgroundColor: .red,
        foregroundColor: .white,
        cornerRadius: constants.cornerRadius,
        padding: constants.padding
      )
    }
  }
}

extension Button {
  func style(_ style: ButtonStyleType) -> some View {
    let buttonStyle = ButtonStyleFactory.style(for: style)
    return self.background(buttonStyle.backgroundColor)
      .foregroundColor(buttonStyle.foregroundColor)
      .cornerRadius(buttonStyle.cornerRadius)
      .padding(buttonStyle.padding)
  }
}

struct MyButton: View {
  private let title: String
  private let style: ButtonStyle
  private let action: () -> Void

  init(title: String, style: ButtonStyleType, action: @escaping () -> Void) {
    self.title = title
    self.style = ButtonStyleFactory.style(for: style)
    self.action = action
  }
  var body: some View {
    Button(action: action) {
      Text(title)
        .padding(style.padding)
        .foregroundColor(style.foregroundColor)
        .font(.title2)
        .fontWeight(.bold)
    }
    .frame(width: 200, height: 64)
    .background(style.backgroundColor)
    .cornerRadius(style.cornerRadius)
  }
}

#if DEBUG
  #Preview {
    MyButton(title: "Hello World", style: .destructive, action: {})
  }
#endif
