import Domain
import Localization
import SwiftCrossUI
import UIUtils

public struct MainScreen: View {
    @State private var viewModel: MainViewModel
    private let fallbackLocalizables: Localizables

    public init(viewModel: MainViewModel, localizables: Localizables) {
        _viewModel = State(wrappedValue: viewModel)
        fallbackLocalizables = localizables
    }

    public var body: some View {
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
        .colorScheme(viewModel.colorScheme)
        .preferredColorScheme(viewModel.colorScheme)
    }

    private var screenHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizables.main.appTitle).emphasized()
                Text(localizables.main.appSubtitle)
            }

            Spacer()

            languageAndThemeControls
        }
    }

    private var languageAndThemeControls: some View {
        HStack(spacing: 6) {
            Text(localizables.main.languageLabel)
            Picker(of: languageOptions, selection: languageSelection)
            Button(localizables.main.actionToggleTheme) {
                viewModel.toggleColorScheme()
            }
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
            .disabled(viewModel.selectedAdapterID == nil)

            Button(localizables.main.actionMoveDown) {
                viewModel.moveSelectedAdapter(by: 1)
            }
            .disabled(viewModel.selectedAdapterID == nil)
        }
    }

    private var selectionStatus: some View {
        Text(localizedSelectionState)
    }

    private var localizables: Localizables {
        guard let selectedLocale = viewModel.localeSettings?.selectedLocale else {
            return fallbackLocalizables
        }
        return Localizables(locale: selectedLocale)
    }

    private var availableLocales: [AppLocale] {
        viewModel.localeSettings?.availableLocales ?? []
    }

    private var languageOptions: [String] {
        availableLocales.map(localizedLanguageName)
    }

    private var languageSelection: Binding<String?> {
        let options = languageOptions

        return Binding(
            get: {
                guard let selectedLocale = viewModel.localeSettings?.selectedLocale,
                      let index = availableLocales.firstIndex(of: selectedLocale)
                else {
                    return nil
                }
                return options[index]
            },
            set: { selectedOption in
                guard let selectedOption,
                      let index = options.firstIndex(of: selectedOption)
                else {
                    return
                }
                viewModel.selectLocale(availableLocales[index])
            }
        )
    }

    private var localizedSelectionState: String {
        switch viewModel.adapterSelectionState {
            case .selectionRequired:
                localizables.main.statusNothingSelected
            case let .selected(name):
                localizables.main.statusSelected(name)
        }
    }

    private func localizedLanguageName(for locale: AppLocale) -> String {
        switch locale {
            case .english:
                localizables.main.languageEnglish
            case .russian:
                localizables.main.languageRussian
            case .estonian:
                localizables.main.languageEstonian
        }
    }

    private func adapterRow(_ adapter: NetworkAdapter, priority: Int) -> some View {
        HStack(spacing: 0) {
            tableCell("\(priority)", minWidth: 55, alignment: .trailing)
            tableCell(adapter.name, minWidth: 180)
            tableCell(adapter.ipv4.address.description, minWidth: 170)
            tableCell(adapter.ipv6.address.description, minWidth: 230)

            if adapter.id == viewModel.selectedAdapterID {
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
        if adapter.id == viewModel.selectedAdapterID {
            return UIColors.selectedRowBackground
        }

        if priority.isMultiple(of: 2) {
            return UIColors.alternateRowBackground
        }

        return UIColors.tableBackground
    }
}
