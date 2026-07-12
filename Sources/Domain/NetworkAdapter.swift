public struct NetworkAdapter: Identifiable, Sendable {
    public struct ID: Hashable, Sendable {
        public let luid: UInt64

        public init(luid: UInt64) {
            self.luid = luid
        }
    }

    public let id: ID
    public var metric: Int
    public let name: String
    public let ipv4: IPv4Configuration
    public let ipv6: IPv6Configuration

    public init(
        id: ID,
        metric: Int,
        name: String,
        ipv4: IPv4Configuration,
        ipv6: IPv6Configuration
    ) {
        self.id = id
        self.metric = metric
        self.name = name
        self.ipv4 = ipv4
        self.ipv6 = ipv6
    }
}
