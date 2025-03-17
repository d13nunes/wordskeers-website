import SwiftUI

struct CompactMenuView<Content: View>: View {
  let content: Content
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  var body: some View {
    VStack {
      Spacer()
      content
        .padding(.horizontal)
    }
    .background(AppColors.background)
  }

}
