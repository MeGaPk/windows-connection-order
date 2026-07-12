import Domain
import Gateway

public struct MockAdaptersGateway: AdaptersGateway {
    public init() {}

    public func fetchAdapters() async -> [NetworkAdapter] {
        [
            NetworkAdapter(priority: 1, metric: 5, name: "Ethernet", ipv4: IPv4Configuration(address: IPv4Address("192.168.1.24")), ipv6: IPv6Configuration(address: IPv6Address("fe80::1a2b:3c4d:5e6f"))),
            NetworkAdapter(priority: 2, metric: 25, name: "Wi-Fi", ipv4: IPv4Configuration(address: IPv4Address("10.0.0.17")), ipv6: IPv6Configuration(address: IPv6Address("fe80::7a8b:9c0d:1e2f"))),
            NetworkAdapter(priority: 3, metric: 50, name: "Tailscale", ipv4: IPv4Configuration(address: IPv4Address("100.64.0.2")), ipv6: IPv6Configuration(address: IPv6Address("fd7a:115c:a1e0::42")))
        ]
    }
}
