import Domain

public protocol ReorderAdaptersUseCase: Sendable {
    func execute(selectedAdapterID: NetworkAdapter.ID, offset: Int) async throws(NetworkAdapterError) -> Bool
}