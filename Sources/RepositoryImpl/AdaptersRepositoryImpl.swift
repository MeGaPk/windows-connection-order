import Domain
import Gateway
import Repository
import Utils

public actor AdaptersRepositoryImpl<Gateway: AdaptersGateway>: AdaptersRepository {
    private let gateway: Gateway
    private let adapters = AsyncCurrentValue<[NetworkAdapter]>([])

    public init(gateway: Gateway) {
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
        for index in reorderedAdapters.indices {
            reorderedAdapters[index].priority = index + 1
        }
        await adapters.update(reorderedAdapters)
        return true
    }
}
