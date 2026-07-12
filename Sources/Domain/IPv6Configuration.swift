public struct IPv6Configuration: Hashable, Sendable {
    public let address: IPv6Address

    public init(address: IPv6Address) {
        self.address = address
    }
}
