import Localization

public protocol StreamLocalesUseCase: Sendable {
    func execute() async -> AsyncStream<LocaleSettings>
}
