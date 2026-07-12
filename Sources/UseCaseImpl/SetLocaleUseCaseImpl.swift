import Domain
import Repository
import UseCase

public struct SetLocaleUseCaseImpl: SetLocaleUseCase {
    private let repository: any LocalizationRepository

    public init(repository: any LocalizationRepository) {
        self.repository = repository
    }

    public func execute(locale: AppLocale) async {
        await repository.setLocale(locale)
    }
}
