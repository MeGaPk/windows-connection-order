public struct IPv6Configuration: Hashable, Sendable {
    public let address: IPv6Address
    public let metric: Int

    public init(address: IPv6Address, metric: Int) {
        self.address = address
        self.metric = metric
    }
}
