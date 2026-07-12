import Domain
import Gateway
import WinSDK

public struct WindowsAdaptersGatewayImpl: AdaptersGateway {
    public init() {}

    public func fetchAdapters() async -> [NetworkAdapter] {
        var winsockData = WSADATA()
        guard WSAStartup(WORD(0x0202), &winsockData) == 0 else {
            return []
        }
        defer { WSACleanup() }

        guard var buffer = adaptersBuffer() else {
            return []
        }

        return buffer.withUnsafeMutableBytes { bytes in
            var adapters: [NetworkAdapter] = []
            var pointer = bytes.baseAddress?.assumingMemoryBound(to: IP_ADAPTER_ADDRESSES.self)

            while let current = pointer {
                let adapter = current.pointee
                if let name = adapter.FriendlyName.map({ String(decodingCString: $0, as: UTF16.self) }) {
                    let addresses = addresses(from: adapter.FirstUnicastAddress)
                    adapters.append(
                        NetworkAdapter(
                            id: .init(luid: adapter.Luid.Value),
                            metric: Int(adapter.Ipv4Metric),
                            name: name,
                            ipv4: IPv4Configuration(address: addresses.ipv4),
                            ipv6: IPv6Configuration(address: addresses.ipv6)
                        )
                    )
                }
                pointer = adapter.Next
            }

            return adapters
        }
    }

    private func adaptersBuffer() -> [UInt8]? {
        var size: ULONG = 15_000

        for _ in 0 ..< 3 {
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

            if status == NO_ERROR {
                return buffer
            }

            guard status == ERROR_BUFFER_OVERFLOW else {
                return nil
            }
        }

        return nil
    }

    private func addresses(
        from firstAddress: PIP_ADAPTER_UNICAST_ADDRESS_LH?
    ) -> (ipv4: IPv4Address?, ipv6: IPv6Address?) {
        var ipv4Address: IPv4Address?
        var ipv6Address: IPv6Address?
        var pointer = firstAddress

        while let current = pointer {
            let address = current.pointee.Address

            if let value = addressString(from: address),
               let family = address.lpSockaddr?.pointee.sa_family {
                switch family {
                    case ADDRESS_FAMILY(AF_INET):
                        if ipv4Address == nil {
                            ipv4Address = IPv4Address(value)
                        }
                    case ADDRESS_FAMILY(AF_INET6):
                        if ipv6Address == nil {
                            ipv6Address = IPv6Address(value)
                        }
                    default:
                        break
                }
            }

            if ipv4Address != nil, ipv6Address != nil {
                break
            }

            pointer = current.pointee.Next
        }

        return (ipv4Address, ipv6Address)
    }

    private func addressString(from address: SOCKET_ADDRESS) -> String? {
        guard let socketAddress = address.lpSockaddr else {
            return nil
        }

        var length: DWORD = 256
        var buffer = [WCHAR](repeating: 0, count: Int(length))
        let status = WSAAddressToStringW(
            socketAddress,
            DWORD(address.iSockaddrLength),
            nil,
            &buffer,
            &length
        )

        guard status == 0 else {
            return nil
        }

        return String(decoding: buffer.prefix { $0 != 0 }, as: UTF16.self)
    }
}
