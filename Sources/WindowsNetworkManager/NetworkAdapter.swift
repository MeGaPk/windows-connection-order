import Foundation

struct NetworkAdapter: Identifiable {
    let id: UUID
    var priority: Int
    let name: String
    let ipv4Address: String
    let ipv6Address: String
    let ipv4Metric: Int
    let ipv6Metric: Int

    init(
        id: UUID = UUID(),
        priority: Int,
        name: String,
        ipv4Address: String,
        ipv6Address: String,
        ipv4Metric: Int,
        ipv6Metric: Int
    ) {
        self.id = id
        self.priority = priority
        self.name = name
        self.ipv4Address = ipv4Address
        self.ipv6Address = ipv6Address
        self.ipv4Metric = ipv4Metric
        self.ipv6Metric = ipv6Metric
    }
}

extension NetworkAdapter {
    static let demoAdapters = [
        NetworkAdapter(
            priority: 1,
            name: "Ethernet",
            ipv4Address: "192.168.1.24",
            ipv6Address: "fe80::1a2b:3c4d:5e6f",
            ipv4Metric: 5,
            ipv6Metric: 5
        ),
        NetworkAdapter(
            priority: 2,
            name: "Wi-Fi",
            ipv4Address: "10.0.0.17",
            ipv6Address: "fe80::7a8b:9c0d:1e2f",
            ipv4Metric: 25,
            ipv6Metric: 25
        ),
        NetworkAdapter(
            priority: 3,
            name: "Tailscale",
            ipv4Address: "100.64.0.2",
            ipv6Address: "fd7a:115c:a1e0::42",
            ipv4Metric: 50,
            ipv6Metric: 50
        )
    ]
}
