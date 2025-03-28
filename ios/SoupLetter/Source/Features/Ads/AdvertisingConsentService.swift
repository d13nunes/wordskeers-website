import AppTrackingTransparency
import GoogleMobileAds
import SwiftUI
import UserMessagingPlatform

/// Manages advertising consent requirements, including App Tracking Transparency
/// and Google's User Messaging Platform for GDPR/privacy compliance
@Observable final class AdvertisingConsentService {

  // MARK: - Properties

  /// Current status of the consent process
  private(set) var consentState: ConsentState = .unknown

  /// Whether ads can be personalized based on user consent
  private(set) var canShowPersonalizedAds: Bool = false

  /// Whether the Google Mobile Ads SDK has been initialized
  private(set) var isAdMobInitialized: Bool = false

  // MARK: - Lifecycle

  /// Request necessary consents and initialize advertising
  /// - Should be called early in the app lifecycle, but after a short delay
  @MainActor
  func initialize() async {
    // Reset state
    consentState = .inProgress

    // Step 1: Request ATT authorization if needed
    await requestTrackingAuthorization()

    // Step 2: Initialize UMP SDK and request consent if needed
    await requestUMPConsent()

    consentState = .completed
  }

  // MARK: - ATT (App Tracking Transparency)

  @MainActor
  private func requestTrackingAuthorization() async {
    // Wait until the app is active
    try? await Task.sleep(for: .seconds(1))

    // Request ATT authorization
    let status = await ATTrackingManager.requestTrackingAuthorization()

    // Log the result
    switch status {
    case .authorized:
      debugPrint("ATT: User authorized tracking")
    case .denied, .restricted:
      debugPrint("ATT: User denied tracking")
    case .notDetermined:
      debugPrint("ATT: Tracking authorization status not determined")
    @unknown default:
      debugPrint("ATT: Unknown tracking authorization status")
    }
  }

  // MARK: - UMP (User Messaging Platform)

  private func requestUMPConsent() async {
    // Create request parameters
    let parameters = UMPRequestParameters()

    // Configure for debugging if needed
    #if DEBUG
      let debugSettings = UMPDebugSettings()
      // debugSettings.geography = .EEA  // Test EEA consent
      // debugSettings.geography = .regulatedUSState  // Test US regulated States consent
      debugSettings.geography = .other  // Test other consent
      debugSettings.testDeviceIdentifiers = ["GADSimulatorID"]

      parameters.debugSettings = debugSettings
    #endif

    do {
      // Request latest consent information
      let formStatus = try await withCheckedThrowingContinuation {
        (continuation: CheckedContinuation<UMPFormStatus, Error>) in
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            // Check if a form is available and load it
            if UMPConsentInformation.sharedInstance.formStatus == .available {
              UMPConsentForm.loadAndPresentIfRequired(
                from: nil  // forcing the use of the top view controller
              ) { [weak self] error in
                if let error = error {
                  continuation.resume(throwing: error)
                } else {
                  // Process consent status
                  self?.processConsentStatus()
                  continuation.resume(returning: UMPConsentInformation.sharedInstance.formStatus)
                }
              }
            } else {
              // No form needed, process existing consent
              self.processConsentStatus()
              continuation.resume(returning: UMPConsentInformation.sharedInstance.formStatus)
            }
          }
        }
      }

      debugPrint("UMP: Consent form status - \(formStatus)")
    } catch {
      debugPrint("UMP: Error obtaining consent: \(error.localizedDescription)")
      // Default to non-personalized ads in case of error
      canShowPersonalizedAds = false
    }
  }

  private func processConsentStatus() {
    // Check consent status
    let canShowPersonalizedAds = UMPConsentInformation.sharedInstance.canRequestAds

    // Update status
    self.canShowPersonalizedAds = canShowPersonalizedAds

    debugPrint("UMP: Can show personalized ads: \(canShowPersonalizedAds)")
  }

  // MARK: - Enums

  enum ConsentState {
    case unknown
    case inProgress
    case completed
  }
}
