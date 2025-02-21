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
  let isDiscovered: Bool

  @State private var scale: CGFloat = 1.0
  @State private var isAnimating: Bool = false

  var body: some View {
    VStack {
      ZStack {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(color)
          .frame(width: size, height: size)
        Text(letter)
          .font(.system(size: size * 0.7, weight: .bold, design: .rounded))
          .frame(width: size, height: size)
      }
      .scaleEffect(scale)  // Apply scale effect
      .onChange(of: isDiscovered) { oldValue, newValue in
        if !oldValue && newValue {
          isAnimating.toggle()
        }
      }

      .confettiCannon(
        trigger: $isAnimating,
        num: 10,
        colors: [.red, .green, .blue, .yellow, .purple],
        openingAngle: Angle(degrees: 0),
        closingAngle: Angle(degrees: 360),
        radius: 200
      )
    }
  }
  private func slamAnimation() {

    let growScale: CGFloat = 1.3
    let recoilScale: CGFloat = 0.95
    let normalScale: CGFloat = 1.0

    let springStiffness: Double = 250
    let springDamping: Double = 15
    let recoilDelay: Double = 0.1
    let recoilDuration: Double = 0.1

    let settleDelay: Double = 0.2
    let settleResponse: Double = 0.3
    let settleDamping: Double = 0.6

    withAnimation(.interpolatingSpring(stiffness: springStiffness, damping: springDamping)) {
      scale = growScale  // First, grow quickly
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + recoilDelay) {
      withAnimation(.easeOut(duration: recoilDuration)) {
        scale = recoilScale  // Slight recoil
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + settleDelay) {
        withAnimation(.spring(response: settleResponse, dampingFraction: settleDamping)) {
          scale = normalScale  // Settle back to normal
        }
      }
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
          letter: "P",
          isDiscovered: false
        )
      }
    }
  }
  #Preview {

    BoardLetterViewPreview()
  }
#endif
