import Foundation

/// Main analytics manager that forwards events to the underlying implementation
@Observable class AnalyticsManager: AnalyticsService {
  private let provider: AnalyticsService

  /// Initialize with a specific analytics service implementation
  /// - Parameter service: The underlying analytics service to use
  init(provider: AnalyticsService) {
    self.provider = provider
  }

  func trackEvent(_ eventName: AnalyticsEvent) {
    provider.trackEvent(eventName)
  }

  func trackEvent(_ eventName: AnalyticsEvent, parameters: [String: Any]? = nil) {
    provider.trackEvent(eventName, parameters: parameters)
  }

}
