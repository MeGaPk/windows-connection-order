import DefaultBackend
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
    private let viewModel: MainViewModel

    init() {
        let adaptersRepository = MainRepository(gateway: MockAdaptersGateway())
        let localizationRepository = LocalizationRepositoryImpl()
        let dependencies = MainDependencies(
            streamAdaptersUseCase: StreamAdaptersUseCaseImpl(repository: adaptersRepository),
            refreshAdaptersUseCase: RefreshAdaptersUseCaseImpl(repository: adaptersRepository),
            reorderAdaptersUseCase: ReorderAdaptersUseCaseImpl(repository: adaptersRepository),
            updateAdapterMetricUseCase: UpdateAdapterMetricUseCaseImpl(repository: adaptersRepository),
            streamLocalesUseCase: StreamLocalesUseCaseImpl(repository: localizationRepository),
            setLocaleUseCase: SetLocaleUseCaseImpl(repository: localizationRepository)
        )

        viewModel = MainViewModel(dependencies: dependencies)
        viewModel.start()
    }

    var body: some Scene {
        WindowGroup("Windows Connection Order") {
            MainScreen(
                viewModel: viewModel,
                localizables: Localizables(locale: .systemDefault)
            )
        }
    }
}
