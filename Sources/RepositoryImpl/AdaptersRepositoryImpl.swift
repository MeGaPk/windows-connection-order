import Domain
import Gateway
import Repository
import Utils

public actor AdaptersRepositoryImpl: AdaptersRepository {
    private let gateway: any AdaptersGateway
    private let adapters = AsyncCurrentValue<[NetworkAdapter]>([])

    public init(gateway: any AdaptersGateway) {
        self.gateway = gateway
    }

    public func streamAdapters() async -> AsyncStream<[NetworkAdapter]> {
        await adapters.stream()
    }

    public func refreshAdapters() async {
        let fetchedAdapters = await gateway.fetchAdapters()
        await adapters.update(fetchedAdapters)
    }

    public func reorderAdapters(selectedAdapterID: NetworkAdapter.ID, offset: Int) async -> Bool {
        var reorderedAdapters = await adapters.current()
        guard let currentIndex = reorderedAdapters.firstIndex(where: { $0.id == selectedAdapterID }) else { return false }
        let destinationIndex = currentIndex + offset
        guard reorderedAdapters.indices.contains(destinationIndex) else { return false }

        reorderedAdapters.swapAt(currentIndex, destinationIndex)
        let sortedMetrics = reorderedAdapters.map(\.metric).sorted()
        for index in reorderedAdapters.indices {
            reorderedAdapters[index].metric = sortedMetrics[index]
        }
        await adapters.update(reorderedAdapters)
        return true
    }

    public func updateAdapterMetric(adapterID: NetworkAdapter.ID, metric: Int) async -> Bool {
        guard metric >= 0 else {
            return false
        }

        var updatedAdapters = await adapters.current()
        guard let index = updatedAdapters.firstIndex(where: { $0.id == adapterID }) else {
            return false
        }

        updatedAdapters[index].metric = metric
        updatedAdapters.sort { $0.metric < $1.metric }

        await adapters.update(updatedAdapters)
        return true
    }
}
