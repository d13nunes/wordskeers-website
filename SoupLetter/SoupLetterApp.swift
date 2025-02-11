//
//  SoupLetterApp.swift
//  SoupLetter
//
//  Created by Diogo Nunes on 10/02/2025.
//

import SwiftUI

@main
struct SoupLetterApp: App {
  let wordList = ["Hello", "World"]
  let gameManager: GameStateManager
  init() {
    self.gameManager = GameStateManager(wordList: wordList)
  }

  var body: some Scene {
    WindowGroup {
      GameView(viewModel: GameViewModel(gameManager: gameManager))
    }
  }
}
