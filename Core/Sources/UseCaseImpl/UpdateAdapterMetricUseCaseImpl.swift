import Domain
import Repository
import UseCase

package struct UpdateAdapterMetricUseCaseImpl: UpdateAdapterMetricUseCase {
    private let repository: any AdaptersRepository

    package init(repository: any AdaptersRepository) {
        self.repository = repository
    }

    package func execute(adapterID: NetworkAdapter.ID, metric: Int) async throws(NetworkAdapterError) {
        try await repository.updateAdapterMetric(adapterID: adapterID, metric: metric)
    }
}