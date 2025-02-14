import SwiftUI

struct PauseMenuView: View {
  @Binding var showingPauseMenu: Bool
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
                showingPauseMenu = false
                onResumeClicked()
              }
            }
          )

          MyButton(
            title: "New Game",
            style: .destructive,
            action: {
              showingPauseMenu = false
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
#if DEBUG
  #Preview {
    PauseMenuView(
      showingPauseMenu: .constant(true),
      onResumeClicked: {
        print("resume clicked")
      },
      onNewGameClicked: {
        print("new game clicked")
      }
    )
  }
#endif
