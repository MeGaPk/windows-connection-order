import Domain
import Repository
import UseCase

public struct StreamLocalesUseCaseImpl<Repository: LocalizationRepository>: StreamLocalesUseCase {
    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute() async -> AsyncStream<LocaleSettings> {
        await repository.streamLocales()
    }
}
