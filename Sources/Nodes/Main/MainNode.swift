import Domain
import Localization
import SwiftCrossUI

public struct MainNode<Dependencies: MainViewModelDependencies>: View {
    @State private var viewModel: MainViewModel<Dependencies>

    private let pageBackground = Color.adaptive(
        light: Color(white: 0.96),
        dark: Color(white: 0.08)
    )
    private let tableBackground = Color.adaptive(
        light: .white,
        dark: Color(white: 0.13)
    )
    private let headerBackground = Color.adaptive(
        light: Color(white: 0.9),
        dark: Color(white: 0.2)
    )

    public init(viewModel: MainViewModel<Dependencies>) {
        _viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.localizables.main.appTitle).emphasized()
                    Text(viewModel.localizables.main.appSubtitle)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(viewModel.localizables.main.languageLabel)
                    Picker(of: languageOptions, selection: languageSelection)
                    Button(viewModel.localizables.main.actionToggleTheme) { viewModel.toggleColorScheme() }
                }
            }

            Text(viewModel.localizables.main.metricTitle).emphasized()
            Text(viewModel.localizables.main.metricHelp)

            VStack(alignment: .leading, spacing: 0) {
                tableHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.adapters) { adapter in
                            adapterRow(adapter, priority: displayPriority(for: adapter))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 240, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tableBackground)

            HStack {
                Button(viewModel.localizables.main.actionMoveUp) { viewModel.moveSelectedAdapter(by: -1) }
                    .disabled(viewModel.selectedAdapterID == nil)
                Button(viewModel.localizables.main.actionMoveDown) { viewModel.moveSelectedAdapter(by: 1) }
                    .disabled(viewModel.selectedAdapterID == nil)
                Button(viewModel.localizables.main.actionApplyDemo) { viewModel.applyAdapterOrder() }
            }

            Text(viewModel.statusMessage.isEmpty ? viewModel.localizables.main.statusNothingSelected : viewModel.statusMessage)
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(pageBackground)
        .colorScheme(viewModel.colorScheme)
        .preferredColorScheme(viewModel.colorScheme)
    }

    private var languageOptions: [String] {
        [
            viewModel.localizables.main.languageEnglish,
            viewModel.localizables.main.languageRussian,
            viewModel.localizables.main.languageEstonian
        ]
    }

    private var languageSelection: Binding<String?> {
        let options = languageOptions

        return Binding(
            get: {
                guard let index = AppLocale.allCases.firstIndex(of: viewModel.locale) else {
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
                viewModel.selectLocale(AppLocale.allCases[index])
            }
        )
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            tableCell(
                viewModel.localizables.main.columnOrder,
                minWidth: 55,
                alignment: .trailing,
                emphasized: true
            )
            tableCell(viewModel.localizables.main.columnAdapter, minWidth: 180, emphasized: true)
            tableCell(viewModel.localizables.main.columnIPv4, minWidth: 170, emphasized: true)
            tableCell(viewModel.localizables.main.columnIPv6, minWidth: 230, emphasized: true)
            tableCell(viewModel.localizables.main.columnMetric, minWidth: 150, emphasized: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 38, alignment: .leading)
        .background(headerBackground)
    }

    private func adapterRow(_ adapter: NetworkAdapter, priority: Int) -> some View {
        HStack(spacing: 0) {
            tableCell("\(priority)", minWidth: 55, alignment: .trailing)
            tableCell(adapter.name, minWidth: 180)
            tableCell(adapter.ipv4.address.description, minWidth: 170)
            tableCell(adapter.ipv6.address.description, minWidth: 230)

            if adapter.id == viewModel.selectedAdapterID {
                TextField(viewModel.localizables.main.columnMetric, text: $viewModel.metricInput)
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

    private func displayPriority(for adapter: NetworkAdapter) -> Int {
        (viewModel.adapters.firstIndex { $0.id == adapter.id } ?? 0) + 1
    }

    private func rowBackground(for adapter: NetworkAdapter, priority: Int) -> Color {
        if adapter.id == viewModel.selectedAdapterID {
            return Color.adaptive(light: Color.blue.opacity(0.2), dark: Color.blue.opacity(0.38))
        }

        if priority.isMultiple(of: 2) {
            return Color.adaptive(light: Color(white: 0.94), dark: Color(white: 0.17))
        }

        return tableBackground
    }
}
