import Domain

package protocol AdaptersRepository: Sendable {
    func streamAdapters() async -> AsyncStream<[NetworkAdapter]>
    func refreshAdapters() async throws(NetworkAdapterError)
    func reorderAdapters(
        selectedAdapterID: NetworkAdapter.ID,
        offset: Int
    ) async throws(NetworkAdapterError) -> Bool
    func updateAdapterMetric(
        adapterID: NetworkAdapter.ID,
        metric: Int
    ) async throws(NetworkAdapterError)
}