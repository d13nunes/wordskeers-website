import SwiftUI

struct PauseMenuView: View {
  let onResumeClicked: () -> Void
  let onNewGameClicked: () -> Void

  var body: some View {
    MenuView("Game Paused") {
      VStack(alignment: .center, spacing: 12) {
        MyButton(
          title: "Resume",
          style: .passive,
          action: {
            onResumeClicked()
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
    ).background(.red)
  }

#endif
