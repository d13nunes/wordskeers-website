import ConfettiSwiftUI
import SwiftUI

struct CompletionView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let formattedTime: String
  let onNextLevel: () -> Void
  var body: some View {
    if horizontalSizeClass == .compact {
      CompletionCompactView(
        formattedTime: formattedTime,
        onNextLevel: onNextLevel
      )
    } else {
      CompletionLargeView(
        formattedTime: formattedTime,
        onNextLevel: onNextLevel
      )
    }
  }
}
struct CompletionCompactView: View {
  let formattedTime: String
  let onNextLevel: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Congratulations! 🎉")
          .font(.title)
          .bold()

        VStack(spacing: 2) {
          Text("You found all the words in")
            .font(.subheadline)
          Text("\(formattedTime)")
            .font(.largeTitle)
            .bold()
        }

        Button("New Game") {
          onNextLevel()
        }
        .buttonStyle(.borderedProminent)
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
struct CompletionLargeView: View {
  let formattedTime: String
  let onNextLevel: () -> Void

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
  let timeElapsed: TimeInterval = 11223.45
  #Preview {
    CompletionView(
      formattedTime: timeElapsed.formattedTime(),
      onNextLevel: {}
    )
  }
#endif
