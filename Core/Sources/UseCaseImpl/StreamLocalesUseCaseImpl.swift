import Domain
import Repository
import UseCase

package struct StreamLocalesUseCaseImpl: StreamLocalesUseCase {
    private let repository: any LocalizationRepository

    package init(repository: any LocalizationRepository) {
        self.repository = repository
    }

    package func execute() async -> AsyncStream<LocaleSettings> {
        await repository.streamLocales()
    }
}
