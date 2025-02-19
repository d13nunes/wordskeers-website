//
//  BoardLetterView.swift
//  SoupLetter
//
//  Created by Diogo Nunes on 18/02/2025.
//

import SwiftUI

enum LetterCellState: Equatable, Hashable {
  case none
  case selected
  case hint
}

struct LetterCell: View {
  let size: CGFloat
  let cornerRadius: CGFloat
  let color: Color
  let letter: String

  var body: some View {
    Text(letter)
      .font(.system(size: size * 0.7, weight: .bold, design: .rounded))
      .frame(width: size, height: size)
      .background {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(color)
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
      }
  }
}

#if DEBUG

  struct BoardLetterViewPreview: View {
    @State private var selectedState = LetterCellState.none
    let states: [LetterCellState] = [.none, .selected, .hint]
    var body: some View {
      VStack {
        Picker("State", selection: $selectedState) {
          ForEach(states, id: \.self) { state in
            Text(String(describing: state))
          }
        }
        .pickerStyle(WheelPickerStyle())
        LetterCell(
          size: 100,
          cornerRadius: 10,
          color: .blue,
          letter: "P")
      }
    }
  }
  #Preview {

    BoardLetterViewPreview()
  }
#endif
