import SwiftUI
import UIKit

extension View {
  @MainActor
  func rootViewController() -> UIViewController? {
    return UIApplication.shared.rootViewController()
  }
}

extension UIApplication {

  @MainActor
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
  case reward
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
  let image: Image?

  init(
    backgroundColor: Color,
    foregroundColor: Color,
    cornerRadius: CGFloat,
    padding: EdgeInsets,
    image: Image? = nil
  ) {
    self.backgroundColor = backgroundColor
    self.foregroundColor = foregroundColor
    self.cornerRadius = cornerRadius
    self.padding = padding
    self.image = image
  }
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
    case .reward:
      return ButtonStyle(
        backgroundColor: .green,
        foregroundColor: .white,
        cornerRadius: constants.cornerRadius,
        padding: constants.padding,
        image: Image("ad-label")
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
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  private let title: String
  private let style: ButtonStyle
  private let action: () -> Void
  private var isCompact: Bool {
    return horizontalSizeClass == .compact
  }

  init(title: String, style: ButtonStyleType, action: @escaping () -> Void) {
    self.title = title
    self.style = ButtonStyleFactory.style(for: style)
    self.action = action
  }
  var body: some View {
    if isCompact {
      compactView
    } else {
      largeView
    }
  }

  private var largeView: some View {
    return internalButtonView(width: 200)
  }

  private var compactView: some View {
    GeometryReader { geometry in
      internalButtonView(width: geometry.size.width)
    }
    .frame(height: 64)
  }

  private func internalButtonView(width: CGFloat) -> some View {
    return Button(action: action) {
      HStack(alignment: .center, spacing: 2) {
        if let image = style.image {
          image
            .resizable()
            .colorMultiply(.white)
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
        }
        Text(title)
          .padding(style.padding)
          .foregroundColor(style.foregroundColor)
          .font(.title2)
          .fontWeight(.bold)
      }
      .frame(width: width, height: 64)
      .background(style.backgroundColor)
      .cornerRadius(style.cornerRadius)
    }
  }
}

#if DEBUG
  #Preview {
    MyButton(
      title: "Hello World", style: .destructive,
      action: {
        print("clicked")
      })
  }
#endif
