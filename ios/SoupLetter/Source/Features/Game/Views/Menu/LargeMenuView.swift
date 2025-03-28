import SwiftUI

struct LargeMenuView<Content: View>: View {
  let content: Content
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  var body: some View {
    ZStack {
      AppColors.background.opacity(1)
        .ignoresSafeArea()
      content
        .padding(.horizontal, 44)
    }
  }
}
