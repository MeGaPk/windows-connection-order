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
        VStack(alignment: .leading, spacing: 0) {
            tableHeader

            ScrollView {
                adapterRows
            }
            .frame(minHeight: 240, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UIColors.tableBackground)
    }

    private var adapterRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(viewModel.adapters.enumerated()), id: \.element.id) { item in
                adapterRow(item.element, priority: item.offset + 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            tableCell(localizables.main.columnOrder, minWidth: 55, alignment: .trailing, emphasized: true)
            tableCell(localizables.main.columnAdapter, minWidth: 180, emphasized: true)
            tableCell(localizables.main.columnIPv4, minWidth: 170, emphasized: true)
            tableCell(localizables.main.columnIPv6, minWidth: 230, emphasized: true)
            tableCell(localizables.main.columnMetric, minWidth: 150, emphasized: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 38, alignment: .leading)
        .background(UIColors.tableHeaderBackground)
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

    private func adapterRow(_ adapter: NetworkAdapter, priority: Int) -> some View {
        HStack(spacing: 0) {
            tableCell("\(priority)", minWidth: 55, alignment: .trailing)
            tableCell(adapter.name, minWidth: 180)
            tableCell(adapter.ipv4.address.description, minWidth: 170)
            tableCell(adapter.ipv6.address.description, minWidth: 230)

            if adapter.id == viewModel.selectedAdapter?.id {
                TextField(localizables.main.columnMetric, text: $viewModel.metricInput)
                    .onSubmit { viewModel.applyMetric() }
                    .padding(6)
                    .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
                    .frame(height: 40, alignment: .leading)
            }
            else {
                tableCell("\(adapter.metric)", minWidth: 150)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 40, alignment: .leading)
        .background(rowBackground(for: adapter, priority: priority))
        .onTapGesture {
            viewModel.selectAdapter(id: adapter.id)
        }
    }

    private func tableCell(
        _ value: String,
        minWidth: Double,
        alignment: Alignment = .leading,
        emphasized: Bool = false
    ) -> some View {
        Group {
            if emphasized {
                Text(value).emphasized()
            }
            else {
                Text(value)
            }
        }
        .padding(6)
        .frame(minWidth: minWidth, maxWidth: .infinity, alignment: alignment)
        .frame(height: 40, alignment: alignment)
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
