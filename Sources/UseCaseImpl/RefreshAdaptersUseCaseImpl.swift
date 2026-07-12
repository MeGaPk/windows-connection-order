import Repository
import UseCase

public struct RefreshAdaptersUseCaseImpl: RefreshAdaptersUseCase {
    private let repository: any AdaptersRepository

    public init(repository: any AdaptersRepository) { self.repository = repository }

    public func execute() async { await repository.refreshAdapters() }
}
