import Domain

public protocol StreamColorSchemeUseCase: Sendable {
    func execute() async -> AsyncStream<AppColorScheme>
}
