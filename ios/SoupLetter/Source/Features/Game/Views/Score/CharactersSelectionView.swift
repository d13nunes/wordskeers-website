import Foundation
import SwiftUI

/// Defines the possible states of the Selected Characters View
enum SelectionState: Equatable {
  case empty
  case addingLetter(Character)
  case activeSelection([Character])
  case reset
  case completed
}

/// State Machine to manage the transition logic
@Observable
class CharactersSelectionStateMachine {
  private(set) var state: SelectionState = .empty

  /// Stores the selected characters
  private(set) var selectedLetters: [Character] = []

  /// Adds a new letter and updates the state accordingly
  func addLetter(_ letter: Character) {
    selectedLetters.append(letter)

    if selectedLetters.count == 1 {
      state = .addingLetter(letter)
      transitionToActiveState()
    } else {
      state = .activeSelection(selectedLetters)
    }
  }

  /// Resets the selection
  func resetSelection() {
    selectedLetters.removeAll()
    state = .reset

    // Move to empty state after a slight delay to allow for animation
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.state = .empty
    }
  }

  /// Marks the selection as completed (e.g., when a word is fully selected)
  func completeSelection() {
    if !selectedLetters.isEmpty {
      state = .completed
    }
  }

  /// Transitions to active selection state after the letter animation completes
  private func transitionToActiveState() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      guard let self = self else { return }
      if case let .addingLetter(letter) = self.state {
        self.state = .activeSelection(self.selectedLetters)
      }
    }
  }
}

struct CharactersSelectionView: View {
  @State private var stateMachine: CharactersSelectionStateMachine

  init(stateMachine: CharactersSelectionStateMachine) {
    self.stateMachine = stateMachine
  }

  var body: some View {
    VStack {
      HStack {
        ForEach(stateMachine.selectedLetters, id: \.self) { letter in
          LetterCell(
            size: 40,
            cornerRadius: 10,
            color: .blue,
            letter: String(letter),
            isDiscovered: false
          )
        }
      }
      .animation(.easeInOut, value: stateMachine.state)
    }
  }
}

#Preview {
  let stateMachine = CharactersSelectionStateMachine()
  VStack {
    HStack {
      Button("Add Letter") {
        let randomLetter = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!
        stateMachine.addLetter(randomLetter)
      }

      Button("Reset") {
        stateMachine.resetSelection()
      }
    }
    CharactersSelectionView(stateMachine: stateMachine)
  }
}
