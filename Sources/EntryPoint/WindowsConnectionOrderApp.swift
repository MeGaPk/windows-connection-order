import AppComposition
import DefaultBackend
import Domain
import Localization
import Nodes
import SwiftCrossUI

@main
@MainActor
struct WindowsConnectionOrderApp: App {
    @State private var navigationPath = NavigationPath()
    @State private var localizablesProvider: LocalizablesProvider
    private var mainDependencies: MainDependencies!
    private var settingsDependencies: SettingsDependencies!

    init() {
        let adaptersUseCases = AppComposition.makeSystemAdaptersUseCases()
        let localizationUseCases = AppComposition.makeLocalizationUseCases()
        let colorSchemeUseCases = AppComposition.makeColorSchemeUseCases()
        let initialLocalizables = Localizables(locale: .systemDefault)
        let provider = LocalizablesProvider(initial: initialLocalizables)
        _localizablesProvider = State(wrappedValue: provider)
        mainDependencies = MainDependencies(
            streamAdaptersUseCase: adaptersUseCases.stream,
            refreshAdaptersUseCase: adaptersUseCases.refresh,
            reorderAdaptersUseCase: adaptersUseCases.reorder,
            updateAdapterMetricUseCase: adaptersUseCases.updateMetric,
            streamLocalesUseCase: localizationUseCases.stream,
            streamColorSchemeUseCase: colorSchemeUseCases.stream,
            navigationPath: $navigationPath
        )
        settingsDependencies = SettingsDependencies(
            streamLocalesUseCase: localizationUseCases.stream,
            setLocaleUseCase: localizationUseCases.set,
            streamColorSchemeUseCase: colorSchemeUseCases.stream,
            setColorSchemeUseCase: colorSchemeUseCases.set,
            navigationPath: $navigationPath
        )
    }

    var body: some Scene {
        WindowGroup("Windows Connection Order") {
            NavigationStack(path: $navigationPath) {
                MainScreen(
                    viewModel: MainViewModel(
                        dependencies: mainDependencies,
                        localizablesProvider: localizablesProvider
                    ),
                    localizablesProvider: localizablesProvider
                )
            }
            .navigationDestination(for: AppNavigationDestination.self) { destination in
                switch destination {
                    case .settings:
                        settingsScreen()
                }
            }
        }
    }

    private func settingsScreen() -> some View {
        SettingsScreen(
            viewModel: SettingsViewModel(
                dependencies: settingsDependencies,
                localizablesProvider: localizablesProvider
            ),
            localizablesProvider: localizablesProvider
        )
    }
}
