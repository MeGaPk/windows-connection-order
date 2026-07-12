import DefaultBackend
import Domain
import GatewayImpl
import Localization
import Nodes
import RepositoryImpl
import SwiftCrossUI
import UseCaseImpl

private typealias MainRepository = AdaptersRepositoryImpl<MockAdaptersGateway>
@main
@MainActor
struct WindowsConnectionOrderApp: App {
    @State private var navigationPath = NavigationPath()
    private var mainDependencies: MainDependencies!
    private var settingsDependencies: SettingsDependencies!

    init() {
        let adaptersRepository = MainRepository(gateway: MockAdaptersGateway())
        let localizationRepository = LocalizationRepositoryImpl()
        let colorSchemeRepository = ColorSchemeRepositoryImpl()
        mainDependencies = MainDependencies(
            streamAdaptersUseCase: StreamAdaptersUseCaseImpl(repository: adaptersRepository),
            refreshAdaptersUseCase: RefreshAdaptersUseCaseImpl(repository: adaptersRepository),
            reorderAdaptersUseCase: ReorderAdaptersUseCaseImpl(repository: adaptersRepository),
            updateAdapterMetricUseCase: UpdateAdapterMetricUseCaseImpl(repository: adaptersRepository),
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
