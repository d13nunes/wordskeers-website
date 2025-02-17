import SwiftUI

struct ImperativeAnimationView: View {
  @State private var isWiggling = false
  @State private var rotationDegree: CGFloat = 0

  var body: some View {
    VStack {
      Spacer()

      Rectangle()
        .fill(Color.blue)
        .frame(width: 100, height: 100)
        .cornerRadius(10)
        .rotationEffect(.degrees(rotationDegree))
        .scaleEffect(isWiggling ? 1.05 : 0.95)

      Spacer()

      Button("Animate") {
        withAnimation(.easeInOut(duration: 0.5)) {
          withAnimation(.easeInOut(duration: 0.2)) { rotationDegree = -50 }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) { rotationDegree = 20 }
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.15)) { rotationDegree = -10 }
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeOut(duration: 0.2)) { rotationDegree = 0 }
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  ImperativeAnimationView()
}
