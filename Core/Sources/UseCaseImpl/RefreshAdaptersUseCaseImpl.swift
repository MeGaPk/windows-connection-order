import Domain
import Repository
import UseCase

package struct RefreshAdaptersUseCaseImpl: RefreshAdaptersUseCase {
    private let repository: any AdaptersRepository

    package init(repository: any AdaptersRepository) { self.repository = repository }

    package func execute() async throws(NetworkAdapterError) { try await repository.refreshAdapters() }
}