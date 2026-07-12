import Domain
import Repository
import UseCase

public struct ReorderAdaptersUseCaseImpl: ReorderAdaptersUseCase {
    private let repository: any AdaptersRepository

    public init(repository: any AdaptersRepository) { self.repository = repository }

    public func execute(selectedAdapterID: NetworkAdapter.ID, offset: Int) async -> Bool {
        await repository.reorderAdapters(selectedAdapterID: selectedAdapterID, offset: offset)
    }
}
