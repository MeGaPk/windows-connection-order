import Domain
import Repository
import UseCase

public struct UpdateAdapterMetricUseCaseImpl<Repository: AdaptersRepository>: UpdateAdapterMetricUseCase {
    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute(adapterID: NetworkAdapter.ID, metric: Int) async -> Bool {
        await repository.updateAdapterMetric(adapterID: adapterID, metric: metric)
    }
}
