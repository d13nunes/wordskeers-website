import SwiftUI

struct PaginatedFlowLayout: Layout {
  let maxRows: Int
  let spacing: CGFloat
  let pageWidth: CGFloat

  struct PageInfo {
    var items: [(Int, CGRect)]
    var page: Int
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
    guard let width = proposal.width else { return .zero }
    return layoutSubviews(in: width, subviews: subviews).last?.items.last?.1.size ?? .zero
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void
  ) {
    guard let width = proposal.width else { return }
    let pages = layoutSubviews(in: width, subviews: subviews)

    for page in pages {
      for (index, frame) in page.items {
        let offsetX = CGFloat(page.page) * pageWidth
        subviews[index].place(
          at: frame.origin.applying(.init(translationX: offsetX, y: 0)),
          proposal: ProposedViewSize(frame.size))
      }
    }
  }

  private func layoutSubviews(in width: CGFloat, subviews: Subviews) -> [PageInfo] {
    var pages: [PageInfo] = []
    var currentPage = PageInfo(items: [], page: 0)

    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    var rowHeight: CGFloat = 0
    var rowCount = 0

    for (index, subview) in subviews.enumerated() {
      let size = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))

      if xOffset + size.width > width {
        xOffset = 0
        yOffset += rowHeight + spacing
        rowHeight = size.height
        rowCount += 1

        if rowCount >= maxRows {
          pages.append(currentPage)
          currentPage = PageInfo(items: [], page: currentPage.page + 1)
          xOffset = 0
          yOffset = 0
          rowCount = 0
        }
      }

      let frame = CGRect(x: xOffset, y: yOffset, width: size.width, height: size.height)
      currentPage.items.append((index, frame))
      xOffset += size.width + spacing
      rowHeight = max(rowHeight, size.height)
    }

    if !currentPage.items.isEmpty {
      pages.append(currentPage)
    }

    return pages
  }
}

/// A view that arranges its children in a paginated flow layout.
struct PaginatedFlowLayoutView<Content: View>: View {
  let maxRows: Int
  let spacing: CGFloat
  let pageWidth: CGFloat
  let content: Content

  init(maxRows: Int, spacing: CGFloat, pageWidth: CGFloat, @ViewBuilder content: () -> Content) {
    self.maxRows = maxRows
    self.spacing = spacing
    self.pageWidth = pageWidth
    self.content = content()
  }

  var body: some View {
    let layout = PaginatedFlowLayout(maxRows: maxRows, spacing: spacing, pageWidth: pageWidth)

    // Use ViewThatFits as a container with our custom layout
    CustomLayoutContainer(layout: layout) {
      content
    }
  }
}

/// A container view that uses a custom layout for its content
struct CustomLayoutContainer<L: Layout, Content: View>: View {
  let layout: L
  let content: Content

  init(layout: L, @ViewBuilder content: () -> Content) {
    self.layout = layout
    self.content = content()
  }

  var body: some View {
    // Use the AnyLayout wrapper to apply our custom layout
    AnyLayout(layout) {
      content
    }
  }
}
