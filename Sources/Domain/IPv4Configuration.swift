public struct IPv4Configuration: Hashable, Sendable {
    public let address: IPv4Address

    public init(address: IPv4Address) {
        self.address = address
    }
}
