import Domain
import Repository
import UseCase

public struct SetColorSchemeUseCaseImpl: SetColorSchemeUseCase {
    private let repository: any ColorSchemeRepository

    public init(repository: any ColorSchemeRepository) {
        self.repository = repository
    }

    public func execute(colorScheme: AppColorScheme) async {
        await repository.setColorScheme(colorScheme)
    }
}
