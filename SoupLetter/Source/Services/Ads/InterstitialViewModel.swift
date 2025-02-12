import Foundation
import GoogleMobileAds
import SwiftUI

class InterstitialViewModel: NSObject, FullScreenContentDelegate {
  private var interstitialAd: InterstitialAd?

  func loadAd() async {
    do {
      interstitialAd = try await InterstitialAd.load(
        with: AdConstants.UnitID.interstitial,
        request: Request()
      )
      interstitialAd?.fullScreenContentDelegate = self
    } catch {
      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
    }
  }

  func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func adDidRecordClick(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func ad(
    _ ad: FullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("\(#function) called")
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    print("\(#function) called")
    // Clear the interstitial ad.
    interstitialAd = nil
  }
}
