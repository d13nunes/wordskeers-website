import Foundation
import OSLog

/// Protocol defining analytics tracking capabilities
protocol AnalyticsService {
  func trackEvent(_ eventName: AnalyticsEvent)
  /// Tracks a custom event with optional parameters
  /// - Parameters:
  ///   - eventName: Name of the event to track
  ///   - parameters: Dictionary of parameters to include with the event
  func trackEvent(_ eventName: AnalyticsEvent, parameters: [String: Any]?)

}
