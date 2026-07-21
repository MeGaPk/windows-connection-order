import Foundation

/// Typed errors for adapter-related operations. Used with Swift 6 typed throws
/// (e.g. `throws(NetworkAdapterError)`) so the call site can rely on the
/// compiler-checked exhaustive `catch`.
public enum NetworkAdapterError: Error, Sendable {
    /// Operation requires elevated (administrator) privileges.
    case permissionDenied

    /// Requested adapter was not found in the current state
    /// (e.g. disconnected or removed between calls).
    case adapterNotFound

    /// The metric value provided by the caller is not valid
    /// (negative, out of range, etc.).
    case invalidMetricValue(value: Int)

    /// A raw Windows / Winsock API call returned an unexpected error.
    case systemError(code: Int32, message: String)

    /// Any other unrecoverable failure.
    case unknown
}
