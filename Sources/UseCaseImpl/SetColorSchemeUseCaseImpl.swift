import Domain
import Repository
import UseCase

public struct SetColorSchemeUseCaseImpl<Repository: ColorSchemeRepository>: SetColorSchemeUseCase {
    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute(colorScheme: AppColorScheme) async {
        await repository.setColorScheme(colorScheme)
    }
}
