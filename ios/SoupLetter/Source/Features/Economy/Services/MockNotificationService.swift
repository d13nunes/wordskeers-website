import Foundation
import SwiftUI
import UserNotifications

/// Mock implementation of NotificationServicing for testing and previews
@Observable final class MockNotificationService: NotificationServicing {
  /// Tracks if notification permission has been requested
  var permissionRequested = false

  /// The simulated permission status
  var permissionGranted = true

  /// Tracks scheduled notifications with their dates
  var scheduledNotifications: [String: Date] = [:]

  /// The expected daily reward notification ID (matching the real service)
  private let dailyRewardNotificationId = "daily_reward_notification"

  /// Controls whether scheduling should succeed or fail
  var shouldSucceedScheduling = true

  /// Tracks if a notification is currently showing (for preview purposes)
  var isShowingNotification = false

  /// The last notification content for preview purposes
  var lastNotificationTitle = ""
  var lastNotificationBody = ""

  /// Request notification permissions if not already granted
  /// - Returns: Whether the permission was granted
  func requestNotificationPermission() async -> Bool {
    permissionRequested = true
    return permissionGranted
  }

  /// Check if notification permission is granted
  /// - Returns: Whether permission is granted or denied
  func checkNotificationPermission() async -> Bool {
    return permissionGranted
  }

  /// Schedule a notification for when the next daily reward is available
  /// - Parameter date: The date when the next reward will be available
  /// - Returns: Whether the notification was scheduled successfully
  @discardableResult
  func scheduleNextRewardNotification(at date: Date) async -> Bool {
    // Remove any existing notifications first
    await removePendingNotifications(withIdentifier: dailyRewardNotificationId)

    // Check permission flow
    if !permissionGranted {
      let gotPermission = await requestNotificationPermission()
      if !gotPermission {
        return false
      }
    }

    // Store notification data for testing/preview purposes
    if shouldSucceedScheduling {
      scheduledNotifications[dailyRewardNotificationId] = date

      // For preview purposes
      lastNotificationTitle = "Daily Reward Available!"
      lastNotificationBody = "Your next daily reward is now ready to claim!"

      // Simulate a notification appearing for previews
      if date.timeIntervalSinceNow < 5 {  // If date is within 5 seconds, show immediately for preview
        isShowingNotification = true
        // Reset after 3 seconds
        Task { @MainActor in
          try? await Task.sleep(for: .seconds(3))
          isShowingNotification = false
        }
      }
    }

    return shouldSucceedScheduling
  }

  /// Removes any pending notifications with the specified identifier
  /// - Parameter identifier: The identifier of the notification to remove
  func removePendingNotifications(withIdentifier identifier: String) async {
    scheduledNotifications.removeValue(forKey: identifier)
  }

  /// Simulates receiving a notification (for preview/testing)
  func simulateReceivingNotification(
    title: String = "Daily Reward Available!",
    body: String = "Your next daily reward is now ready to claim!"
  ) {
    lastNotificationTitle = title
    lastNotificationBody = body
    isShowingNotification = true

    // Auto-dismiss after 3 seconds
    Task { @MainActor in
      try? await Task.sleep(for: .seconds(3))
      isShowingNotification = false
    }
  }

  /// Helper method to simulate scheduled notification firing
  func simulateScheduledNotificationFiring(identifier: String) {
    guard let date = scheduledNotifications[identifier] else { return }

    // Only fire if the date has passed
    if date <= Date() {
      isShowingNotification = true

      // For daily reward notification, use the standard content
      if identifier == dailyRewardNotificationId {
        lastNotificationTitle = "Daily Reward Available!"
        lastNotificationBody = "Your next daily reward is now ready to claim!"
      }

      // Auto-dismiss after 3 seconds
      Task { @MainActor in
        try? await Task.sleep(for: .seconds(3))
        isShowingNotification = false
      }

      // Remove the notification from scheduled list
      scheduledNotifications.removeValue(forKey: identifier)
    }
  }
}

// MARK: - SwiftUI Preview Helpers

extension MockNotificationService {
  /// Creates a preview-ready instance
  static var preview: MockNotificationService {
    let service = MockNotificationService()
    service.permissionGranted = true
    return service
  }

  /// Creates a preview-ready instance with denied permissions
  static var previewDenied: MockNotificationService {
    let service = MockNotificationService()
    service.permissionGranted = false
    return service
  }

  /// Creates a preview-ready instance showing an active notification
  static var previewWithNotification: MockNotificationService {
    let service = MockNotificationService()
    service.permissionGranted = true
    service.isShowingNotification = true
    service.lastNotificationTitle = "Daily Reward Available!"
    service.lastNotificationBody = "Your next daily reward is now ready to claim!"
    return service
  }
}

// MARK: - Preview UI Component

/// A view modifier that displays a mock notification banner when notifications are showing
struct MockNotificationBanner: ViewModifier {
  @Bindable var notificationService: MockNotificationService

  func body(content: Content) -> some View {
    ZStack {
      content

      if notificationService.isShowingNotification {
        VStack {
          HStack {
            VStack(alignment: .leading) {
              Text(notificationService.lastNotificationTitle)
                .font(.headline)
              Text(notificationService.lastNotificationBody)
                .font(.subheadline)
            }

            Spacer()

            Button {
              notificationService.isShowingNotification = false
            } label: {
              Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
          }
          .padding()
          .background(.ultraThinMaterial)
          .cornerRadius(16)
          .shadow(radius: 4)
          .padding()

          Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring, value: notificationService.isShowingNotification)
        .zIndex(100)
      }
    }
  }
}
