import SwiftUI

struct MenuView<Content: View>: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  let title: String
  let subtitle: String?
  let content: Content
  init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
    self.title = title
    self.subtitle = subtitle
    self.content = content()
  }
  var body: some View {
    if horizontalSizeClass == .compact {
      CompactMenuView {
        InnerMenuView(title, subtitle: subtitle) {
          content
        }
      }
    } else {
      LargeMenuView {
        InnerMenuView(title, subtitle: subtitle) {
          content
        }
      }
    }
  }
}
