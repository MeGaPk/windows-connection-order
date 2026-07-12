import Domain

public protocol UpdateAdapterMetricUseCase: Sendable {
    func execute(adapterID: NetworkAdapter.ID, metric: Int) async throws(NetworkAdapterError)
}
