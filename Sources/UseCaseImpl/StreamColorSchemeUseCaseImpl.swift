import Domain
import Repository
import UseCase

public struct StreamColorSchemeUseCaseImpl<Repository: ColorSchemeRepository>: StreamColorSchemeUseCase {
    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute() async -> AsyncStream<AppColorScheme> {
        await repository.streamColorScheme()
    }
}
