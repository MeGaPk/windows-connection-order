import Domain
import Repository
import UseCase

public struct StreamAdaptersUseCaseImpl<Repository: AdaptersRepository>: StreamAdaptersUseCase {
    private let repository: Repository

    public init(repository: Repository) { self.repository = repository }

    public func execute() async -> AsyncStream<[NetworkAdapter]> {
        await repository.streamAdapters()
    }
}
