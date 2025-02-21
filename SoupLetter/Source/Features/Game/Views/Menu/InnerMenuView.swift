import SwiftUI

struct InnerMenuView<Content: View>: View {
  let title: String
  let subtitle: String?
  let content: Content
  init(_ title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
    self.title = title
    self.subtitle = subtitle
    self.content = content()
  }

  var body: some View {
    VStack(spacing: 28) {
      Spacer()
        .frame(height: 44)
      VStack(alignment: .center, spacing: 2) {
        Text(title)
          .font(.title)
          .bold()
        if let subtitle = subtitle {
          Text(subtitle)
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      }
      content
      Spacer()
        .frame(height: 44)
    }
  }
}
