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
            AdaptersTable(viewModel: viewModel, localizables: localizables)
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
}
