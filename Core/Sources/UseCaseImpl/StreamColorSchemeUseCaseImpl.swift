import Domain
import Repository
import UseCase

package struct StreamColorSchemeUseCaseImpl: StreamColorSchemeUseCase {
    private let repository: any ColorSchemeRepository

    package init(repository: any ColorSchemeRepository) {
        self.repository = repository
    }

    package func execute() async -> AsyncStream<AppColorScheme> {
        await repository.streamColorScheme()
    }
}
