import Domain

public protocol RefreshAdaptersUseCase: Sendable {
    func execute() async throws(NetworkAdapterError)
}
