import Gateway
import GatewayImpl
import RepositoryImpl
import UseCaseImpl

#if canImport(WindowsNetworkGatewayImpl)
import WindowsNetworkGatewayImpl
#endif

public enum AppComposition {
    public static func makeSystemAdaptersUseCases() -> AdaptersUseCases {
        #if canImport(WindowsNetworkGatewayImpl)
        makeAdaptersUseCases(gateway: WindowsNetworkGatewayImpl.WindowsAdaptersGatewayImpl())
        #else
        makeAdaptersUseCases(gateway: MockAdaptersGateway())
        #endif
    }

    package static func makeAdaptersUseCases(
        gateway: any AdaptersGateway
    ) -> AdaptersUseCases {
        let repository = AdaptersRepositoryImpl(gateway: gateway)

        return AdaptersUseCases(
            stream: StreamAdaptersUseCaseImpl(repository: repository),
            refresh: RefreshAdaptersUseCaseImpl(repository: repository),
            reorder: ReorderAdaptersUseCaseImpl(repository: repository),
            updateMetric: UpdateAdapterMetricUseCaseImpl(repository: repository)
        )
    }

    public static func makeLocalizationUseCases() -> LocalizationUseCases {
        let repository = LocalizationRepositoryImpl()

        return LocalizationUseCases(
            stream: StreamLocalesUseCaseImpl(repository: repository),
            set: SetLocaleUseCaseImpl(repository: repository)
        )
    }

    public static func makeColorSchemeUseCases() -> ColorSchemeUseCases {
        let repository = ColorSchemeRepositoryImpl()

        return ColorSchemeUseCases(
            stream: StreamColorSchemeUseCaseImpl(repository: repository),
            set: SetColorSchemeUseCaseImpl(repository: repository)
        )
    }
}
