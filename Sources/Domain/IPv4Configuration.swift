public struct IPv4Configuration: Hashable, Sendable {
    public let address: IPv4Address
    public let metric: Int

    public init(address: IPv4Address, metric: Int) {
        self.address = address
        self.metric = metric
    }
}
