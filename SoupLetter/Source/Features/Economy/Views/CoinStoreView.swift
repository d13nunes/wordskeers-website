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

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ZStack {
          ScrollView {
            VStack(spacing: 24) {
              // Header
              HStack {
                Image(systemName: "coin.fill")
                  .font(.largeTitle)
                  .foregroundStyle(.yellow)

                Text("\(wallet.coins)")
                  .font(.title)
                  .fontWeight(.bold)
              }
              .frame(maxWidth: .infinity, alignment: .center)
              .padding()
              .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

              // Remove Ads Banner
              if !storeService.removeAdsProduct.isPurchased {
                removeAdsBanner
              }

              // Coin packages
              Text("Get More Coins")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

              ForEach(storeService.coinPackages) { package in
                CoinPackageRow(
                  package: package,
                  isPurchasing: isPurchasing,
                  isLoadingRewardedVideo: storeService.isLoadingRewardedVideo,
                  onPurchase: { await purchasePackage(package) }
                )
                .disabled(isPurchasing || isRestoring)
              }
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
        }
        .navigationTitle("Store")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button("Close") {
              dismiss()
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
      HStack {
        // Icon and title
        VStack(alignment: .leading, spacing: 4) {
          Text("Remove Ads")
            .font(.headline)
            .lineLimit(1)

          Text("Enjoy an ad-free experience")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Spacer()

        // Arrow icon
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
      }
      .padding()
      .background {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.secondarySystemBackground))
      }
    }
    .buttonStyle(.plain)
    .padding(.bottom, 8)
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
        // Icon and coins amount
        VStack(alignment: .leading, spacing: 4) {
          Text(package.name)
            .font(.headline)
            .lineLimit(1)

          HStack(spacing: 2) {
            Image(systemName: "coin.fill")
              .foregroundStyle(.yellow)
            Text("\(package.totalCoins)")
              .fontWeight(.bold)
          }

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
        } else if package.isRewardedVideo {
          rewardedVideoButton(package)
        } else {
          iapPackageButton(package)
        }

      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
      .background {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.secondarySystemBackground))
          .overlay {
            if package.isMostPopular {
              VStack {
                Text("MOST POPULAR")
                  .font(.caption)
                  .fontWeight(.black)
                  .foregroundStyle(.white)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(.blue, in: RoundedRectangle(cornerRadius: 6))

                Spacer()
              }
              .padding(.top, -12)
              .frame(maxWidth: .infinity, alignment: .center)
            } else if package.isBestValue {
              VStack {
                Text("BEST VALUE")
                  .font(.caption)
                  .fontWeight(.black)
                  .foregroundStyle(.white)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(.green, in: RoundedRectangle(cornerRadius: 6))

                Spacer()
              }
              .padding(.top, -12)
              .frame(maxWidth: .infinity, alignment: .center)
            }
          }
      }
    }
    .buttonStyle(.plain)
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
      .foregroundColor(.green)
      .cornerRadius(4)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(.tint, in: RoundedRectangle(cornerRadius: 8))
      .foregroundStyle(.white)
  }

  private func iapPackageButton(_ package: CoinStoreInfoing) -> some View {
    // Price
    return Text(package.priceText)
      .fontWeight(.semibold)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(.tint, in: RoundedRectangle(cornerRadius: 8))
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
