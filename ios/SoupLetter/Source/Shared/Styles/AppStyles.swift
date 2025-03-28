import SwiftUI

extension View {
  func roundedContainer(backgroundColor: Color = .white) -> some View {
    self.background(backgroundColor)
      .roundedCornerRadius()
      .roundedShadow()
  }

  func roundedCornerRadius() -> some View {
    self.cornerRadius(8)
  }

  func roundedShadow() -> some View {
    self.shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
  }

  func storeStyle(backgroundColor: Color = AppColors.storeItemBackground) -> some View {
    self.background(backgroundColor)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .inset(by: 0.5)
          .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 1)
      )
      .clipShape(RoundedRectangle(cornerRadius: 16))
  }

  func pillStyle(foregroundColor: Color, backgroundColor: Color) -> some View {
    self.font(
      Font.custom("Inter", size: 16)
        .weight(.bold)
    )
    .multilineTextAlignment(.center)
    .foregroundColor(foregroundColor)
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8))
    .foregroundStyle(foregroundColor)
  }
}
