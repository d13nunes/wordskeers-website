import SwiftUI

enum LevelStatus {
  case locked
  case open
  case completed
}

struct Level: Identifiable {
  let id: UUID
  let name: String
  let status: LevelStatus
}

struct LevelsView: View {
  let levels: [Level]

  init(levels: [Level] = []) {
    self.levels = levels
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { scrollProxy in
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
              LevelItemContainer(level: level, index: index)
                .id(level.id)  // Add an id to each item for scrolling
                .padding(.horizontal, 32)
            }
          }
          .padding(.vertical)
        }
        .onAppear {
          // Find the first open level and scroll to it
          if let openLevelIndex = levels.firstIndex(where: { $0.status == .open }) {
            // Add a slight delay to ensure the view is fully laid out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              withAnimation(.easeInOut(duration: 0.5)) {
                scrollProxy.scrollTo(levels[openLevelIndex].id, anchor: .bottom)
              }
            }
          }
        }
      }
    }
    .navigationTitle("Levels")
  }
}

struct LevelItemContainer: View {
  let level: Level
  let index: Int

  // Adjust frame height based on level status
  private var frameHeight: CGFloat {
    switch level.status {
    case .locked, .completed:
      return 90
    case .open:
      return 110
    }
  }

  var body: some View {
    GeometryReader { geometry in
      LevelItem(level: level, position: index, geometry: geometry)
    }
    .frame(height: frameHeight)
    // Add animation for smooth transitions when level status changes
    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: level.status)
  }
}

struct LevelItem: View {
  let level: Level
  let position: Int
  let geometry: GeometryProxy
  @State private var isHovered = false
  @State private var isPulsing = false
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  // Define scale based on level status instead of position
  private var scale: CGFloat {
    // Don't apply scaling if reduce motion is enabled
    guard !reduceMotion else {
      return 1.0
    }

    switch level.status {
    case .locked:
      return 0.95  // Smaller for locked levels
    case .completed:
      return 0.95  // Medium for completed levels
    case .open:
      // Larger for open levels, with hover effect and subtle pulsing if not hovered
      return isHovered ? 1.08 : (isPulsing ? 1.05 : 1.03)
    }
  }

  // Define shadow elevation based on level status
  private var shadowRadius: CGFloat {
    switch level.status {
    case .locked:
      return 2
    case .completed:
      return 3
    case .open:
      return isHovered ? 9 : 7  // Increased shadow radius when hovered
    }
  }

  // Define shadow opacity based on level status
  private var shadowOpacity: CGFloat {
    switch level.status {
    case .locked:
      return 0.05
    case .completed:
      return 0.1
    case .open:
      return isHovered ? 0.25 : 0.2  // Increased shadow opacity when hovered
    }
  }

  // Get the background color based on level status
  private var backgroundColor: Color {
    switch level.status {
    case .locked:
      return Color(.systemGray6)
    case .open:
      return .white
    case .completed:
      return Color(.systemGreen).opacity(0.1)
    }
  }

  var body: some View {
    LevelView(level: level)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(backgroundColor)
          .shadow(
            color: .black.opacity(shadowOpacity),
            radius: shadowRadius,
            x: 0,
            y: level.status == .open ? 3 : 1
          )
      )
      .scaleEffect(scale)
      .opacity(level.status == .locked ? 0.7 : 1.0)
      // Use a higher z-index for open levels to ensure they're on top
      .zIndex(level.status == .open ? 1 : 0)
      // Hover effect only for open levels
      .onHover { hovering in
        guard level.status == .open else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          isHovered = hovering
        }
      }
      .padding(.top, level.status == .open ? 8 : 0)
      // Add a spring animation to make the transition smooth
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: level.status)
      .onAppear {
        // Add a subtle pulsing animation for open levels
        guard level.status == .open && !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
          isPulsing = true
        }
      }
      // Clear description of status for VoiceOver
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(level.status == .open ? .isButton : [])
      .accessibilityHint(level.status == .open ? "Tap to play this level" : "")
  }
}

struct LevelView: View {
  let level: Level

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text(level.name)
          .font(.headline)
          .foregroundColor(level.status == .locked ? .gray : .primary)
          .accessibilityLabel("\(level.name)")

        HStack {
          statusIcon

          statusText
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .accessibilityLabel(accessibilityLabel)
      }

      Spacer()

      trailingIcon
        .accessibilityHidden(true)
    }
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }

  // Status icon based on level status
  @ViewBuilder
  private var statusIcon: some View {
    switch level.status {
    case .locked:
      Image(systemName: "lock.fill")
        .foregroundColor(.gray)
    case .open:
      Image(systemName: "star")
        .foregroundColor(.yellow)
    case .completed:
      Image(systemName: "star.fill")
        .foregroundColor(.yellow)
    }
  }

  // Status text based on level status
  @ViewBuilder
  private var statusText: some View {
    switch level.status {
    case .locked:
      Text("Locked")
    case .open:
      Text("Tap to play")
    case .completed:
      Text("Completed")
    }
  }

  // Trailing icon based on status
  @ViewBuilder
  private var trailingIcon: some View {
    switch level.status {
    case .locked:
      Image(systemName: "lock.fill")
        .foregroundColor(.gray)
    case .open:
      Image(systemName: "chevron.right")
        .foregroundColor(.blue)
    case .completed:
      Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.green)
    }
  }

  // Accessibility label based on status
  private var accessibilityLabel: String {
    switch level.status {
    case .locked:
      return "Level locked. Complete previous levels to unlock."
    case .open:
      return "Tap to play this level"
    case .completed:
      return "Level completed"
    }
  }
}

#Preview {
  let levels =
    [
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 1", status: .completed),
      Level(id: UUID(), name: "Level 2", status: .open),
    ] + Array(3..<100).map { Level(id: UUID(), name: "Level \($0)", status: .locked) }

  return LevelsView(levels: levels.reversed())
}
