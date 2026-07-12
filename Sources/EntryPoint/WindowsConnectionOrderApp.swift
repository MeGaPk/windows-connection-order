import DefaultBackend
import GatewayImpl
import Localization
import Nodes
import RepositoryImpl
import SwiftCrossUI
import UseCaseImpl

private typealias MainRepository = AdaptersRepositoryImpl<MockAdaptersGateway>
private typealias ApplicationDependencies = MainDependencies<
    StreamAdaptersUseCaseImpl<MainRepository>,
    RefreshAdaptersUseCaseImpl<MainRepository>,
    ReorderAdaptersUseCaseImpl<MainRepository>,
    UpdateAdapterMetricUseCaseImpl<MainRepository>
>

@main
@MainActor
struct WindowsConnectionOrderApp: App {
    private let viewModel: MainViewModel<ApplicationDependencies>

    init() {
        let repository = MainRepository(gateway: MockAdaptersGateway())
        let dependencies = ApplicationDependencies(
            streamAdaptersUseCase: StreamAdaptersUseCaseImpl(repository: repository),
            refreshAdaptersUseCase: RefreshAdaptersUseCaseImpl(repository: repository),
            reorderAdaptersUseCase: ReorderAdaptersUseCaseImpl(repository: repository),
            updateAdapterMetricUseCase: UpdateAdapterMetricUseCaseImpl(repository: repository)
        )

        viewModel = MainViewModel(
            dependencies: dependencies,
            localizables: Localizables(locale: .systemDefault)
        )
        viewModel.start()
    }

    var body: some Scene {
        WindowGroup("Windows Connection Order") {
            MainNode(viewModel: viewModel)
        }
    }
}
