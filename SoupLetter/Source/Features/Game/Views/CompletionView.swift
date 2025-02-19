import ConfettiSwiftUI
import SwiftUI

struct CompletionView: View {
  let formattedTime: String
  let onNextLevel: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Text("Level Complete!")
          .font(.title)
          .bold()

        VStack(spacing: 8) {
          Text("Time: \(formattedTime)")
            .font(.subheadline)
        }

        Button("Next Level") {
          withAnimation {
            onNextLevel()
          }
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
  #Preview {
    CompletionView(
      formattedTime: "01:23",
      onNextLevel: {}
    )
  }
#endif
