import UseCase

public struct AdaptersUseCases {
    public let stream: any StreamAdaptersUseCase
    public let refresh: any RefreshAdaptersUseCase
    public let reorder: any ReorderAdaptersUseCase
    public let updateMetric: any UpdateAdapterMetricUseCase

    public init(
        stream: any StreamAdaptersUseCase,
        refresh: any RefreshAdaptersUseCase,
        reorder: any ReorderAdaptersUseCase,
        updateMetric: any UpdateAdapterMetricUseCase
    ) {
        self.stream = stream
        self.refresh = refresh
        self.reorder = reorder
        self.updateMetric = updateMetric
    }
}
