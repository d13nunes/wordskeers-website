//
//  MyViewController.swift
//  App
//
//  Created by Diogo Nunes on 10/04/2025.
//

import Foundation
import Capacitor

class MyViewController: CAPBridgeViewController {
  override func capacitorDidLoad() {
    bridge?.registerPluginInstance(RestorePurchasesPlugin())
  }
}
