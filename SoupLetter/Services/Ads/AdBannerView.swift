import GoogleMobileAds
import SwiftUI

struct AdBannerView: UIViewRepresentable {
  let adUnitID: String
  let width: CGFloat
  
  func makeUIView(context: Context) -> BannerView {
    let adView = BannerView(adSize: AdSizeBanner)
    adView.adUnitID = adUnitID
    adView.adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
    adView.rootViewController = UIApplication.shared.rootViewController()
    adView.load(Request())
    return adView
  }

  func updateUIView(_ uiView: BannerView, context: Context) {}
}
