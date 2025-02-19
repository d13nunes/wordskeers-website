import SwiftUI

private typealias WiggleProperties = (angleDegree: CGFloat, scale: CGFloat)

extension View {

  @MainActor
  func printView(_ text: String) -> some View {
    print(text)
    return self
  }

  func wiggle(active: Bool) -> some View {
    let totalDuration = 1.0
    return self.keyframeAnimator(
      initialValue: WiggleProperties(0, 1),
      repeating: active
    ) { content, value in
      content
        .rotationEffect(.degrees(active ? value.angleDegree : 0))
        .scaleEffect(.init(width: 1, height: active ? value.scale : 1), anchor: .center)
    } keyframes: { _ in
      KeyframeTrack(\.angleDegree) {
        CubicKeyframe(0, duration: 0.2 * totalDuration)
        CubicKeyframe(10, duration: 0.2 * totalDuration)
        CubicKeyframe(-10, duration: 0.6 * totalDuration)
        CubicKeyframe(0, duration: 0.25 * totalDuration)
      }

      KeyframeTrack(\.scale) {
        CubicKeyframe(0.9, duration: 0.2 * totalDuration)
        CubicKeyframe(1.2, duration: 0.4 * totalDuration)
        CubicKeyframe(0.95, duration: 0.4 * totalDuration)
        CubicKeyframe(1, duration: 0.5 * totalDuration)
      }
    }
  }

  func pulsating(active: Bool) -> some View {
    let totalDuration = 1.8  // Faster overall animation
    return self.keyframeAnimator(
      initialValue: CGFloat(1),
      repeating: active
    ) { content, scale in
      content.scaleEffect(scale)
    } keyframes: { _ in
      KeyframeTrack {
        CubicKeyframe(0.95, duration: 0.25 * totalDuration)  // More subtle initial shrink
        CubicKeyframe(1.05, duration: 0.25 * totalDuration)  // Gentler expansion
        CubicKeyframe(0.95, duration: 0.25 * totalDuration)  // Intermediate step
        CubicKeyframe(1.0, duration: 0.25 * totalDuration)  // Gradual return to normal
      }
    }
  }
}
