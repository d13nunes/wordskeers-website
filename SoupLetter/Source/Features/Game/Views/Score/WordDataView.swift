import SwiftUI

struct WordDataView: View {
  @Namespace private var wordTransition

  let word: String
  let isFound: Bool
  let direction: String?
  let wordFontSize: CGFloat
  let recentlyFoundWord: String?
  static let horizontalPadding: CGFloat = 12

  var body: some View {
    let font = Font.custom("Inter", size: wordFontSize)
    HStack(alignment: .center, spacing: 0) {
      if let direction = direction {
        Text(direction)
          .font(font)
          .foregroundColor(isFound ? .green.opacity(0.5) : .primary)
          .padding(.trailing, 8)
      }
      Text("\(word.capitalized)")
        .foregroundColor(isFound ? .green.opacity(0.5) : .primary)
        .strikethrough(isFound, color: .green.opacity(0.5))
        .font(font)
        .scaleEffect(recentlyFoundWord == word ? 1.2 : 1.0)
        .animation(.spring(duration: 0.5), value: isFound)
        .matchedGeometryEffect(id: word, in: wordTransition)
    }
    .padding(.horizontal, WordDataView.horizontalPadding - 4)
    .padding(.top, 7)
    .padding(.bottom, 8)
    .frame(alignment: .center)
    .background(Color(red: 0.95, green: 0.96, blue: 0.98))
    .cornerRadius(8)
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .inset(by: 0)
        .stroke(Color(red: 0.9, green: 0.91, blue: 0.92), lineWidth: 0)
    )
    .onChange(of: isFound) { oldValue, newValue in
      print("is found \(oldValue) - \(newValue)")
    }

  }

  static func getSize(for word: String, fontSize: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
    return (word as NSString).size(withAttributes: [.font: font]).width + (horizontalPadding * 2)
  }
}

#if DEBUG
  #Preview {
    let wordData = WordData(
      word: "Hello", isFound: true, position: Position(row: 0, col: 0), direction: .vertical)

    WordDataView(
      word: wordData.word,
      isFound: wordData.isFound,
      direction: nil,
      wordFontSize: 14,
      recentlyFoundWord: nil)
  }
#endif
