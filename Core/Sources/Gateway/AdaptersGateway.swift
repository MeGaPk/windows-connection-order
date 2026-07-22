import Domain

package protocol AdaptersGateway: Sendable {
    func fetchAdapters() async throws(NetworkAdapterError) -> [NetworkAdapter]
}