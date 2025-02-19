import SwiftUI

struct HintPopupView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  let onDismissedClicked: () -> Void

  let onShowHintClicked: () -> Void
  private let buttonWidth: CGFloat = .infinity
  var body: some View {
    if horizontalSizeClass == .compact {
      HintPopupCompactView(
        onDismissedClicked: onDismissedClicked,
        onShowHintClicked: onShowHintClicked
      )
    } else {
      HintPopupLargeView(
        onDismissedClicked: onDismissedClicked,
        onShowHintClicked: onShowHintClicked)
    }
  }
}
struct HintPopupCompactView: View {
  let onDismissedClicked: () -> Void
  let onShowHintClicked: () -> Void
  var body: some View {
    ZStack {
      Color.white.opacity(1)
        .ignoresSafeArea()

      VStack(spacing: 36) {
        Spacer()
        VStack(alignment: .center, spacing: 8) {
          Text("Hint")
            .font(.headline)
            .bold()
          Text("You can get a hint by watching an ad")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
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
          Spacer().frame(height: 44)
        }
      }
    }

  }
}

struct HintPopupLargeView: View {
  let onDismissedClicked: () -> Void
  let onShowHintClicked: () -> Void
  private let buttonWidth: CGFloat = .infinity
  var body: some View {
    ZStack {
      Color.black.opacity(0.3)
        .ignoresSafeArea()
      VStack(spacing: 36) {
        VStack(alignment: .center, spacing: 8) {
          Text("Hint")
            .font(.headline)
            .bold()
          Text("You can get a hint by watching an ad")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        HStack(alignment: .center, spacing: 12) {
          MyButton(
            title: "Dismiss",
            style: .passive,
            action: {
              withAnimation {
                onDismissedClicked()
              }
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
