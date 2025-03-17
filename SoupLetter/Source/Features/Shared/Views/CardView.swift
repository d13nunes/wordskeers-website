import SwiftUI

struct CardView: View {
  let title: String
  let details: String
  let icon: String
  let iconColor: Color
  let iconBackgroundColor: Color?
  let backgroundColor: Color
  let textColor: Color
  let rightContent: AnyView
  let onClick: () -> Void

  var body: some View {
    Button(action: onClick) {
      HStack(spacing: 8) {
        StoreItemIcon(
          image: icon,
          color: iconColor,
          backgroundColor: iconBackgroundColor
        )
        .padding(.leading, 16)
        .padding(.trailing, 16)
        // Icon and title
        VStack(alignment: .leading, spacing: 3) {
          Text(title)
            .font(.system(size: 16, weight: .bold))
            .multilineTextAlignment(.leading)
            .foregroundColor(textColor)
          Text(details)
            .font(.system(size: 14, weight: .regular))
            .multilineTextAlignment(.leading)
            .foregroundStyle(textColor)
        }
        Spacer()

        // Arrow icon
        rightContent
      }
      .padding(17)
      .storeStyle(backgroundColor: backgroundColor)
    }
  }
}

#if DEBUG
  #Preview {
    CardView(
      title: "Remove Ads",
      details: "Enjoy an  ad-free experience",
      icon: "RemoveAds",
      iconColor: AppColors.red,
      iconBackgroundColor: nil,
      backgroundColor: AppColors.storeItemBackground,
      textColor: AppColors.storeText,
      rightContent: AnyView(Color.red.frame(width: 120, height: 20)),
      onClick: {}
    )
    .padding(12)
  }
#endif
