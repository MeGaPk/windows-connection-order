import Domain
import Localization
import SwiftCrossUI
import UIUtils

public struct MainScreen: View {
    @State private var viewModel: MainViewModel
    private let fallbackLocalizables: Localizables

    public init(
        viewModel: MainViewModel,
        localizables: Localizables
    ) {
        _viewModel = State(wrappedValue: viewModel)
        fallbackLocalizables = localizables
    }

    public var body: some View {
        if let colorScheme {
            content
                .colorScheme(colorScheme)
                .preferredColorScheme(colorScheme)
        }
        else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            screenHeader
            metricDescription
            adaptersTable
            adapterActions
            selectionStatus
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(UIColors.pageBackground)
    }

    private var screenHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizables.main.appTitle).emphasized()
                Text(localizables.main.appSubtitle)
            }

            Spacer()

            Button(localizables.main.actionSettings) { viewModel.showSettings() }
        }
    }

    private var metricDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(localizables.main.metricTitle).emphasized()
            Text(localizables.main.metricHelp)
        }
    }

    private var adaptersTable: some View {
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
                adapterCell(for: item.element, priority: item.offset + 1) {
                    tableTextCell("\(item.offset + 1)", alignment: .trailing)
                }
            }
        }
    }

    private var adapterColumn: some View {
        ScrollableTableColumn {
            tableHeaderCell(localizables.main.columnAdapter)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                adapterCell(for: item.element, priority: item.offset + 1) {
                    tableTextCell(item.element.name)
                }
            }
        }
    }

    private var ipv4Column: some View {
        ScrollableTableColumn {
            tableHeaderCell(localizables.main.columnIPv4)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                adapterCell(for: item.element, priority: item.offset + 1) {
                    tableTextCell(item.element.ipv4.address?.description ?? "—")
                }
            }
        }
    }

    private var ipv6Column: some View {
        ScrollableTableColumn {
            tableHeaderCell(localizables.main.columnIPv6)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                adapterCell(for: item.element, priority: item.offset + 1) {
                    tableTextCell(item.element.ipv6.address?.description ?? "—")
                }
            }
        }
    }

    private var metricColumn: some View {
        ScrollableTableColumn {
            tableHeaderCell(localizables.main.columnMetric)
        } cells: {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                adapterCell(for: item.element, priority: item.offset + 1) {
                    metricCell(for: item.element)
                }
            }
        }
    }

    private var adapterActions: some View {
        HStack {
            Button(localizables.main.actionMoveUp) {
                viewModel.moveSelectedAdapter(by: -1)
            }
            .disabled(viewModel.selectedAdapter == nil)

            Button(localizables.main.actionMoveDown) {
                viewModel.moveSelectedAdapter(by: 1)
            }
            .disabled(viewModel.selectedAdapter == nil)
        }
    }

    private var selectionStatus: some View {
        Text(
            viewModel.selectedAdapter.map { localizables.main.statusSelected($0.name) }
                ?? localizables.main.statusNothingSelected
        )
    }

    private var localizables: Localizables {
        guard let selectedLocale = viewModel.localeSettings?.selectedLocale else {
            return fallbackLocalizables
        }
        return Localizables(locale: selectedLocale)
    }

    private var colorScheme: ColorScheme? {
        switch viewModel.appColorScheme {
            case .automatic:
                nil
            case .light:
                .light
            case .dark:
                .dark
        }
    }

    private func metricCell(for adapter: NetworkAdapter) -> some View {
        Group {
            if adapter.id == viewModel.selectedAdapter?.id {
                TextField(localizables.main.columnMetric, text: $viewModel.metricInput)
                    .onSubmit { viewModel.applyMetric() }
            }
            else {
                Text("\(adapter.metric)")
            }
        }
        .padding(6)
        .frame(height: 40, alignment: .leading)
    }

    private func tableHeaderCell(
        _ value: String,
        alignment: Alignment = .leading
    ) -> some View {
        Text(value)
            .emphasized()
            .padding(6)
            .frame(height: 38, alignment: alignment)
            .background(UIColors.tableHeaderBackground)
    }

    private func tableTextCell(
        _ value: String,
        alignment: Alignment = .leading
    ) -> some View {
        Text(value)
            .padding(6)
            .frame(height: 40, alignment: alignment)
    }

    private func adapterCell<Content: View>(
        for adapter: NetworkAdapter,
        priority: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .background(rowBackground(for: adapter, priority: priority))
            .onTapGesture {
                viewModel.selectAdapter(id: adapter.id)
            }
    }

    private func rowBackground(for adapter: NetworkAdapter, priority: Int) -> Color {
        if adapter.id == viewModel.selectedAdapter?.id {
            return UIColors.selectedRowBackground
        }

        if priority.isMultiple(of: 2) {
            return UIColors.alternateRowBackground
        }

        return UIColors.tableBackground
    }
}
