import Domain
import Repository
import UseCase

package struct SetLocaleUseCaseImpl: SetLocaleUseCase {
    private let repository: any LocalizationRepository

    package init(repository: any LocalizationRepository) {
        self.repository = repository
    }

    package func execute(locale: AppLocale) async {
        await repository.setLocale(locale)
    }
}
