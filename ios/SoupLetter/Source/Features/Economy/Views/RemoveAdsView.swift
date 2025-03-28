import SwiftUI

/// View displaying the remove ads purchase option
struct RemoveAdsView: View {
  let storeService: StoreService
  let analytics: AnalyticsService

  @Environment(\.dismiss) private var dismiss
  @State private var isPurchasing = false
  @State private var showAlert = false
  @State private var alertMessage: String?

  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        // Header with icon
        VStack(spacing: 0) {
          Text(storeService.removeAdsProduct.name)
            .font(.title)
            .fontWeight(.bold)

          Text(storeService.removeAdsProduct.description)
            .font(.headline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
        .padding()

        // Benefits
        VStack(alignment: .leading, spacing: 16) {
          VStack {
            Text("🎉 Limited-Time Offer! 🎉")
              .font(.title3)
              .fontWeight(.bold)
              .frame(maxWidth: .infinity, alignment: .leading)
            Text("Early Adopters Special: Enjoy a seamless, ad-free experience. Now at an exclusive early bird discount!\nAct now! Offer available for a limited period only.")
              .multilineTextAlignment(.leading)
              .fontWeight(.regular)
          }
          VStack(spacing: 8) {
          Text("Benefits")
            .font(.title3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
          
            FeatureRow(text: "No more interruptions", icon: "checkmark.circle.fill")
            FeatureRow(text: "Ad-free gameplay", icon: "checkmark.circle.fill")
            FeatureRow(text: "Faster loading times", icon: "checkmark.circle.fill")
            FeatureRow(text: "One-time purchase", icon: "checkmark.circle.fill")
            FeatureRow(text: "Supports future development", icon: "checkmark.circle.fill")
          }
          .padding(.top, 8)

        }
        .padding()
        .background {
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemBackground))
        }
        .padding(.horizontal, 24)

        Spacer()

        // Purchase button or already purchased message
        if storeService.removeAdsProduct.isPurchased {

          HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(.green)
            Text("You already own this product")
              .fontWeight(.medium)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
          .padding(.horizontal)

        } else {
          ZStack(alignment: .leadingLastTextBaseline) {

          // Purchase button
          Button {
            Task {
              await purchaseRemoveAds()
            }
          }
            label: {
          
              HStack {
                if isPurchasing {
                  ProgressView()
                    .tint(.white)
                } else {
                  Text(
                    storeService.removeAdsProduct.priceText.isEmpty
                      ? "Loading..." : storeService.removeAdsProduct.priceText
                  )
                  .fontWeight(.bold)
                }
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
              .foregroundStyle(.white)

            }
            .buttonStyle(.plain)
            .disabled(isPurchasing || storeService.removeAdsProduct.priceText.isEmpty)
            .padding(.horizontal)

            if !(isPurchasing || storeService.removeAdsProduct.priceText.isEmpty) {
              Text("60% Off")
                .font(.system(size: 16))
                .bold(true)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColors.red)

                .roundedCornerRadius()
                //.frame(maxWidth: 120)
                .rotationEffect(.degrees(-4))
                .offset(x: 42, y: -2)
                .transition(.opacity)
            }
          }
          .pulsating(active: true, duration: 3, style: .light)
        }

        // Restore purchases link
        Button("Restore Purchases") {
          Task {
            await restorePurchases()
          }
        }
        .font(.subheadline)
        .padding(.bottom)
        .disabled(isPurchasing)
      }
      .navigationTitle("Remove Ads")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
    .alert("Remove Ads", isPresented: $showAlert) {
      Button("OK") {
        dismiss()
      }
    } message: {
      if let message = alertMessage {
        Text(message)
      }
    }
    .onAppear {
      Task {
        if !storeService.removeAdsProduct.isPurchased
          && storeService.removeAdsProduct.product == nil
        {
          await storeService.loadProducts()
        }
      }

      // Track analytics
      analytics.trackEvent(
        .storeItemViewed,
        parameters: [
          "product_id": storeService.removeAdsProduct.productId,
          "product_type": "remove_ads",
        ])
    }
  }

  /// Purchase the Remove Ads product
  private func purchaseRemoveAds() async {
    isPurchasing = true
    defer { isPurchasing = false }

    // Attempt to purchase
    let result = await storeService.purchaseRemoveAds()

    switch result {
    case .success:
      alertMessage = "Purchase successful! You will no longer see ads in the game."
    case .failure(let error):
      if let storeError = error as? StoreError {
        alertMessage = storeError.localizedDescription
      } else {
        alertMessage = "Failed to complete purchase: \(error.localizedDescription)"
      }
    }

    showAlert = true
  }

  /// Restore previous purchases
  private func restorePurchases() async {
    isPurchasing = true
    defer { isPurchasing = false }

    let restored = await storeService.restorePurchases()

    if restored {
      if storeService.removeAdsProduct.isPurchased {
        alertMessage = "Your Remove Ads purchase has been restored!"
      } else {
        alertMessage =
          "Your purchases have been restored, but you haven't purchased Remove Ads yet."
      }
    } else {
      alertMessage = "No purchases to restore."
    }

    showAlert = true
  }
}

/// Feature row with checkmark icon
private struct FeatureRow: View {
  let text: String
  let icon: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .foregroundStyle(.green)

      Text(text)
        .fontWeight(.medium)

      Spacer()
    }
  }
}

#if DEBUG
  #Preview {
    RemoveAdsView(
      storeService: StoreService(
        wallet: Wallet.forTesting(),
        analytics: ConsoleAnalyticsManager(),
        adManager: MockAdManager()
      ),
      analytics: ConsoleAnalyticsManager()
    )
  }
#endif
