import Domain

package protocol ColorSchemeRepository: Sendable {
    func streamColorScheme() async -> AsyncStream<AppColorScheme>
    func setColorScheme(_ colorScheme: AppColorScheme) async
}
