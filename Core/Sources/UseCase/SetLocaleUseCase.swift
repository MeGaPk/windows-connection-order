import Domain

public protocol SetLocaleUseCase: Sendable {
    func execute(locale: AppLocale) async
}
