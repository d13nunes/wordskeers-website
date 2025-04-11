//
//  RestorePurchasePlugin.swift
//  App
//
//  Created by Diogo Nunes on 10/04/2025.
//

import Capacitor
import Foundation

@objc(RestorePurchasesPlugin)
public class RestorePurchasesPlugin: CAPPlugin, CAPBridgedPlugin {
  public let identifier = "RestorePurchases"
  public let jsName = "RestorePurchases"
  public let pluginMethods: [CAPPluginMethod] = [
    CAPPluginMethod(name: "restore", returnType: CAPPluginReturnPromise)
  ]
  private let implementation = RestorePurchases()

  @objc func restore(_ call: CAPPluginCall) {
    print("cal \(call.options.description)")
    let productIdsJS: [String] = call.getArray("productIds", String.self) ?? []
    let defaultProductIds = [
      "com.wordseekr.coinpack.removeads",
      "com.wordseekr.coinpack.removeads60",
      "com.wordseekr.removeads",
      "com.wordseekr.removeads60",
    ]
    let productIds: [String] = productIdsJS.isEmpty ? defaultProductIds : productIdsJS
    
    Task { @MainActor in
      let ownedProductIds = await implementation.restore(productIds: productIds)
      call.resolve([ 
        "productIds": ownedProductIds
      ])
      debugPrint("ownedProductIds \(ownedProductIds)")
    }

  }
}
