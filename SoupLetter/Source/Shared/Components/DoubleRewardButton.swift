import SwiftUI

/// A reusable button component for doubling rewards through watching ads
struct DoubleRewardButton: View {
  /// The action to perform when the button is tapped
  let action: () async -> Void

  /// Title to display on the button
  let title: String

  /// Icon to display on the button
  let iconName: String

  /// Whether the button is in a loading state
  let isLoading: Bool

  /// The color for the button background
  let backgroundColor: Color

  /// The accessibility label for the button
  let accessibilityLabel: String

  /// Initialize with custom text and icon
  /// - Parameters:
  ///   - title: Text to display on the button
  ///   - iconName: SF Symbol name for the button icon
  ///   - isLoading: Whether the button is in a loading state
  ///   - backgroundColor: The color for the button background
  ///   - accessibilityLabel: The accessibility label for the button
  ///   - action: The action to perform when tapped
  init(
    title: String = "Double Coins",
    iconName: String = "play.rectangle.fill",
    isLoading: Bool = false,
    backgroundColor: Color = .green,
    accessibilityLabel: String = "Double coins by watching an ad",
    action: @escaping () async -> Void
  ) {
    self.title = title
    self.iconName = iconName
    self.isLoading = isLoading
    self.backgroundColor = backgroundColor
    self.accessibilityLabel = accessibilityLabel
    self.action = action
  }

  var body: some View {
    Button {
      Task {
        await action()
      }
    } label: {
      CustomButton(title: title, iconName: iconName, backgroundColor: backgroundColor)
    }
    .disabled(isLoading)
    .overlay {
      if isLoading {
        ProgressView()
          .tint(.white)
      }
    }
    .accessibilityLabel(Text(accessibilityLabel))
    .sensoryFeedback(.impact(weight: .light), trigger: !isLoading)
  }
}

#Preview {
  VStack(spacing: 20) {
    // Standard state
    DoubleRewardButton {
      // Simulate network delay
      try? await Task.sleep(nanoseconds: 1_000_000_000)
    }

    // Loading state
    DoubleRewardButton(
      isLoading: true
    ) {
      // No-op for preview
    }

    // Custom title and icon
    DoubleRewardButton(
      title: "Watch Ad for Bonus",
      iconName: "film.fill",
      backgroundColor: .blue,
      accessibilityLabel: "Watch advertisement to receive bonus rewards"
    ) {
      // No-op for preview
    }
  }
  .padding()
  .previewLayout(.sizeThatFits)
}

extension View {
  func customButtonBackground(color: Color) -> some View {
    self.background(
      RoundedRectangle(cornerRadius: 8)
        .fill(color)
    )
  }
}
