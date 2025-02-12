import SwiftUI

struct PauseMenuView: View {
  @Binding var showingPauseMenu: Bool
  let onResume: () -> Void
  let onQuit: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Game Paused")
          .font(.title)
          .bold()

        Button("Resume") {
          withAnimation {
            showingPauseMenu = false
            onResume()
          }
        }
        .buttonStyle(.borderedProminent)

        Button("Quit", role: .destructive) {
          onQuit()
        }
        .buttonStyle(.bordered)
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
