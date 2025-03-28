import SwiftUI

struct PaginatedFlowView: View {
  let items: [WordData]
  @State var viewModel: GameViewModel
  @State var recentlyFoundWord: String?
  let maxRows: Int
  let spacing: CGFloat

  // Estimate average word size for calculation
  private let estimatedWordHeight: CGFloat = 30

  // Use PreferenceKey to collect view sizes
  @State private var pages: [[WordData]] = [[]]
  @State private var totalPageCount = 1
  @Binding var currentPageIndex: Int

  var body: some View {
    let isSmall = isSmallScreen()
    GeometryReader { proxy in
      let pageWidth = proxy.size.width

      ZStack {
        // Main content with TabView
        TabView(selection: $currentPageIndex) {
          ForEach(0..<totalPageCount, id: \.self) { pageIndex in
            VStack(alignment: .leading, spacing: spacing) {
              FlowLayoutView(
                items: pages[pageIndex],
                maxRows: maxRows,
                pageWidth: pageWidth,
                spacing: spacing,
                viewModel: viewModel,
                recentlyFoundWord: recentlyFoundWord
              )
            }
            .frame(width: pageWidth, alignment: .leading)
            .tag(pageIndex)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))  // Hide default indicators
        .onChange(of: proxy.size) { _, newSize in
          calculatePages(width: newSize.width)
        }
        .onChange(of: items) { _, _ in
          calculatePages(width: pageWidth)
        }
        
        .onAppear {
          calculatePages(width: pageWidth)
        }

        // Overlay for indicators
        VStack {
          // Page number indicator (e.g., "2/3") - top right
          if totalPageCount > 1 {
            HStack {
              Spacer()
              Text("\(currentPageIndex + 1)/\(totalPageCount)")
                .font(.system(size: 8).bold())
                .padding(.top, isSmall ? -4 : -6)
                .padding(.trailing, isSmall ? -2 : -4)

            }
          } else {
            // Empty spacer to maintain consistent layout
            HStack { Spacer() }.padding(.top, 8)
          }

          Spacer()

          // Custom page dots indicator - bottom center
          if totalPageCount > 1 {
            PageDotsIndicator(
              currentPage: currentPageIndex,
              pageCount: totalPageCount,
              onPageSelected: { selectedPage in
                currentPageIndex = selectedPage
              }
            )
            .offset(y: isSmall ? 2 : 6)
          }
        }
      }
    }
  }

  /// Navigate to the page containing the specified word
  private func navigateToPageContaining(word: String) {
    // Find which page contains the word
    for (pageIndex, pageWords) in pages.enumerated() {
      if pageWords.contains(where: { $0.word == word }) {
        // Use DispatchQueue to ensure animation happens after layout is complete
        DispatchQueue.main.async {
          withAnimation {
            self.currentPageIndex = pageIndex
          }
        }
        return
      }
    }
  }

  private func calculatePages(width: CGFloat) {
    var result: [[WordData]] = []
    var currentPage: [WordData] = []
    var currentRow = 0
    var rowItemCount = 0
    var remainingWidth = width

    // Improve the width estimation - use a smaller multiplier to avoid over-estimation
    for item in items {
      // More conservative width estimate (was 10, now 8 points per character)
      let estimatedWidth = max(CGFloat(item.word.count) * 8 + 16, 40)  // Ensure minimum width of 40

      // Special case for the first item in a row - it always fits
      if rowItemCount == 0 {
        currentPage.append(item)
        remainingWidth -= estimatedWidth
        rowItemCount += 1
        continue
      }

      // For subsequent items, check if they fit in the current row
      // Consider spacing only for items after the first one
      let widthWithSpacing = estimatedWidth + spacing

      if widthWithSpacing > remainingWidth {
        // Item doesn't fit, start a new row
        currentRow += 1
        rowItemCount = 0

        // Check if we need a new page
        if currentRow >= maxRows {
          // Save current page and start a new one
          if !currentPage.isEmpty {
            result.append(currentPage)
          }

          // Reset for new page
          currentPage = []
          currentRow = 0
          rowItemCount = 0
          remainingWidth = width

          // Add item as first in the new page/row
          currentPage.append(item)
          remainingWidth -= estimatedWidth
          rowItemCount += 1
        } else {
          // New row on same page
          remainingWidth = width - estimatedWidth
          currentPage.append(item)
          rowItemCount += 1
        }
      } else {
        // Item fits in current row with spacing
        currentPage.append(item)
        remainingWidth -= widthWithSpacing
        rowItemCount += 1
      }
    }

    // Add the last page if not empty
    if !currentPage.isEmpty {
      result.append(currentPage)
    }

    // Ensure we have at least one page
    if result.isEmpty {
      result = [[]]
    }

    self.pages = result
    self.totalPageCount = result.count

    // Ensure current page index is valid
    if currentPageIndex >= totalPageCount {
      currentPageIndex = max(0, totalPageCount - 1)
    }

  }
}

struct PageDotsIndicator: View {
  let currentPage: Int
  let pageCount: Int
  var onPageSelected: (Int) -> Void

  var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<pageCount, id: \.self) { index in
        Circle()
          .fill(index == currentPage ? Color.black : Color.gray.opacity(0.3))
          .frame(width: 4, height: 4)
          .scaleEffect(index == currentPage ? 1.2 : 1.0)
          .animation(.spring(duration: 0.2), value: currentPage)
          .onTapGesture {
            onPageSelected(index)
          }
      }
    }
    .padding(.horizontal)
  }
}

struct FlowLayoutView: View {
  var items: [WordData]
  let maxRows: Int
  let pageWidth: CGFloat
  let spacing: CGFloat
  @State var viewModel: GameViewModel
  @State var recentlyFoundWord: String?

  var hintedWord: WordData? {
    viewModel.powerUpManager.hintedWord
  }

  var body: some View {
    VStack(alignment: .leading, spacing: spacing) {
      FlowLayout(spacing: spacing) {
        ForEach(items, id: \.self) { item in
          WordDataView(
            word: item.word,
            isFound: item.isFound,
            direction: item.word == hintedWord?.word ? hintedWord?.direction.symbol : nil,
            wordFontSize: 14,
            recentlyFoundWord: recentlyFoundWord
          )
          // Uncomment for debugging size visualization
          // .background(Color.yellow.opacity(0.2))
          // .overlay(
          //   Text("\(item.count)")
          //     .font(.system(size: 8))
          //     .foregroundColor(.red)
          // )
        }
      }
    }
  }
}

struct FlowLayout: Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let width = proposal.width ?? 0
    let rows = calculateRows(width: width, subviews: subviews)

    var height: CGFloat = 0
    for (rowIndex, row) in rows.enumerated() {
      if let maxHeight = row.map({ subviews[$0].sizeThatFits(.unspecified).height }).max() {
        height += maxHeight

        if rowIndex < rows.count - 1 {
          height += spacing
        }
      }
    }

    return CGSize(width: width, height: height)
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let width = bounds.width
    let rows = calculateRows(width: width, subviews: subviews)

    var y = bounds.minY

    for row in rows {
      let rowHeight = row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
      var x = bounds.minX

      for (itemIndex, index) in row.enumerated() {
        let subview = subviews[index]
        let subviewSize = subview.sizeThatFits(.unspecified)

        subview.place(
          at: CGPoint(x: x, y: y + (rowHeight - subviewSize.height) / 2),
          proposal: ProposedViewSize(width: subviewSize.width, height: subviewSize.height)
        )

        x += subviewSize.width
        if itemIndex < row.count - 1 {
          x += spacing
        }
      }

      y += rowHeight + spacing
    }
  }

  private func calculateRows(width: CGFloat, subviews: Subviews) -> [[Int]] {
    var rows: [[Int]] = []
    var currentRow: [Int] = []
    var remainingWidth = width

    for (index, subview) in subviews.enumerated() {
      let size = subview.sizeThatFits(.unspecified)

      // Account for spacing only after the first item in a row
      let widthNeeded = currentRow.isEmpty ? size.width : size.width + spacing

      if widthNeeded > remainingWidth, !currentRow.isEmpty {
        rows.append(currentRow)
        currentRow = [index]
        remainingWidth = width - size.width
      } else {
        currentRow.append(index)
        remainingWidth -= widthNeeded
      }
    }

    if !currentRow.isEmpty {
      rows.append(currentRow)
    }

    return rows
  }
}
