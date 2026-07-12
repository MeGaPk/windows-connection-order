import Domain

public protocol SetColorSchemeUseCase: Sendable {
    func execute(colorScheme: AppColorScheme) async
}
