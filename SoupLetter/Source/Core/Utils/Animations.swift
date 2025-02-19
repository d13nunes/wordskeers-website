import SwiftUI

private typealias WiggleProperties = (angleDegree: CGFloat, scale: CGFloat)

extension View {

  func wiggle(active: Bool) -> some View {
    let totalDuration = 10.0
    return self.keyframeAnimator(
      initialValue: WiggleProperties(0, 1),
      repeating: active
    ) { content, value in

      content
        .rotationEffect(.degrees(value.angleDegree))
        .scaleEffect(.init(width: 1, height: value.scale), anchor: .bottom)
    } keyframes: { _ in
      KeyframeTrack(\.angleDegree) {
        SpringKeyframe(0, duration: 0.2 * totalDuration)
        CubicKeyframe(10, duration: 0.2 * totalDuration)
        CubicKeyframe(-10, duration: 0.6 * totalDuration)
        CubicKeyframe(10, duration: 0.25 * totalDuration)
        SpringKeyframe(0, duration: 0.25 * totalDuration)
      }

      KeyframeTrack(\.scale) {
        CubicKeyframe(0.9, duration: 0.2 * totalDuration)
        CubicKeyframe(1.2, duration: 0.4 * totalDuration)
        CubicKeyframe(0.95, duration: 0.4 * totalDuration)
        CubicKeyframe(1, duration: 0.5 * totalDuration)
      }
    }
  }

  func scaleUpDown(active: Bool) -> some View {
    let totalDuration = 0.6
    return self.keyframeAnimator(
      initialValue: CGFloat(1),
      repeating: active
    ) { content, scale in
      content.scaleEffect(scale)
    } keyframes: { _ in
      KeyframeTrack {
        CubicKeyframe(0.8, duration: 0.3 * totalDuration)
        CubicKeyframe(1.1, duration: 0.3 * totalDuration)
        CubicKeyframe(1.0, duration: 0.4 * totalDuration)
      }
    }
  }
}
