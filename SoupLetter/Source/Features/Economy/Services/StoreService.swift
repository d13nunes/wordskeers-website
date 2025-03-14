import Foundation
import StoreKit

/// Manages all store-related operations including in-app purchases
@Observable class StoreService {
  /// Available coin packages
  private(set) var coinPackages: [CoinPackage]

  /// Remove Ads product
  private(set) var removeAdsProduct: RemoveAdsProduct

  let rewardedVideoProduct: RewardedVideoProduct

  /// Whether to show the not enough coins message
  var showNotEnoughCoinsMessage = true

  /// Transaction listener task
  private var updateListenerTask: Task<Void, Error>?

  /// The player's wallet
  private let wallet: Wallet

  var coinsToastAmount: Int = 0
  var showCoinsToast: Bool = false

  /// Whether products are currently being loaded
  private(set) var isLoadingProducts = false

  /// Whether products are currently being loaded
  var isLoadingRewardedVideo: Bool {
    !adManager.isRewardedReady
  }

  /// Analytics service for tracking purchases
  private let analytics: AnalyticsService
  private let adManager: AdManaging
  /// Initialize the store service
  /// - Parameters:
  ///   - wallet: The player's wallet
  ///   - analytics: Analytics service for tracking events
  init(wallet: Wallet, analytics: AnalyticsService, adManager: AdManaging) {
    self.wallet = wallet
    self.analytics = analytics
    self.adManager = adManager
    self.coinPackages = CoinPackage.defaultPackages()
    self.removeAdsProduct = RemoveAdsProduct()
    self.rewardedVideoProduct = RewardedVideoProduct(
      name: "Get Free Coins",
      coinAmount: 25
    )

    // Check if Remove Ads has already been purchased
    self.removeAdsProduct.isPurchased = UserDefaults.standard.bool(forKey: "remove_ads_purchased")

    // Start listening for transactions
    updateListenerTask = listenForTransactions()

    // Load products
    Task {
      await loadProducts()
    }
  }

  deinit {
    updateListenerTask?.cancel()
  }

  /// Load product information from App Store Connect
  @MainActor
  func loadProducts() async {
    guard !isLoadingProducts else { return }

    isLoadingProducts = true

    do {
      // Get all product IDs from our coin packages and remove ads product
      var productIds = Set(coinPackages.map { $0.productId })
      productIds.insert(removeAdsProduct.productId)

      // Request products from the App Store
      let storeProducts = try await Product.products(for: productIds)

      // Update our coin packages with the product information
      for index in coinPackages.indices {
        if let product = storeProducts.first(where: { $0.id == coinPackages[index].productId }) {
          coinPackages[index].product = product
          coinPackages[index].priceText = product.displayPrice
        }
      }

      // Update remove ads product
      if let removeAdsStoreProduct = storeProducts.first(where: {
        $0.id == removeAdsProduct.productId
      }) {
        removeAdsProduct.product = removeAdsStoreProduct
        removeAdsProduct.priceText = removeAdsStoreProduct.displayPrice
      }

      // Check for existing purchase of remove ads
      await checkExistingPurchases()
    } catch {
      print("Failed to load products: \(error)")
    }

    isLoadingProducts = false
  }

  /// Check existing purchases to determine if remove ads was purchased
  @MainActor
  private func checkExistingPurchases() async {
    do {
      for await verification in Transaction.currentEntitlements {
        guard case .verified(let transaction) = verification else { continue }

        // Check if user has purchased remove ads
        if transaction.productID == removeAdsProduct.productId {
          removeAdsProduct.isPurchased = true
          UserDefaults.standard.set(true, forKey: "remove_ads_purchased")
        }
      }
    } catch {
      print("Failed to check existing purchases: \(error)")
    }
  }

  /// Purchase a coin package
  /// - Parameter package: The coin package to purchase
  /// - Returns: Result indicating success or failure with error
  @MainActor
  func purchaseCoinPackage(_ package: CoinPackage) async -> Result<Transaction, Error> {
    guard let product = package.product else {
      return .failure(StoreError.productNotFound)
    }

    do {
      // Request a purchase from the App Store
      let result = try await product.purchase()

      switch result {
      case .success(let verification):
        // Check if the transaction is verified
        let transaction = try checkVerified(verification)

        // Add coins to the wallet
        wallet.addCoins(package.totalCoins)
        coinsToastAmount = package.totalCoins
        showCoinsToast = true

        // Track purchase in analytics
        analytics.trackEvent(
          .coinsPurchased,
          parameters: [
            "package_id": package.id,
            "coins_amount": package.totalCoins,
          ])

        // Finish the transaction
        await transaction.finish()

        return .success(transaction)

      case .userCancelled:
        return .failure(StoreError.userCancelled)

      case .pending:
        return .failure(StoreError.paymentPending)

      default:
        return .failure(StoreError.unknown)
      }
    } catch {
      return .failure(error)
    }
  }

  /// Purchase the Remove Ads product
  /// - Returns: Result indicating success or failure with error
  @MainActor
  func purchaseRemoveAds() async -> Result<Transaction, Error> {
    guard let product = removeAdsProduct.product else {
      return .failure(StoreError.productNotFound)
    }

    // If already purchased, return success
    if removeAdsProduct.isPurchased {
      return .failure(StoreError.alreadyPurchased)
    }

    do {
      // Request a purchase from the App Store
      let result = try await product.purchase()

      switch result {
      case .success(let verification):
        // Check if the transaction is verified
        let transaction = try checkVerified(verification)

        // Update the remove ads state
        removeAdsProduct.isPurchased = true
        UserDefaults.standard.set(true, forKey: "remove_ads_purchased")

        // Track purchase in analytics
        analytics.trackEvent(.removeAdsPurchased, parameters: [:])

        // Finish the transaction
        await transaction.finish()

        return .success(transaction)

      case .userCancelled:
        return .failure(StoreError.userCancelled)

      case .pending:
        return .failure(StoreError.paymentPending)

      default:
        return .failure(StoreError.unknown)
      }
    } catch {
      return .failure(error)
    }
  }

  /// Restore previous purchases
  /// - Returns: True if any purchases were restored
  @MainActor
  func restorePurchases() async -> Bool {
    var restoredPurchases = false

    // Check for previous purchases
    for await result in Transaction.currentEntitlements {
      do {
        let transaction = try checkVerified(result)

        // Check for remove ads
        if transaction.productID == removeAdsProduct.productId {
          removeAdsProduct.isPurchased = true
          UserDefaults.standard.set(true, forKey: "remove_ads_purchased")
          restoredPurchases = true

          // Track restoration in analytics
          analytics.trackEvent(.removeAdsRestored, parameters: [:])
        }

        // Check for coin packages
        if let package = coinPackages.first(where: { $0.productId == transaction.productID }) {
          // Add coins to the wallet
          wallet.addCoins(package.totalCoins)
          coinsToastAmount = package.totalCoins
          showCoinsToast = true
          restoredPurchases = true

          // Track restoration in analytics
          analytics.trackEvent(
            .coinsRestored,
            parameters: [
              "package_id": package.id,
              "coins_amount": package.totalCoins,
            ])
        }

        await transaction.finish()
      } catch {
        print("Failed to restore transaction: \(error)")
      }
    }

    return restoredPurchases
  }

  /// Listen for transactions from the App Store
  private func listenForTransactions() -> Task<Void, Error> {
    return Task.detached {
      // Iterate through any transactions that don't come from a direct call to purchase
      for await result in Transaction.updates {
        do {
          let transaction = try self.checkVerified(result)

          // Check for remove ads purchase
          let removeAdsId = await self.removeAdsProduct.productId
          if transaction.productID == removeAdsId {
            await MainActor.run {
              self.removeAdsProduct.isPurchased = true
              UserDefaults.standard.set(true, forKey: "remove_ads_purchased")

              // Track purchase in analytics
              self.analytics.trackEvent(.removeAdsPurchased, parameters: [:])
            }
          }

          // Check for coin package purchase
          if let package = await self.coinPackages.first(where: {
            $0.productId == transaction.productID
          }) {
            // Add coins to the wallet
            await self.wallet.addCoins(package.totalCoins)
            self.coinsToastAmount = package.totalCoins
            self.showCoinsToast = true

            // Track purchase in analytics
            await self.analytics.trackEvent(
              .coinsPurchased,
              parameters: [
                "package_id": package.id,
                "coins_amount": package.totalCoins,
              ])
          }

          // Finish the transaction
          await transaction.finish()
        } catch {
          print("Transaction failed verification: \(error)")
        }
      }
    }
  }

  /// Check if a transaction is verified
  /// - Parameter result: The verification result
  /// - Returns: The verified transaction
  private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
    // Check if the transaction passes StoreKit verification
    switch result {
    case .unverified:
      throw StoreError.verificationFailed
    case .verified(let safe):
      return safe
    }
  }

  @MainActor
  func showRewardedVideo(on viewController: UIViewController) async {
    let success = await adManager.showRewardedAd(on: viewController)
    if success {
      wallet.addCoins(rewardedVideoProduct.coinAmount)
      coinsToastAmount = rewardedVideoProduct.coinAmount
      showCoinsToast = true
    }
  }
}

/// Store-related errors
enum StoreError: Error {
  case productNotFound
  case userCancelled
  case paymentPending
  case verificationFailed
  case alreadyPurchased
  case unknown

  var localizedDescription: String {
    switch self {
    case .productNotFound:
      return "Product not found."
    case .userCancelled:
      return "Purchase was cancelled."
    case .paymentPending:
      return "Payment is pending approval."
    case .verificationFailed:
      return "Transaction verification failed."
    case .alreadyPurchased:
      return "You have already purchased this product."
    case .unknown:
      return "An unknown error occurred."
    }
  }
}
