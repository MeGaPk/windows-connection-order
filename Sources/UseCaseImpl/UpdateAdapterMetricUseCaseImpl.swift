import Domain
import Repository
import UseCase

public struct UpdateAdapterMetricUseCaseImpl: UpdateAdapterMetricUseCase {
    private let repository: any AdaptersRepository

    public init(repository: any AdaptersRepository) {
        self.repository = repository
    }

    public func execute(adapterID: NetworkAdapter.ID, metric: Int) async -> Bool {
        await repository.updateAdapterMetric(adapterID: adapterID, metric: metric)
    }
}
