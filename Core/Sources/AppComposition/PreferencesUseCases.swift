import UseCase

public struct LocalizationUseCases: Sendable {
    public let stream: any StreamLocalesUseCase
    public let set: any SetLocaleUseCase

    public init(
        stream: any StreamLocalesUseCase,
        set: any SetLocaleUseCase
    ) {
        self.stream = stream
        self.set = set
    }
}

public struct ColorSchemeUseCases: Sendable {
    public let stream: any StreamColorSchemeUseCase
    public let set: any SetColorSchemeUseCase

    public init(
        stream: any StreamColorSchemeUseCase,
        set: any SetColorSchemeUseCase
    ) {
        self.stream = stream
        self.set = set
    }
}
