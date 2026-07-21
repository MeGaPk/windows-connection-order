import Domain
import Repository
import UseCase

public struct StreamLocalesUseCaseImpl: StreamLocalesUseCase {
    private let repository: any LocalizationRepository

    public init(repository: any LocalizationRepository) {
        self.repository = repository
    }

    public func execute() async -> AsyncStream<LocaleSettings> {
        await repository.streamLocales()
    }
}
