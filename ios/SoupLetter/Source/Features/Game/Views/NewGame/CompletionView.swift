import ConfettiSwiftUI
import SwiftUI

struct CompletionView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let formattedTime: String
  let onNextLevel: () -> Void
  let doubleRewardWithAd: () async -> Void

  var body: some View {
    CompletionCompactView(
      formattedTime: formattedTime,
      onNextLevel: onNextLevel,
      doubleRewardWithAd: doubleRewardWithAd
    )
    // if horizontalSizeClass == .compact {

    // } else {
    //   CompletionLargeView(
    //     formattedTime: formattedTime,
    //     onNextLevel: onNextLevel,
    //     doubleRewardWithAd: doubleRewardWithAd
    //   )
    // }
  }
}
struct CompletionCompactView: View {
  let formattedTime: String
  let onNextLevel: () -> Void
  let doubleRewardWithAd: () async -> Void

  @State private var showStandardRewardButton = false
  @State private var isAnimating = false
  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Congratulations! 🎉")
          .font(.title)
          .bold()

        VStack(spacing: 2) {
          Text("You completed the board in")
            .font(.subheadline)
          Text("\(formattedTime)")
            .font(.largeTitle)
            .bold()
        }.confettiCannon(
          trigger: $isAnimating,
          rainHeight: 100,
          openingAngle: Angle(degrees: 0),
          closingAngle: Angle(degrees: 360),
          radius: 200
        )

        DoubleRewardButton(
          title: "Collect 10 Coins",
          isLoading: false,
          action: doubleRewardWithAd
        )
        if showStandardRewardButton {
          DoubleRewardButton(
            title: "Collect 5 Coins",
            iconName: "nil",
            isLoading: false,
            backgroundColor: AppColors.blue,
            action: onNextLevel
          )
          .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
      }
      .padding(40)
      .background {
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(.systemBackground))
          .shadow(radius: 20)
      }
      .onAppear {
        isAnimating = true
        // Add a delay before showing the standard reward button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          withAnimation(.easeInOut(duration: 0.7)) {
            showStandardRewardButton = true
          }
        }
      }
    }
  }
}
struct CompletionLargeView: View {
  let formattedTime: String
  let onNextLevel: () -> Void
  let doubleRewardWithAd: () async -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Congratulations! 🎉")
          .font(.title)
          .bold()

        VStack(spacing: 8) {
          Text("It took you only \(formattedTime) to find all the words.")
            .font(.subheadline)
        }

        Button("New Game") {
          onNextLevel()
        }
        .buttonStyle(.borderedProminent)

        DoubleRewardButton(
          isLoading: false,
          action: doubleRewardWithAd
        )
      }

      .padding(40)
      .background {
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(.systemBackground))
          .shadow(radius: 20)
      }
    }

  }
}

#if DEBUG
  struct CompletionViewPreviews: View {
    let timeElapsed: TimeInterval = 11223.45
    @State private var isVisible = false

    var body: some View {
      VStack {
        Button("Show") {
          isVisible.toggle()
        }
        if isVisible {
          CompletionView(
            formattedTime: timeElapsed.formattedTime(),
            onNextLevel: {},
            doubleRewardWithAd: {}
          )
        }
      }
    }
  }
  #Preview {
    CompletionViewPreviews()
  }
#endif
