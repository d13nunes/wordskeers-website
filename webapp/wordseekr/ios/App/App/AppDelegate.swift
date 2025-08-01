import Capacitor
import UIKit
import AppCoinsSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Override point for customization after application launch.
    if let url = launchOptions?[.url] as? URL {
      if AppcSDK.handle(redirectURL: url) { return true }
    }
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
  }

  func application(
    _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if AppcSDK.handle(redirectURL: url) {
      return true
    }
    return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
  }

  func application(
    _ application: UIApplication, continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return ApplicationDelegateProxy.shared.application(
      application, continue: userActivity, restorationHandler: restorationHandler)
  }

}
