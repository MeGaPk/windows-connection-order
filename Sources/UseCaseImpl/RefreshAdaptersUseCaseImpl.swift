import Repository
import UseCase

public struct RefreshAdaptersUseCaseImpl<Repository: AdaptersRepository>: RefreshAdaptersUseCase {
    private let repository: Repository

    public init(repository: Repository) { self.repository = repository }

    public func execute() async { await repository.refreshAdapters() }
}
