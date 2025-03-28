import FirebaseCore
import GoogleMobileAds
import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()

    // Configure notification delegate
    UNUserNotificationCenter.current().delegate = self

    return true
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  /// Handle notifications that arrive when the app is in the foreground
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show the notification even if the app is in the foreground
    completionHandler([.banner, .sound, .badge])
  }

  /// Handle notification interactions when the app is in the background
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // Reset badge count
    UIApplication.shared.applicationIconBadgeNumber = 0

    // Handle notification based on identifier
    let identifier = response.notification.request.identifier
    if identifier == "daily_reward_notification" {
      // You could post a notification here or set a flag to navigate to daily rewards
      NotificationCenter.default.post(name: .dailyRewardNotificationTapped, object: nil)
    }

    completionHandler()
  }
}

// MARK: - Notification Names
extension Notification.Name {
  /// Posted when a daily reward notification is tapped
  static let dailyRewardNotificationTapped = Notification.Name("dailyRewardNotificationTapped")
}
