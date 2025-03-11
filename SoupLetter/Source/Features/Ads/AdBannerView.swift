import GoogleMobileAds
import SwiftUI

/// A standard 320x50 banner ad view
struct StandardBannerView: UIViewRepresentable {
  func makeUIView(context: Context) -> BannerView {
    let bannerView = BannerView(adSize: AdSizeBanner)
    bannerView.adUnitID = AdConstants.UnitID.banner

    if let rootViewController = UIApplication.shared.rootViewController() {
      bannerView.rootViewController = rootViewController
    }

    bannerView.load(Request())
    return bannerView
  }

  func updateUIView(_ uiView: BannerView, context: Context) {
    // No updates needed
  }
}
