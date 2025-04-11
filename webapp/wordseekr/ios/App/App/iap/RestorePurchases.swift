//
//  RestorePurchase.swift
//  App
//
//  Created by Diogo Nunes on 10/04/2025.
//

import Capacitor
import Foundation
import StoreKit

public class RestorePurchases {
  func restore(productIds: [String]) async -> [String] {
    do {
      try await AppStore.sync()
      let ownedProductIDs = await getTransactions(productIds: productIds)
      return ownedProductIDs
    } catch let error {
      print("error \(error)")
      return []
    }
  }

  private func getTransactions(productIds: [String]) async -> [String] {
    var ownedProductIDs: [String] = []
    if #available(iOS 18.4, *) {
      for productID in productIds {
        print("productID", productID)
        let transactions = Transaction.currentEntitlements(for: productID)
        print("Will print Transactions")
        for await result in transactions {
          guard case .verified(let transaction) = result else {
            continue  // Skip unverified transactions
          }
          print("transactions \(transaction.debugDescription)")
          if productIds.contains(transaction.productID) {
            ownedProductIDs.append(transaction.productID)
          }
        }
        print("Did print Transactions")
      }
    } else {
      // Fallback on earlier versions
      for await result in Transaction.currentEntitlements {
        guard case .verified(let transaction) = result else {
          continue  // Skip unverified transactions
        }
        if productIds.contains(transaction.productID) {
          ownedProductIDs.append(transaction.productID)
        }
      }
    }
    return ownedProductIDs
  }
}
