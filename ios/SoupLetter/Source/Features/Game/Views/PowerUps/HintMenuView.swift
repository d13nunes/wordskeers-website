import SwiftUI

struct HintPopupView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  let onDismissedClicked: () -> Void

  let onShowHintClicked: () -> Void
  private let buttonWidth: CGFloat = .infinity
  var body: some View {
    MenuView("Hint", subtitle: "You can get by watching an ad") {
      VStack(alignment: .center, spacing: 12) {
        MyButton(
          title: "Dismiss",
          style: .passive,
          action: {
            onDismissedClicked()
          }
        )
        MyButton(
          title: "Get hint",
          style: .reward,
          action: {
            onShowHintClicked()
          }
        )
      }
    }
  }
}

#if DEBUG
  #Preview {
    HintPopupView(
      onDismissedClicked: {
        print("dismiss clicked")
      },
      onShowHintClicked: {
        print("show hint clicked")
      }
    )
  }
#endif
