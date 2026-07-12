import Domain
import Repository
import UseCase

public struct ReorderAdaptersUseCaseImpl<Repository: AdaptersRepository>: ReorderAdaptersUseCase {
    private let repository: Repository

    public init(repository: Repository) { self.repository = repository }

    public func execute(selectedAdapterID: NetworkAdapter.ID, offset: Int) async -> Bool {
        await repository.reorderAdapters(selectedAdapterID: selectedAdapterID, offset: offset)
    }
}
