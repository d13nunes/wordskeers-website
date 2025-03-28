import SwiftUI

struct StoreItemIcon: View {
  let image: String
  let color: Color
  let backgroundColor: Color

  init(image: String, color: Color, backgroundColor: Color? = nil) {
    self.image = image
    self.color = color
    self.backgroundColor = backgroundColor ?? AppColors.storeItemBackground
  }

  var body: some View {
    Image(image)
      .renderingMode(.template)
      .resizable()
      .foregroundColor(color)
      .frame(width: 20, height: 20)
      .background(
        Circle()
          .fill(backgroundColor)
          .frame(width: 44, height: 44)
          .clipped()
      )
  }
}
