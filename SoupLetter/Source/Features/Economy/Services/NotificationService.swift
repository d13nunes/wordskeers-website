import Foundation
import UserNotifications

/// Protocol defining the notification service capabilities
protocol NotificationServicing {
  /// Request notification permissions if not already granted
  /// - Returns: Whether the permission was granted
  func requestNotificationPermission() async -> Bool

  /// Check if notification permission is granted
  /// - Returns: Whether permission is granted or denied
  func checkNotificationPermission() async -> Bool

  /// Schedule a notification for when the next daily reward is available
  /// - Parameter date: The date when the next reward will be available
  /// - Returns: Whether the notification was scheduled successfully
  @discardableResult
  func scheduleNextRewardNotification(at date: Date) async -> Bool

  /// Removes any pending notifications with the specified identifier
  /// - Parameter identifier: The identifier of the notification to remove
  func removePendingNotifications(withIdentifier identifier: String) async
}

/// Service responsible for scheduling and managing local notifications
class NotificationService: NotificationServicing {
  /// The notification center
  private let notificationCenter = UNUserNotificationCenter.current()

  /// The notification identifier for daily rewards
  private let dailyRewardNotificationId = "daily_reward_notification"

  /// Request notification permissions if not already granted
  /// - Returns: Whether the permission was granted
  func requestNotificationPermission() async -> Bool {
    do {
      // Request permission to display notifications
      let options: UNAuthorizationOptions = [.alert, .sound, .badge]
      return try await notificationCenter.requestAuthorization(options: options)
    } catch {
      print("Error requesting notification authorization: \(error.localizedDescription)")
      return false
    }
  }

  /// Check if notification permission is granted
  /// - Returns: Whether permission is granted or denied
  func checkNotificationPermission() async -> Bool {
    let settings = await notificationCenter.notificationSettings()
    return settings.authorizationStatus == .authorized
  }

  /// Schedule a notification for when the next daily reward is available
  /// - Parameter date: The date when the next reward will be available
  /// - Returns: Whether the notification was scheduled successfully
  @discardableResult
  func scheduleNextRewardNotification(at date: Date) async -> Bool {
    // Remove any existing daily reward notifications
    await removePendingNotifications(withIdentifier: dailyRewardNotificationId)

    // Check if we have permission
    guard await checkNotificationPermission() else {
      let gotPermission = await requestNotificationPermission()
      if !gotPermission {
        return false
      }

      // Exit the guard if we got permission but needed to request it
      // This will make sure we continue with a fresh permission check
      return await scheduleNextRewardNotification(at: date)
    }

    // Create notification content
    let content = UNMutableNotificationContent()
    content.title = "Daily Reward Available!"
    content.body = "Your next daily reward is now ready to claim!"
    content.sound = .default
    content.badge = 1

    // Create a date components trigger for the specified date
    let triggerDate = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: date
    )
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

    // Create the request
    let request = UNNotificationRequest(
      identifier: dailyRewardNotificationId,
      content: content,
      trigger: trigger
    )

    do {
      // Schedule the notification
      try await notificationCenter.add(request)
      return true
    } catch {
      print("Error scheduling notification: \(error.localizedDescription)")
      return false
    }
  }

  /// Removes any pending notifications with the specified identifier
  /// - Parameter identifier: The identifier of the notification to remove
  func removePendingNotifications(withIdentifier identifier: String) async {
    await notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
  }
}
