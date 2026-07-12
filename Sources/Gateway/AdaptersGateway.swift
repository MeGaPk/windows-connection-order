import Domain

public protocol AdaptersGateway: Sendable {
    func fetchAdapters() async -> [NetworkAdapter]
}
