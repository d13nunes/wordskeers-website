import SwiftUI

protocol WordSelectionVisualizing {
  var selectedLetters: [String] { get }
}
struct WordSelectionVisualizer: View {
  @State var viewModel: WordSelectionVisualizing
  private let size: CGFloat
  private let cornerRadius: CGFloat
  private let color: Color
  init(
    viewModel: WordSelectionVisualizing,
    size: CGFloat = 50,
    cornerRadius: CGFloat = 10,
    color: Color = .blue
  ) {
    self.viewModel = viewModel
    self.size = size
    self.cornerRadius = cornerRadius
    self.color = color
  }

  var body: some View {
    HStack(spacing: 1) {
      ForEach(viewModel.selectedLetters, id: \.self) { letter in
        LetterCell(
          size: size, cornerRadius: cornerRadius, color: color, letter: letter, isDiscovered: false)
      }
      Spacer().frame(width: .infinity)
    }
  }
}
