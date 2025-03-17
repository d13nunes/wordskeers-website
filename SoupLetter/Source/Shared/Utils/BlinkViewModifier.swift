import SwiftUI

struct BlinkViewModifier: ViewModifier {
  let duration: Double
  @State private var isVisible: Bool = true

  func body(content: Content) -> some View {
    content
      .opacity(isVisible ? 1 : 0)
      .onAppear {
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
          isVisible.toggle()
        }
      }
  }
}

extension View {
  func blinking(duration: Double = 0.75) -> some View {
    modifier(BlinkViewModifier(duration: duration))
  }
}
