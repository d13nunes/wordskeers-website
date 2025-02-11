//
//  SoupLetterApp.swift
//  SoupLetter
//
//  Created by Diogo Nunes on 10/02/2025.
//

import SwiftUI

@main
struct SoupLetterApp: App {
  let storage: any StorageProtocol
  let wordList: WordList
  let gameManager: GameStateManager
  
  init() {
    do {
      self.storage = try SwiftDataRepository()
    } catch {
      fatalError("Failed to initialize storage: \(error)")
    }
    self.wordList = WordList(
      id: UUID(), name: "Default", words: ["Hello", "World"], difficulty: .easy)
    self.gameManager = GameStateManager(wordList: wordList, storage: storage)
  }  

  var body: some Scene {
    WindowGroup {
      GameView(viewModel: GameViewModel(wordList: wordList, storage: storage, gameManager: gameManager  ))
    }
  }
}
