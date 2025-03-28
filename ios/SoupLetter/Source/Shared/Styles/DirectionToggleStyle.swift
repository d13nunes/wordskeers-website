import SwiftUI

struct DirectionToggleStyle: ButtonStyle {
  let isSelected: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.title2)
      .padding()
      .background(isSelected ? .blue : .clear)
      .foregroundStyle(isSelected ? .white : .primary)
      .clipShape(Circle())
      .overlay {
        Circle()
          .strokeBorder(isSelected ? .clear : .gray.opacity(0.3), lineWidth: 1)
      }
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.snappy(duration: 0.2), value: configuration.isPressed)
      .animation(.snappy(duration: 0.2), value: isSelected)
  }
}
