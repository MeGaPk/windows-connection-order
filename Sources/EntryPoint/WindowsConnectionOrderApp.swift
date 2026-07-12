import AppComposition
import DefaultBackend
import Domain
import Localization
import Nodes
import RepositoryImpl
import SwiftCrossUI
import UseCaseImpl

@main
@MainActor
struct WindowsConnectionOrderApp: App {
    @State private var navigationPath = NavigationPath()
    private var mainDependencies: MainDependencies!
    private var settingsDependencies: SettingsDependencies!

    init() {
        let adaptersUseCases = AppComposition.makeSystemAdaptersUseCases()
        let localizationRepository = LocalizationRepositoryImpl()
        let colorSchemeRepository = ColorSchemeRepositoryImpl()
        mainDependencies = MainDependencies(
            streamAdaptersUseCase: adaptersUseCases.stream,
            refreshAdaptersUseCase: adaptersUseCases.refresh,
            reorderAdaptersUseCase: adaptersUseCases.reorder,
            updateAdapterMetricUseCase: adaptersUseCases.updateMetric,
            streamLocalesUseCase: StreamLocalesUseCaseImpl(repository: localizationRepository),
            streamColorSchemeUseCase: StreamColorSchemeUseCaseImpl(repository: colorSchemeRepository),
            navigationPath: $navigationPath
        )
        settingsDependencies = SettingsDependencies(
            streamLocalesUseCase: StreamLocalesUseCaseImpl(repository: localizationRepository),
            setLocaleUseCase: SetLocaleUseCaseImpl(repository: localizationRepository),
            streamColorSchemeUseCase: StreamColorSchemeUseCaseImpl(repository: colorSchemeRepository),
            setColorSchemeUseCase: SetColorSchemeUseCaseImpl(repository: colorSchemeRepository),
            navigationPath: $navigationPath
        )
    }

    var body: some Scene {
        WindowGroup("Windows Connection Order") {
            NavigationStack(path: $navigationPath) {
                MainScreen(
                    viewModel: MainViewModel(dependencies: mainDependencies),
                    localizables: Localizables(locale: .systemDefault)
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
            viewModel: SettingsViewModel(dependencies: settingsDependencies),
            localizables: Localizables(locale: .systemDefault)
        )
    }

}
