import Domain

public protocol AdaptersRepository: Sendable {
    func streamAdapters() async -> AsyncStream<[NetworkAdapter]>
    func refreshAdapters() async
    func reorderAdapters(selectedAdapterID: NetworkAdapter.ID, offset: Int) async -> Bool
    func updateAdapterMetric(adapterID: NetworkAdapter.ID, metric: Int) async -> Bool
}
