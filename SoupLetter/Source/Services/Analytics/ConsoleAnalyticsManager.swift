import Foundation
import OSLog

/// A development implementation of AnalyticsService that logs events to the console
@Observable class ConsoleAnalyticsManager: AnalyticsService {
  private let logger = Logger(subsystem: "com.soupletter.analytics", category: "Analytics")

  init() {
    logger.info("ConsoleAnalyticsManager initialized")
  }

  func trackEvent(_ eventName: AnalyticsEvent) {
    trackEvent(eventName, parameters: nil)
  }

  func trackEvent(_ eventName: AnalyticsEvent, parameters: [String: Any]? = nil) {
    if let parameters = parameters, !parameters.isEmpty {
      logger.info("\("📊 EVENT: \(eventName), params: \(String(describing: parameters))")")
    } else {
      logger.info("\("📊 EVENT: \(eventName)")")
    }
  }
}
