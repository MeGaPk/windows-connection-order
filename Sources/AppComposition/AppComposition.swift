import Gateway
import GatewayImpl
import RepositoryImpl
import UseCaseImpl

#if os(Windows)
import WindowsNetworkGatewayImpl
#endif

public enum AppComposition {
    public static func makeSystemAdaptersUseCases() -> AdaptersUseCases {
        #if os(Windows)
        makeAdaptersUseCases(gateway: WindowsAdaptersGatewayImpl())
        #else
        makeAdaptersUseCases(gateway: MockAdaptersGateway())
        #endif
    }

    public static func makeAdaptersUseCases(
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
}
