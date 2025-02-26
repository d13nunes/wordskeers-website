import Foundation

/// Main analytics manager that forwards events to the underlying implementation
@Observable class AnalyticsManager: AnalyticsService {
  private let service: AnalyticsService

  /// Initialize with a specific analytics service implementation
  /// - Parameter service: The underlying analytics service to use
  init(service: AnalyticsService) {
    self.service = service
  }

  func trackEvent(_ eventName: AnalyticsEvent, parameters: [String: Any]? = nil) {
    service.trackEvent(eventName, parameters: parameters)
  }

}
