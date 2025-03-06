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

// #Preview {
//   @Observable
//   class WordSelectionVisualizerViewModel: WordSelectionVisualizing {
//     var selectedLetters: [String] = []
//     var count = 0 {
//       didSet {
//         selectedLetters = Array("abcfsadasdhjaljdasjdasiodoais".map { String($0) }.prefix(count))
//       }
//     }
//     func addLetter(_ letter: String) {
//       selectedLetters.append(letter)
//     }

//     func removeLetter(_ letter: String) {
//       selectedLetters.removeAll { $0 == letter }
//     }
//   }

//   let viewModel = WordSelectionVisualizerViewModel()
//   return VStack {
//     Slider(
//       value: .init(get: { Double(viewModel.count) }, set: { viewModel.count = Int($0) }),
//       in: 0...10, step: 8)
//     WordSelectionVisualizer(viewModel: viewModel)
//   }.padding()
// }
