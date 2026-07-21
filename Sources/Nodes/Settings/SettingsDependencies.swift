import SwiftCrossUI
import UseCase

public struct SettingsDependencies {
    public let streamLocalesUseCase: any StreamLocalesUseCase
    public let setLocaleUseCase: any SetLocaleUseCase
    public let streamColorSchemeUseCase: any StreamColorSchemeUseCase
    public let setColorSchemeUseCase: any SetColorSchemeUseCase
    public let navigationPath: Binding<NavigationPath>

    public init(
        streamLocalesUseCase: some StreamLocalesUseCase,
        setLocaleUseCase: some SetLocaleUseCase,
        streamColorSchemeUseCase: some StreamColorSchemeUseCase,
        setColorSchemeUseCase: some SetColorSchemeUseCase,
        navigationPath: Binding<NavigationPath>
    ) {
        self.streamLocalesUseCase = streamLocalesUseCase
        self.setLocaleUseCase = setLocaleUseCase
        self.streamColorSchemeUseCase = streamColorSchemeUseCase
        self.setColorSchemeUseCase = setColorSchemeUseCase
        self.navigationPath = navigationPath
    }
}
