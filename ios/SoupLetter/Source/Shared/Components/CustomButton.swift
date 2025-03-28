import SwiftUI

struct CustomButton: View {
  let title: String
  let iconName: String
  let backgroundColor: Color
  let minWidth: CGFloat = 200

  var body: some View {
    HStack {
      Image(systemName: iconName)
        .foregroundColor(.white)
      Text(title)
        .foregroundColor(.white)
    }
    .frame(minWidth: minWidth)
    .padding()
    .customButtonBackground(color: backgroundColor)
    .foregroundColor(.black)
    .fontWeight(.semibold)
  }
}

#Preview {
  CustomButton(title: "Button", iconName: "plus", backgroundColor: .blue)
}
