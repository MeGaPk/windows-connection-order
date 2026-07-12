import Foundation

public struct NetworkAdapter: Identifiable, Sendable {
    public let id: UUID
    public var priority: Int
    public let name: String
    public let ipv4: IPv4Configuration
    public let ipv6: IPv6Configuration

    public init(
        id: UUID = UUID(),
        priority: Int,
        name: String,
        ipv4: IPv4Configuration,
        ipv6: IPv6Configuration
    ) {
        self.id = id
        self.priority = priority
        self.name = name
        self.ipv4 = ipv4
        self.ipv6 = ipv6
    }
}
