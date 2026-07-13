import Domain
import Localization
import SwiftCrossUI
import UIUtils

struct AdaptersTable: View {
    @State private var viewModel: MainViewModel
    private let localizables: Localizables

    init(viewModel: MainViewModel, localizables: Localizables) {
        _viewModel = State(wrappedValue: viewModel)
        self.localizables = localizables
    }

    var body: some View {
        ScrollableTable {
            HStack(alignment: .top, spacing: 0) {
                orderColumn
                adapterColumn
                ipv4Column
                ipv6Column
                metricColumn
            }
        }
        .frame(minHeight: 240, maxHeight: .infinity, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UIColors.tableBackground)
    }

    private var orderColumn: some View {
        ScrollableTableColumn {
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
        ScrollableTableColumn {
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
        ScrollableTableColumn {
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
        ScrollableTableColumn {
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
        ScrollableTableColumn {
            tableHeaderCell(localizables.main.columnMetric)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                metricCell(for: item.element, priority: item.offset + 1)
            }
        }
    }

    private func metricCell(
        for adapter: NetworkAdapter,
        priority: Int
    ) -> some View {
        let isSelected = adapter.id == viewModel.selectedAdapter?.id
        let background = rowBackground(isSelected: isSelected, priority: priority)

        return Group {
            if isSelected {
                TextField(localizables.main.columnMetric, text: $viewModel.metricInput)
                    .onSubmit { viewModel.applyMetric() }
            }
            else {
                Text("\(adapter.metric)")
            }
        }
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
        .background(background)
        .onTapGesture {
            viewModel.selectAdapter(id: adapter.id)
        }
    }

    private func tableHeaderCell(
        _ value: String,
        alignment: Alignment = .leading
    ) -> some View {
        Text(value)
            .emphasized()
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 38, alignment: alignment)
            .background(UIColors.tableHeaderBackground)
    }

    private func tableTextCell(
        _ value: String,
        alignment: Alignment = .leading,
        isSelected: Bool,
        priority: Int
    ) -> some View {
        Text(value)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: alignment)
            .background(rowBackground(isSelected: isSelected, priority: priority))
    }

    private func rowBackground(isSelected: Bool, priority: Int) -> Color {
        if isSelected {
            return UIColors.selectedRowBackground
        }

        if priority.isMultiple(of: 2) {
            return UIColors.alternateRowBackground
        }

        return UIColors.tableBackground
    }
}
