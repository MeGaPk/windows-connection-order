import Domain
import Localization
import SwiftCrossUI
import UIUtils

public struct MainScreen: View {
    @State private var viewModel: MainViewModel
    private let localizablesProvider: LocalizablesProvider

    public init(
        viewModel: MainViewModel,
        localizablesProvider: LocalizablesProvider
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.localizablesProvider = localizablesProvider
    }

    public var body: some View {
        Group {
            if let colorScheme {
                content
                    .colorScheme(colorScheme)
                    .preferredColorScheme(colorScheme)
            }
            else {
                content
            }
        }
        .environment(\.localizablesProvider, localizablesProvider)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            screenHeader
            metricDescription
            AdaptersTable(viewModel: viewModel)
            adapterActions
            selectionStatus
            errorStatus
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(UIColors.Surface.page)
    }

    private var screenHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(localizables.main.appTitle).emphasized()
                Text(localizables.main.appSubtitle)
            }

            Spacer()

            if viewModel.isRefreshing {
                HeaderProgressDot()
            }

            Button(localizables.main.actionSettings) {
                viewModel.showSettings()
            }
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
            .foregroundColor(
                viewModel.selectedAdapter == nil
                    ? UIColors.Text.disabled
                    : UIColors.Accent.primary
            )

            Button(localizables.main.actionMoveDown) {
                viewModel.moveSelectedAdapter(by: 1)
            }
            .disabled(viewModel.selectedAdapter == nil)
            .foregroundColor(
                viewModel.selectedAdapter == nil
                    ? UIColors.Text.disabled
                    : UIColors.Accent.primary
            )
        }
    }

    private var selectionStatus: some View {
        Text(
            viewModel.selectedAdapter.map { localizables.main.statusSelected($0.name) }
                ?? localizables.main.statusNothingSelected
        )
    }

    @ViewBuilder
    private var errorStatus: some View {
        if let errorMessage = viewModel.systemError {
            ErrorBanner(
                message: errorMessage,
                dismissTitle: localizables.main.actionDismiss
            ) {
                viewModel.clearSystemError()
            }
        }
    }

    private var localizables: Localizables {
        localizablesProvider.current
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
