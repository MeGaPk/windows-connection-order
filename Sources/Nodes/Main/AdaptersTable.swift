import Domain
import Localization
import SwiftCrossUI
import UIUtils

struct AdaptersTable: View {
    let viewModel: MainViewModel
    @Environment(\.localizablesProvider) private var localizablesProvider

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }

    // Total weight of all columns: 0.5 + 2.5 + 1.6 + 1.6 + 1.0 = 7.2
    private static let totalWeight: Double = 7.2

    var body: some View {
        ScrollableTable(totalWeight: Self.totalWeight) {
            orderColumn
            adapterColumn
            ipv4Column
            ipv6Column
            metricColumn
        }
        .frame(minHeight: 240, maxHeight: .infinity, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UIColors.Surface.table)
    }

    private var localizables: Localizables {
        if let current = localizablesProvider?.current {
            return current
        }
        if let selectedLocale = viewModel.localeSettings?.selectedLocale {
            return Localizables(locale: selectedLocale)
        }
        return Localizables(locale: .systemDefault)
    }

    private var orderColumn: some View {
        ScrollableTableColumn(weight: 0.5) {
            tableHeaderCell(localizables.main.columnOrder, alignment: .trailing)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                tableTextCell(
                    "\(item.offset + 1)",
                    alignment: .trailing,
                    isSelected: item.element.id == viewModel.selectedAdapter?.id,
                    priority: item.offset + 1
                )
                .onTapGesture {
                    viewModel.selectAdapter(id: item.element.id)
                }
            }
        }
    }

    private var adapterColumn: some View {
        ScrollableTableColumn(weight: 2.5, minWidth: 140) {
            tableHeaderCell(localizables.main.columnAdapter)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                tableTextCell(
                    item.element.name,
                    isSelected: item.element.id == viewModel.selectedAdapter?.id,
                    priority: item.offset + 1
                )
                .onTapGesture {
                    viewModel.selectAdapter(id: item.element.id)
                }
            }
        }
    }

    private var ipv4Column: some View {
        ScrollableTableColumn(weight: 1.6, minWidth: 110) {
            tableHeaderCell(localizables.main.columnIPv4)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                tableTextCell(
                    item.element.ipv4.address?.description ?? "-",
                    isSelected: item.element.id == viewModel.selectedAdapter?.id,
                    priority: item.offset + 1
                )
                .onTapGesture {
                    viewModel.selectAdapter(id: item.element.id)
                }
            }
        }
    }

    private var ipv6Column: some View {
        ScrollableTableColumn(weight: 1.6, minWidth: 110) {
            tableHeaderCell(localizables.main.columnIPv6)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                tableTextCell(
                    item.element.ipv6.address?.description ?? "-",
                    isSelected: item.element.id == viewModel.selectedAdapter?.id,
                    priority: item.offset + 1
                )
                .onTapGesture {
                    viewModel.selectAdapter(id: item.element.id)
                }
            }
        }
    }

    private var metricColumn: some View {
        ScrollableTableColumn(weight: 1.0, minWidth: 90) {
            tableHeaderCell(localizables.main.columnMetric)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                metricCell(for: item.element, priority: item.offset + 1)
            }
        }
    }

    @ViewBuilder
    private func metricCell(
        for adapter: NetworkAdapter,
        priority: Int
    ) -> some View {
        let isSelected = adapter.id == viewModel.selectedAdapter?.id
        let background = rowBackground(isSelected: isSelected, priority: priority)

        if isSelected {
            VStack(alignment: .leading, spacing: 2) {
                TextField(localizables.main.columnMetric, text: $viewModel.metricInput)
                    .onSubmit { viewModel.applyMetric() }
                if let message = viewModel.metricFieldError {
                    FieldHint(message: message)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .background(background)
            .onTapGesture {
                viewModel.selectAdapter(id: adapter.id)
            }
        }
        else {
            Text("\(adapter.metric)")
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .background(background)
                .onTapGesture {
                    viewModel.selectAdapter(id: adapter.id)
                }
        }
    }

    private func tableHeaderCell(
        _ value: String,
        alignment: Alignment = .leading
    ) -> some View {
        VStack(spacing: 0) {
            Text(value)
                .emphasized()
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, minHeight: 38, alignment: alignment)
                .background(UIColors.Surface.tableHeader)
            Divider(UIColors.Divider.default)
        }
    }

    private func tableTextCell(
        _ value: String,
        alignment: Alignment = .leading,
        isSelected: Bool,
        priority: Int
    ) -> some View {
        VStack(spacing: 0) {
            Text(value)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: alignment)
                .background(rowBackground(isSelected: isSelected, priority: priority))
            Divider(UIColors.Divider.default)
        }
    }

    private func rowBackground(isSelected: Bool, priority: Int) -> Color {
        if isSelected {
            return UIColors.Surface.selected
        }

        if priority.isMultiple(of: 2) {
            return UIColors.Surface.rowAlternate
        }

        return UIColors.Surface.table
    }
}
