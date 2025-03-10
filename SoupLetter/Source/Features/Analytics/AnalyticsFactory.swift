import Foundation

enum AnalyticsEnvironment {
  case development
  case production
}

struct AnalyticsFactory {
  static func createAnalyticsService(environment: AnalyticsEnvironment) -> AnalyticsService {
    switch environment {
    case .development:
      return ConsoleAnalyticsManager()
    case .production:
      return FirebaseAnalyticsManager()
    }
  }
}
