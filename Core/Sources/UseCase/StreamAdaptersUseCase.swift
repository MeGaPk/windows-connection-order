import Domain

public protocol StreamAdaptersUseCase: Sendable {
    func execute() async -> AsyncStream<[NetworkAdapter]>
}
