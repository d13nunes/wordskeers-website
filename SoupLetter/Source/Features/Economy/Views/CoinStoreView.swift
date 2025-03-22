import StoreKit
import SwiftUI

/// View for purchasing coin packages
struct CoinStoreView: View {

  @Namespace var bottomID

  @Environment(\.dismiss) private var dismiss

  @State private var isPurchasing = false
  @State private var isRestoring = false
  @State private var alertMessage: String?
  @State private var showAlert = false
  @State private var showRemoveAdsView = false

  let showNotEnoughCoinsMessage: Bool
  @State var storeService: StoreService
  let wallet: Wallet
  let analytics: AnalyticsService

  var isRemoveAdsActive: Bool {
    !storeService.removeAdsProduct.isPurchased && storeService.removeAdsProduct.product != nil
  }

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ZStack {
          ScrollView {
            VStack(spacing: 12) {
              // Header
              BalanceBigView(wallet: wallet)
              // Remove Ads Banner
              if isRemoveAdsActive {
                removeAdsBanner
              }

              // Coin packages
              Text("Get More Coins")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

              if storeService.isLoadingProducts {
                // Loading state
                VStack(spacing: 16) {
                  ProgressView()
                    .scaleEffect(1.5)

                  Text("Loading store products...")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
              } else if storeService.coinPackages.allSatisfy({ $0.product == nil }) {
                // Failed to load products
                EmptyView()
              } else {
                // Successfully loaded products
                let validPackages = storeService.coinPackages.filter { $0.product != nil }
                ForEach(validPackages) { package in
                  CoinPackageRow(
                    package: package,
                    isPurchasing: isPurchasing,
                    isLoadingRewardedVideo: storeService.isLoadingRewardedVideo,
                    onPurchase: { await purchasePackage(package) }
                  )
                  .disabled(isPurchasing || isRestoring)
                }

              }
              // Only show rewarded video product if it's available from ad manager

              CoinPackageRow(
                package: storeService.rewardedVideoProduct,
                isPurchasing: storeService.isLoadingRewardedVideo,
                isLoadingRewardedVideo: storeService.isLoadingRewardedVideo,
                onPurchase: {
                  guard let viewController = rootViewController() else {
                    return
                  }
                  await storeService.showRewardedVideo(on: viewController)
                }
              )
              .disabled(isPurchasing || isRestoring)

              if showNotEnoughCoinsMessage {
                VStack(spacing: 4) {
                  Text("Not enough coins")
                    .font(.headline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                  Text("Buy more coins to use the powerups")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .id(bottomID)
              }
            }
            .padding()
          }

          // Loading indicator
          if isPurchasing || isRestoring {
            Color.black.opacity(0.4)
              .ignoresSafeArea()

            ProgressView()
              .tint(.white)
              .scaleEffect(1.5)
          }

          CoinsToastView(
            coinAmount: storeService.coinsToastAmount,
            isVisible: $storeService.showCoinsToast
          )
        }
        .onAppear {
          if storeService.showNotEnoughCoinsMessage {
            withAnimation {
              proxy.scrollTo(bottomID, anchor: .bottom)
            }
          }
          // Refresh products when view appears
          Task {
            await storeService.loadProducts()
          }
        }
        .navigationTitle("Store")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button("Close") {
              dismiss()
            }
          }
          if isRemoveAdsActive {
            ToolbarItem(placement: .topBarTrailing) {
              Button {
                Task {
                  await restorePurchases()
                }
              } label: {
                Text("Restore")
                  .font(.subheadline)
              }
              .disabled(isPurchasing || isRestoring)
            }
          }
        }
      }
      .alert("Store", isPresented: $showAlert) {
        Button("OK") {}
      } message: {
        if let message = alertMessage {
          Text(message)
        }
      }
      .onAppear {
        analytics.trackEvent(.storeOpened, parameters: [:])
      }
      .sheet(isPresented: $showRemoveAdsView) {
        RemoveAdsView(storeService: storeService, analytics: analytics)
      }
    }
  }

  // Remove Ads Banner View
  private var removeAdsBanner: some View {
    Button {
      showRemoveAdsView = true
    } label: {
      HStack(spacing: 0) {
        StoreItemIcon(
          image: "RemoveAds",
          color: AppColors.red
        )
        .padding(.leading, 16)
        .padding(.trailing, 16)
        // Icon and title
        VStack(alignment: .leading, spacing: 4) {
          Text("Remove Ads")
            .font(
              Font.custom("Inter", size: 16)
                .weight(.bold)
            )
            .foregroundColor(AppColors.storeText)

          Text("Enjoy an ad-free experience")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Spacer()

        // Arrow icon
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
      }
      .padding(17)
      .storeStyle()
    }
    .padding(.bottom, 8)
  }

  private var noProductsView: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 40))
        .foregroundStyle(.orange)

      Text("Could not load store products")
        .font(.headline)

      Text("Please check your internet connection and try again.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      Button("Retry") {
        Task {
          await storeService.loadProducts()
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      .background(Color.blue)
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
  }

  /// Purchase a coin package
  private func purchasePackage(_ package: CoinPackage) async {
    isPurchasing = true
    defer {
      isPurchasing = false
    }

    // Track that the user viewed a specific package
    analytics.trackEvent(
      .storeItemViewed,
      parameters: [
        "package_id": package.id
      ])

    // Attempt to purchase the package
    let result = await storeService.purchaseCoinPackage(package)

    switch result {
    case .success:
      // alertMessage =
      //   "Purchase successful! \(package.totalCoins) coins have been added to your account."
      // Handled by CoinsToastView
      break
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
    isRestoring = true
    defer { isRestoring = false }

    let restored = await storeService.restorePurchases()

    if restored {
      alertMessage = "Your purchases have been restored!"
    } else {
      alertMessage = "No purchases to restore."
    }

    showAlert = true
  }
}

/// Row for displaying a single coin package
struct CoinPackageRow: View {
  let package: CoinStoreInfoing
  let isPurchasing: Bool
  let isLoadingRewardedVideo: Bool
  let onPurchase: () async -> Void

  var body: some View {
    Button {
      Task {
        await onPurchase()
      }
    } label: {
      HStack {
        StoreItemIcon(
          image: "Coins",
          color: AppColors.coinBackground
        )
        .padding(.leading, 16)
        .padding(.trailing, 16)
        // Icon and coins amount
        VStack(alignment: .leading, spacing: 2) {
          Text(package.name)
            .font(
              Font.custom("Inter", size: 16)
                .weight(.bold)
            )
            .foregroundColor(AppColors.storeText)
            .frame(alignment: .topLeading)
          Text("\(package.totalCoins) coins")
            .font(Font.custom("Inter", size: 14))
            .foregroundColor(AppColors.storeDetailText)
          if package.bonusPercentage > 0 {
            Text("+\(package.bonusPercentage)% BONUS")
              .font(.caption)
              .fontWeight(.bold)
              .foregroundStyle(.green)
          }
        }

        Spacer()
        if package.isRewardedVideo && isLoadingRewardedVideo || package.priceText.isEmpty {
          progressViewButton
        } else {
          let text = package.isRewardedVideo ? "Watch Ad" : package.priceText
          let color = package.isRewardedVideo ? AppColors.green : AppColors.blue
          Text(text)
            .pillStyle(foregroundColor: .white, backgroundColor: color)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background {
        RoundedRectangle(cornerRadius: 12)
          .inset(by: 0.5)
          .fill(Color(red: 0.98, green: 0.98, blue: 0.98))
          .stroke(Color(red: 0.95, green: 0.96, blue: 0.96), lineWidth: 1)
          .overlay {
            HStack {
              Spacer()
              VStack {
                if package.isMostPopular {
                  Text("MOST POPULAR")
                    .font(Font.custom("Inter", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.red, in: RoundedRectangle(cornerRadius: 6))

                } else if package.isBestValue {
                  Text("BEST VALUE")
                    .font(Font.custom("Inter", size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.green, in: RoundedRectangle(cornerRadius: 6))

                }
                Spacer()
              }
              .padding(.top, -8)
              .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.trailing, 6)
          }
      }
    }
    .contentShape(RoundedRectangle(cornerRadius: 12))
  }

  private var progressViewButton: some View {
    ProgressView()
      .frame(width: 24, height: 24)
      .tint(.white)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(.tint, in: RoundedRectangle(cornerRadius: 8))
      .foregroundStyle(.white)
  }

  private func rewardedVideoButton(_ package: CoinStoreInfoing) -> some View {
    // Price
    return Image(systemName: "play.circle.fill")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 24, height: 24)
      .foregroundColor(AppColors.green)
      .cornerRadius(4)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(AppColors.blue, in: RoundedRectangle(cornerRadius: 8))
      .foregroundStyle(.white)
  }
}

#if DEBUG
  #Preview {
    let wallet = Wallet.forTesting()
    return CoinStoreView(
      showNotEnoughCoinsMessage: false,
      storeService: StoreService(
        wallet: wallet,
        analytics: ConsoleAnalyticsManager(),
        adManager: MockAdManager()
      ),
      wallet: wallet,
      analytics: ConsoleAnalyticsManager()
    )
  }
#endif
