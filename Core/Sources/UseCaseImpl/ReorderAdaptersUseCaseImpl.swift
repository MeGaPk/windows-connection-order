import Domain
import Repository
import UseCase

package struct ReorderAdaptersUseCaseImpl: ReorderAdaptersUseCase {
    private let repository: any AdaptersRepository

    package init(repository: any AdaptersRepository) { self.repository = repository }

    package func execute(selectedAdapterID: NetworkAdapter.ID, offset: Int) async throws(NetworkAdapterError) -> Bool {
        try await repository.reorderAdapters(selectedAdapterID: selectedAdapterID, offset: offset)
    }
}