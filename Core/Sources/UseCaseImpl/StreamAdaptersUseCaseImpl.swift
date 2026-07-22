import Domain
import Repository
import UseCase

package struct StreamAdaptersUseCaseImpl: StreamAdaptersUseCase {
    private let repository: any AdaptersRepository

    package init(repository: any AdaptersRepository) { self.repository = repository }

    package func execute() async -> AsyncStream<[NetworkAdapter]> {
        await repository.streamAdapters()
    }
}
