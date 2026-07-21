import SwiftCrossUI

/// A scrollable, column-oriented table whose columns share the available width
/// according to a configurable weight.
///
/// Each column is a ``ScrollableTableColumn`` declared with a `weight`. The
/// total of all column weights is supplied once via `totalWeight`. A column
/// then receives a fraction of the available width equal to
/// `weight / totalWeight`, clamped by `minWidth`.
///
/// Resizing the window reflows columns without an extra state round-trip.
public struct ScrollableTable<Content: View>: View {
    private let totalWeight: Double
    private let content: Content

    public init(
        totalWeight: Double = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.totalWeight = totalWeight
        self.content = content()
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    content
                }
                    .environment(\.columnLayout, ColumnLayoutContext(
                        availableWidth: proxy.size.width,
                        totalWeight: totalWeight
                    ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

/// One weighted column inside ``ScrollableTable``.
///
/// The column receives a fraction of the table's available width equal to
/// `weight / totalWeight`, clamped by `minWidth`. `totalWeight` is supplied
/// once to the enclosing ``ScrollableTable``; if it is not, columns equal-split
/// the available width.
public struct ScrollableTableColumn<Header: View, Cells: View>: View {
    @Environment(\.columnLayout) private var layout: ColumnLayoutContext
    private let weight: Double
    private let minWidth: Double
    private let header: Header
    private let cells: Cells

    public init(
        weight: Double = 1.0,
        minWidth: Double = 0,
        @ViewBuilder header: () -> Header,
        @ViewBuilder cells: () -> Cells
    ) {
        self.weight = weight
        self.minWidth = minWidth
        self.header = header()
        self.cells = cells()
    }

    public var body: some View {
        let width = layout.width(for: weight, minWidth: minWidth)
        VStack(alignment: .leading, spacing: 0) {
            header
            cells
        }
        .frame(width: width, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Computation context that maps a column weight to a concrete pixel width.
struct ColumnLayoutContext {
    /// The total width the table can distribute across its columns.
    var availableWidth: Double
    /// Sum of `weight` values of all sibling columns. If zero, each column
    /// receives its `minWidth` (i.e. equal-split is approximated by giving
    /// each column 100% of the available width — see the per-column min).
    var totalWeight: Double

    func width(for weight: Double, minWidth: Double) -> Double {
        guard totalWeight > 0, availableWidth > 0 else { return minWidth }
        let share = availableWidth * (weight / totalWeight)
        return max(share, minWidth)
    }
}

private struct ColumnLayoutKey: EnvironmentKey {
    static let defaultValue = ColumnLayoutContext(
        availableWidth: 0,
        totalWeight: 0
    )
}

extension EnvironmentValues {
    /// Internal storage used by `ScrollableTable` to pass its measured width
    /// and the configured total weight to its `ScrollableTableColumn` children.
    var columnLayout: ColumnLayoutContext {
        get { self[ColumnLayoutKey.self] }
        set { self[ColumnLayoutKey.self] = newValue }
    }
}
