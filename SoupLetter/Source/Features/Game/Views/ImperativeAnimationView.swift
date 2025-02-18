import SwiftUI

struct AnimationProperties {
  var translation = 0.0
  var verticalStretch = 1.0
}
struct ImperativeAnimationView: View {
  @State private var isWiggling = false
  @State private var rotationDegree: CGFloat = 0
  @State private var isAnimating = false
  let totalDuration = 1.0
  var body: some View {
    VStack {
      Spacer()

      Rectangle()
        .fill(Color.blue)
        .frame(width: 100, height: 100)
        .cornerRadius(10)
        .keyframeAnimator(
          initialValue: AnimationProperties(),
          trigger: isAnimating
        ) { content, value in
          content
            .scaleEffect(.init(width: 1, height: value.verticalStretch), anchor: .bottom)
            .offset(y: value.translation)
        } keyframes: { _ in
          KeyframeTrack(\.verticalStretch) {
            SpringKeyframe(0.6, duration: 0.2 * totalDuration)
            CubicKeyframe(1, duration: 0.2 * totalDuration)
            CubicKeyframe(1.2, duration: 0.6 * totalDuration)
            CubicKeyframe(1.1, duration: 0.25 * totalDuration)
            SpringKeyframe(1, duration: 0.25 * totalDuration)
          }

          KeyframeTrack(\.translation) {
            CubicKeyframe(0, duration: 0.2 * totalDuration)
            CubicKeyframe(-100, duration: 0.4 * totalDuration)
            CubicKeyframe(-100, duration: 0.4 * totalDuration)
            CubicKeyframe(0, duration: 0.5 * totalDuration)
          }
        }
        .onTapGesture {
          isAnimating.toggle()  // Start/Stop animation on tap
          print("isAnimating: \(isAnimating)")
        }
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
