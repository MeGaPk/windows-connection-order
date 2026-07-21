import Domain

public protocol AdaptersGateway: Sendable {
    func fetchAdapters() async throws(NetworkAdapterError) -> [NetworkAdapter]
}