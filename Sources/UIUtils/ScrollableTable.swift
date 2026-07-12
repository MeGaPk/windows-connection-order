import SwiftCrossUI

/// A scrollable, column-oriented table.
///
/// Columns use the natural width of their header and cells. Colours, strings,
/// selection, and row content stay at the call site.
public struct ScrollableTable<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// One naturally-sized column inside ``ScrollableTable``.
public struct ScrollableTableColumn<Header: View, Cells: View>: View {
    private let header: Header
    private let cells: Cells

    public init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder cells: () -> Cells
    ) {
        self.header = header()
        self.cells = cells()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            cells
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}
