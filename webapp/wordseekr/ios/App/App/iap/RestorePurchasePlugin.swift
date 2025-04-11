//
//  RestorePurchasePlugin.swift
//  App
//
//  Created by Diogo Nunes on 10/04/2025.
//

import Foundation
import Capacitor

@objc(RestorePurchasesPlugin)
public class RestorePurchasesPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "RestorePurchases"
    public let jsName = "RestorePurchases"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "restore", returnType: CAPPluginReturnNone)
    ]
    private let implementation = RestorePurchases()

    @objc func restore(_ call: CAPPluginCall) {
      print("cal \(call.options.description)")
      guard let productIds: [String] = call.getArray("productIds", String.self) else {
        call.reject("No parameters provided")
        return
      }
      Task {
        let productIds = await implementation.restore(productIds: productIds)
        call.resolve([
          "productIds": productIds
        ])
      }
    }
}
