import SwiftUI

struct SplashView: View {

  var body: some View {
    VStack(spacing: 20) {
      Text("SoupLetter")
        .font(.largeTitle)
        .fontWeight(.bold)

      Text("Find the hidden words!")
        .font(.title2)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  SplashView()
}
