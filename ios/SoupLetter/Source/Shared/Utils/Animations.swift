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

  func pulsating(active: Bool, duration: Double = 1.8, style: PulsatingStyle = .regular ) -> some View {
    let minSize = style == .regular ? 0.95 : 0.975
    let maxSize = style == .regular ? 1.05 : 1.025
    return self.keyframeAnimator(
      initialValue: CGFloat(1),
      repeating: active
    ) { content, scale in
      content.scaleEffect(scale)
    } keyframes: { _ in
      KeyframeTrack {
        CubicKeyframe(minSize, duration: 0.25 * duration)  // More subtle initial shrink
        CubicKeyframe(maxSize, duration: 0.25 * duration)  // Gentler expansion
        CubicKeyframe(minSize, duration: 0.25 * duration)  // Intermediate step
        CubicKeyframe(1.0, duration: 0.25 * duration)  // Gradual return to normal
      }
    }
  }
}

enum PulsatingStyle {
  case light
  case regular
}
