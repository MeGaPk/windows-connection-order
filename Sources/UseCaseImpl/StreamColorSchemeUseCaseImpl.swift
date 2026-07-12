import Domain
import Repository
import UseCase

public struct StreamColorSchemeUseCaseImpl: StreamColorSchemeUseCase {
    private let repository: any ColorSchemeRepository

    public init(repository: any ColorSchemeRepository) {
        self.repository = repository
    }

    public func execute() async -> AsyncStream<AppColorScheme> {
        await repository.streamColorScheme()
    }
}
