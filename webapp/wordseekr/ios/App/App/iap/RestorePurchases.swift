//
//  RestorePurchase.swift
//  App
//
//  Created by Diogo Nunes on 10/04/2025.
//

import Foundation
import StoreKit
import Capacitor



public class RestorePurchases  {
  
  func restore(productIds: [String]) async -> [String] {
      do {
        try await AppStore.sync()
        if #available(iOS 18.4, *) {
          for productID in productIds {
            print("productID", productID)
            let transactions = Transaction.currentEntitlements(for: productID)
            print("Will print Transactions")
            for await transaction in transactions {
              print("transactions \(transaction.debugDescription)")
            }
            print("Did print Transactions")
            
          }
          return []
        } else {
          // Fallback on earlier versions
          for await transaction in Transaction.currentEntitlements {
            print("Transaction \(transaction.debugDescription)")
          }
          return []
        }
      } catch let error {
        print( "error \(error)")
        return []
    }
  }
  
}
