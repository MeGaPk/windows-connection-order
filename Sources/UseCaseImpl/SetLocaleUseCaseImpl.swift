import Localization
import Repository
import UseCase

public struct SetLocaleUseCaseImpl<Repository: LocalizationRepository>: SetLocaleUseCase {
    private let repository: Repository

    public init(repository: Repository) {
        self.repository = repository
    }

    public func execute(locale: AppLocale) async {
        await repository.setLocale(locale)
    }
}
