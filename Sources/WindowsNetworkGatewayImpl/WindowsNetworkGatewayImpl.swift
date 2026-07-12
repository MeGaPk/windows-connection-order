import Domain
import Gateway
import WinSDK

public struct WindowsAdaptersGatewayImpl: AdaptersGateway {
    public init() {}

    public func fetchAdapters() async -> [NetworkAdapter] {
        var size: ULONG = 15_000
        var buffer = [UInt8](repeating: 0, count: Int(size))

        let status = buffer.withUnsafeMutableBytes {
            GetAdaptersAddresses(
                ULONG(AF_UNSPEC),
                ULONG(GAA_FLAG_INCLUDE_PREFIX),
                nil,
                $0.baseAddress?.assumingMemoryBound(to: IP_ADAPTER_ADDRESSES.self),
                &size
            )
        }

        guard status == NO_ERROR else { return [] }

        return buffer.withUnsafeMutableBytes { bytes in
            var adapters: [NetworkAdapter] = []
            var pointer = bytes.baseAddress?.assumingMemoryBound(to: IP_ADAPTER_ADDRESSES.self)

            while let current = pointer {
                let adapter = current.pointee
                if let name = adapter.FriendlyName.map({ String(decodingCString: $0, as: UTF16.self) }) {
                    adapters.append(
                        NetworkAdapter(
                            id: .init(luid: adapter.Luid.Value),
                            metric: Int(adapter.Ipv4Metric),
                            name: name,
                            ipv4: IPv4Configuration(address: IPv4Address("0.0.0.0")),
                            ipv6: IPv6Configuration(address: IPv6Address("::"))
                        )
                    )
                }
                pointer = adapter.Next
            }

            return adapters
        }
    }
}
