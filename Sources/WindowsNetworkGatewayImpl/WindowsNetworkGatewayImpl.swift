import Domain
import Gateway
import WinSDK

public struct WindowsAdaptersGatewayImpl: AdaptersGateway {
    public init() {}

    public func fetchAdapters() async throws(NetworkAdapterError) -> [NetworkAdapter] {
        var winsockData = WSADATA()
        let wsaStartupResult = WSAStartup(WORD(0x0202), &winsockData)
        guard wsaStartupResult == 0 else {
            throw mapWindowsError(
                code: wsaStartupResult,
                message: "WSAStartup failed"
            )
        }
        defer { WSACleanup() }

        var buffer = try adaptersBuffer()

        let adapters: [NetworkAdapter] = buffer.withUnsafeMutableBytes { bytes in
            var collected: [NetworkAdapter] = []
            var pointer = bytes.baseAddress?.assumingMemoryBound(to: IP_ADAPTER_ADDRESSES.self)

            while let current = pointer {
                let adapter = current.pointee
                if let name = adapter.FriendlyName.map({ String(decodingCString: $0, as: UTF16.self) }) {
                    let addresses = addresses(from: adapter.FirstUnicastAddress)
                    collected.append(
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

            return collected
        }

        return adapters
    }

    private func adaptersBuffer() throws(NetworkAdapterError) -> [UInt8] {
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

            // ERROR_BUFFER_OVERFLOW means `size` was updated with the required size;
            // retry with the new size. Any other status is a hard failure.
            guard status == ERROR_BUFFER_OVERFLOW else {
                throw mapWindowsError(
                    code: Int32(bitPattern: status),
                    message: "GetAdaptersAddresses failed"
                )
            }
        }

        // 3 attempts in a row kept overflowing - give up.
        throw mapWindowsError(
            code: ERROR_BUFFER_OVERFLOW,
            message: "GetAdaptersAddresses kept reporting buffer overflow"
        )
    }

    private func mapWindowsError(
        code: Int32,
        message: String
    ) -> NetworkAdapterError {
        switch code {
            case Int32(ERROR_ACCESS_DENIED):
                .permissionDenied
            default:
                .systemError(code: code, message: message)
        }
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
