import SwiftUI

struct PauseMenuView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let onResumeClicked: () -> Void
  let onNewGameClicked: () -> Void
  private let buttonWidth: CGFloat = .infinity
  var body: some View {
    if horizontalSizeClass == .compact {
      PauseMenuCompactView(
        onResumeClicked: onResumeClicked,
        onNewGameClicked: onNewGameClicked
      )
    } else {
      PauseMenuLargeView(
        onResumeClicked: onResumeClicked,
        onNewGameClicked: onNewGameClicked
      )
    }
  }
}

private struct PauseMenuLargeView: View {
  let onResumeClicked: () -> Void
  let onNewGameClicked: () -> Void
  private let buttonWidth: CGFloat = .infinity
  var body: some View {
    ZStack {
      Color.black.opacity(1)
        .ignoresSafeArea()
      VStack(spacing: 36) {
        Text("Game Paused")
          .font(.title)
          .bold()

        HStack(alignment: .center, spacing: 12) {
          MyButton(
            title: "Resume",
            style: .passive,
            action: {
              withAnimation {
                onResumeClicked()
              }
            }
          )

          MyButton(
            title: "New Game",
            style: .destructive,
            action: {
              onNewGameClicked()
            }
          )
        }
      }
      .frame(width: buttonWidth)
      .padding(40)
      .frame(width: .infinity)
      .background {
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(.systemBackground))
          .shadow(radius: 20)
      }
    }
  }
}

private struct PauseMenuCompactView: View {
  let onResumeClicked: () -> Void
  let onNewGameClicked: () -> Void

  var body: some View {
    ZStack {
      Color.white.opacity(1)
        .ignoresSafeArea()
      VStack(spacing: 36) {
        Spacer()
        Text("Game Paused")
          .font(.title)
          .bold()
        VStack(alignment: .center, spacing: 12) {
          MyButton(
            title: "Resume",
            style: .passive,
            action: {
              withAnimation {
                onResumeClicked()
              }
            }
          )

          MyButton(
            title: "New Game",
            style: .destructive,
            action: {
              onNewGameClicked()
            }
          )
          Spacer().frame(height: 44)
        }
      }
    }
  }
}

#if DEBUG
  #Preview {
    PauseMenuView(
      onResumeClicked: {
        print("resume clicked")
      },
      onNewGameClicked: {
        print("new game clicked")
      }
    )
  }

  #Preview("iPhone") {
    PauseMenuView(
      onResumeClicked: {
        print("resume clicked")
      },
      onNewGameClicked: {
        print("new game clicked")
      }
    )
  }

  #Preview("iPad") {
    PauseMenuLargeView(
      onResumeClicked: {
        print("resume clicked")
      },
      onNewGameClicked: {
        print("new game clicked")
      }
    )
  }

#endif
