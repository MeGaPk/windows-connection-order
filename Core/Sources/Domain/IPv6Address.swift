public struct IPv6Address: Hashable, CustomStringConvertible, Sendable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }
}
