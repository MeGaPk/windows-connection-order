import Domain
import Repository
import UseCase

package struct SetColorSchemeUseCaseImpl: SetColorSchemeUseCase {
    private let repository: any ColorSchemeRepository

    package init(repository: any ColorSchemeRepository) {
        self.repository = repository
    }

    package func execute(colorScheme: AppColorScheme) async {
        await repository.setColorScheme(colorScheme)
    }
}
