import SwiftUI

struct LargeMenuView<Content: View>: View {
  let content: Content
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  var body: some View {
    ZStack {
      Color.white.opacity(1)
        .ignoresSafeArea()
      content
        .padding(.horizontal, 44)
    }
  }
}
