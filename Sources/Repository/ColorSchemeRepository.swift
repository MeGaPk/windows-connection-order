import Domain

public protocol ColorSchemeRepository: Sendable {
    func streamColorScheme() async -> AsyncStream<AppColorScheme>
    func setColorScheme(_ colorScheme: AppColorScheme) async
}
