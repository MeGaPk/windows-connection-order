import Foundation

public actor AsyncCurrentValue<Value: Sendable> {
    private var value: Value
    private var continuations: [UUID: AsyncStream<Value>.Continuation] = [:]

    public init(_ initialValue: Value) {
        value = initialValue
    }

    public func current() -> Value {
        value
    }

    public func update(_ newValue: Value) {
        value = newValue

        for continuation in continuations.values {
            continuation.yield(newValue)
        }
    }

    public func stream() -> AsyncStream<Value> {
        let observerID = UUID()

        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            continuations[observerID] = continuation
            continuation.yield(value)
            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.removeObserver(id: observerID)
                }
            }
        }
    }

    private func removeObserver(id: UUID) {
        continuations[id] = nil
    }
}
