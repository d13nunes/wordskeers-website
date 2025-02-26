import FirebaseAnalytics
import FirebaseCore
import Foundation
import OSLog

/// Firebase implementation of the AnalyticsService
@Observable class FirebaseAnalyticsManager: AnalyticsService {
  private let logger = Logger(subsystem: "com.soupletter.analytics", category: "FirebaseAnalytics")
  private let limitParametersCount = 25

  func trackEvent(_ eventName: AnalyticsEvent, parameters: [String: Any]? = nil) {

    var sanitizedParams: [String: Any]?

    if let parameters = parameters {
      sanitizedParams = sanitizeParameters(parameters)
    }

    let eventString = eventName.rawValue
    logger.debug(
      "Tracking Firebase event: \(eventString), params: \(String(describing: sanitizedParams))")
    Analytics.logEvent(eventString, parameters: sanitizedParams)
  }

  // MARK: - Helper Methods

  private func sanitizeParameters(_ parameters: [String: Any]) -> [String: Any] {
    var result = [String: Any]()

    // Firebase has a limit of 25 parameters per event
    for (key, value) in parameters.prefix(limitParametersCount) {
      // Only include parameters with valid names (40 chars max, alphanumeric + underscores)
      if isValidParameterName(key) {
        result[key] = value
      } else {
        logger.warning("Ignoring invalid parameter name: \(key)")
      }
    }

    return result
  }

  private func isValidParameterName(_ name: String) -> Bool {
    let nameRegex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9_]{1,40}$")
    return nameRegex?.firstMatch(in: name, range: NSRange(location: 0, length: name.count)) != nil
  }
}
