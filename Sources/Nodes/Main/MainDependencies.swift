import UseCase

public struct MainDependencies: Sendable {
    public let streamAdaptersUseCase: any StreamAdaptersUseCase
    public let refreshAdaptersUseCase: any RefreshAdaptersUseCase
    public let reorderAdaptersUseCase: any ReorderAdaptersUseCase
    public let updateAdapterMetricUseCase: any UpdateAdapterMetricUseCase
    public let streamLocalesUseCase: any StreamLocalesUseCase
    public let setLocaleUseCase: any SetLocaleUseCase

    public init(
        streamAdaptersUseCase: some StreamAdaptersUseCase,
        refreshAdaptersUseCase: some RefreshAdaptersUseCase,
        reorderAdaptersUseCase: some ReorderAdaptersUseCase,
        updateAdapterMetricUseCase: some UpdateAdapterMetricUseCase,
        streamLocalesUseCase: some StreamLocalesUseCase,
        setLocaleUseCase: some SetLocaleUseCase
    ) {
        self.streamAdaptersUseCase = streamAdaptersUseCase
        self.refreshAdaptersUseCase = refreshAdaptersUseCase
        self.reorderAdaptersUseCase = reorderAdaptersUseCase
        self.updateAdapterMetricUseCase = updateAdapterMetricUseCase
        self.streamLocalesUseCase = streamLocalesUseCase
        self.setLocaleUseCase = setLocaleUseCase
    }
}
