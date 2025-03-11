// import SwiftUI

// /// A view that displays available power-ups in a grid layout
// struct PowerUpView: View {
//   // MARK: - Properties

//   /// The power-up manager
//   @Bindable var powerUpManager: PowerUpManager

//   /// Words in the current game
//   let words: [WordData]

//   /// Callback when a power-up is selected
//   var onPowerUpSelected: (PowerUpType) -> Void

//   /// Environment value for the view controller
//   @Environment(\.hostingWindow) private var hostingWindow

//   // MARK: - Body

//   var body: some View {
//     VStack(spacing: 16) {
//       Text("Power-Ups")
//         .font(.headline)
//         .padding(.top, 8)
//       LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//         ForEach(powerUpManager.powerUps, id: \.type) { powerUp in
//           PowerUpButton(
//             type: powerUp.type,
//             isActive: powerUpManager.activePowerUpType == powerUp.type,
//             isAvailable: powerUpManager.powerUps.first(where: { $0.type == powerUp.type })?
//               .isAvailable ?? false
//           ) {
//             handlePowerUpTap(powerUp: powerUp)
//           }
//         }
//       }
//       .padding(.horizontal)

//       if powerUpManager.activePowerUpType != .none {
//         Button(action: {
//           Task { @MainActor in
//             powerUpManager.clearActivePowerUp()
//           }
//         }) {
//           Text("Clear Power-Up")
//             .font(.subheadline)
//             .foregroundStyle(.secondary)
//         }
//         .buttonStyle(.bordered)
//         .padding(.bottom, 8)
//       }
//     }
//     .padding()
//     .background(Material.regular)
//     .clipShape(RoundedRectangle(cornerRadius: 16))
//     .shadow(radius: 5)
//   }

//   // MARK: - Private Methods

//   /// Handles the tap on a power-up button
//   /// - Parameter powerUp: The power-up tapped
//   private func handlePowerUpTap(powerUp: PowerUp) {
//     guard let viewController = hostingWindow?.rootViewController else {
//       return
//     }

//     // If already active, clear it
//     if powerUpManager.activePowerUpType == powerUp.type {
//       Task { @MainActor in
//         powerUpManager.clearActivePowerUp()
//       }
//       return
//     }

//     // Otherwise try to activate the selected power-up
//     Task {
//       do {
//         let success = await powerUpManager.requestPowerUp(
//           powerUp: powerUp,
//           undiscoveredWords: words,
//           on: viewController
//         )

//         if success {
//           await MainActor.run {
//             onPowerUpSelected(powerUp.type)
//           }
//         }
//       }
//     }
//   }
// }

// /// A button displaying a power-up with its icon and availability state
// struct PowerUpButton: View {
//   // MARK: - Properties

//   /// The type of power-up this button represents
//   let type: PowerUpType

//   /// Whether this power-up is currently active
//   let isActive: Bool

//   /// Whether this power-up is available for use
//   let isAvailable: Bool

//   /// Action to perform when tapped
//   let action: () -> Void

//   // MARK: - Body

//   var body: some View {
//     Button(action: action) {
//       VStack {
//         Image(systemName: iconName)
//           .font(.system(size: 24))
//           .symbolVariant(isActive ? .fill : .none)
//           .foregroundStyle(isActive ? .white : .primary)
//           .frame(width: 44, height: 44)
//           .background(isActive ? Color.accentColor : Color.secondary.opacity(0.2))
//           .clipShape(Circle())

//         Text(title)
//           .font(.caption)
//           .foregroundStyle(isActive ? .primary : .secondary)
//       }
//       .padding(12)
//       .background(isActive ? Color.accentColor.opacity(0.2) : Color.clear)
//       .clipShape(RoundedRectangle(cornerRadius: 12))
//       .overlay(
//         RoundedRectangle(cornerRadius: 12)
//           .stroke(isActive ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
//       )
//     }
//     .disabled(!isAvailable && !isActive)
//     .opacity(isAvailable || isActive ? 1.0 : 0.5)
//   }

//   // MARK: - Computed Properties

//   /// The icon name for the power-up
//   private var iconName: String {
//     switch type {
//     case .none:
//       return "xmark.circle"
//     case .hint:
//       return "lightbulb"
//     case .directional:
//       return "arrow.up.and.down.and.arrow.left.and.right"
//     case .fullWord:
//       return "character.textbox"
//     case .rotateBoard:
//       return "arrow.clockwise"
//     }
//   }

//   /// The title for the power-up
//   private var title: String {
//     switch type {
//     case .none:
//       return "None"
//     case .hint:
//       return "Hint"
//     case .directional:
//       return "Direction"
//     case .fullWord:
//       return "Reveal"
//     case .rotateBoard:
//       return "Rotate"
//     }
//   }
// }

// #if DEBUG
//   // Add a hostingWindow environment key for presenting ads
//   private struct HostingWindowKey: EnvironmentKey {
//     static let defaultValue: UIWindow? = nil
//   }

//   extension EnvironmentValues {
//     var hostingWindow: UIWindow? {
//       get { self[HostingWindowKey.self] }
//       set { self[HostingWindowKey.self] = newValue }
//     }
//   }
//   #Preview {
//     PowerUpView(
//       powerUpManager: PowerUpManager(
//         adManager: MockAdManager(),
//         analytics: ConsoleAnalyticsManager(),
//         wallet: Wallet.forTesting()
//       ),
//       words: [],
//       onPowerUpSelected: {
//         print("PowerUpView: onPowerUpSelected: \($0)")
//       }
//     )
//   }
// #endif
