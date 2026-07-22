import Domain
import Gateway
import Repository
import Utils

package actor AdaptersRepositoryImpl: AdaptersRepository {
    private let gateway: any AdaptersGateway
    private let adapters = AsyncCurrentValue<[NetworkAdapter]>([])

    package init(gateway: any AdaptersGateway) {
        self.gateway = gateway
    }

    package func streamAdapters() async -> AsyncStream<[NetworkAdapter]> {
        await adapters.stream()
    }

    package func refreshAdapters() async throws(NetworkAdapterError) {
        let fetchedAdapters = try await gateway.fetchAdapters()
        await adapters.update(fetchedAdapters)
    }

    package func reorderAdapters(
        selectedAdapterID: NetworkAdapter.ID,
        offset: Int
    ) async throws(NetworkAdapterError) -> Bool {
        var reorderedAdapters = await adapters.current()
        guard let currentIndex = reorderedAdapters.firstIndex(where: { $0.id == selectedAdapterID }) else {
            throw NetworkAdapterError.adapterNotFound
        }
        let destinationIndex = currentIndex + offset
        guard reorderedAdapters.indices.contains(destinationIndex) else {
            return false
        }

        reorderedAdapters.swapAt(currentIndex, destinationIndex)
        let sortedMetrics = reorderedAdapters.map(\.metric).sorted()
        for index in reorderedAdapters.indices {
            reorderedAdapters[index].metric = sortedMetrics[index]
        }
        await adapters.update(reorderedAdapters)
        return true
    }

    package func updateAdapterMetric(
        adapterID: NetworkAdapter.ID,
        metric: Int
    ) async throws(NetworkAdapterError) {
        guard metric >= 0 else {
            throw NetworkAdapterError.invalidMetricValue(value: metric)
        }

        var updatedAdapters = await adapters.current()
        guard let index = updatedAdapters.firstIndex(where: { $0.id == adapterID }) else {
            throw NetworkAdapterError.adapterNotFound
        }

        updatedAdapters[index].metric = metric
        updatedAdapters.sort { $0.metric < $1.metric }

        await adapters.update(updatedAdapters)
    }
}