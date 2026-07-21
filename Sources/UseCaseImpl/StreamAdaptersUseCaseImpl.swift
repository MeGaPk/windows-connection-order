import Domain
import Repository
import UseCase

public struct StreamAdaptersUseCaseImpl: StreamAdaptersUseCase {
    private let repository: any AdaptersRepository

    public init(repository: any AdaptersRepository) { self.repository = repository }

    public func execute() async -> AsyncStream<[NetworkAdapter]> {
        await repository.streamAdapters()
    }
}
