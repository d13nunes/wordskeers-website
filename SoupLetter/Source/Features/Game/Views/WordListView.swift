import SwiftUI

struct WordListView: View {
  @State var viewModel: GameViewModel

  let maxRowCount = 3
  var collumns: Int {
    viewModel.words.count / 3 + ((viewModel.words.count % 3 != 0) ? 1 : 0)
  }

  var gridItems: [[WordData]] {
    viewModel.words.sorted(by: shortestLength)
      .chunked(into: maxRowCount)
  }

  var body: some View {
    HStack(alignment: .top, spacing: 4) {
      ForEach(gridItems, id: \.self) { collumn in
        VStack(alignment: .leading) {
          ForEach(collumn, id: \.word) { word in
            HStack(alignment: .firstTextBaseline, spacing: 4) {
              Image(
                systemName: word.isFound ? "checkmark.square.fill" : "square"
              )
              .foregroundColor(word.isFound ? .green : .gray)

              Text(word.word.capitalized)
                .font(.subheadline)
                .foregroundColor(word.isFound ? .primary : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
              RoundedRectangle(cornerRadius: 8)
                .fill(word.isFound ? Color.green.opacity(0.1) : Color.clear)
            }
          }
        }
      }
    }
    .onAppear {
      print(gridItems[0])
    }

  }

  func shortestLength(word1: WordData, word2: WordData) -> Bool {
    return word1.word.count < word2.word.count
  }
}
#if DEBUG
  #Preview {
    WordListView(viewModel: getViewModel(gridSize: 16, wordCount: 15))
  }
#endif
