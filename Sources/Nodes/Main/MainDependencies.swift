import SwiftCrossUI
import UseCase

public struct MainDependencies {
    public let streamAdaptersUseCase: any StreamAdaptersUseCase
    public let refreshAdaptersUseCase: any RefreshAdaptersUseCase
    public let reorderAdaptersUseCase: any ReorderAdaptersUseCase
    public let updateAdapterMetricUseCase: any UpdateAdapterMetricUseCase
    public let streamLocalesUseCase: any StreamLocalesUseCase
    public let streamColorSchemeUseCase: any StreamColorSchemeUseCase
    public let navigationPath: Binding<NavigationPath>

    public init(
        streamAdaptersUseCase: some StreamAdaptersUseCase,
        refreshAdaptersUseCase: some RefreshAdaptersUseCase,
        reorderAdaptersUseCase: some ReorderAdaptersUseCase,
        updateAdapterMetricUseCase: some UpdateAdapterMetricUseCase,
        streamLocalesUseCase: some StreamLocalesUseCase,
        streamColorSchemeUseCase: some StreamColorSchemeUseCase,
        navigationPath: Binding<NavigationPath>
    ) {
        self.streamAdaptersUseCase = streamAdaptersUseCase
        self.refreshAdaptersUseCase = refreshAdaptersUseCase
        self.reorderAdaptersUseCase = reorderAdaptersUseCase
        self.updateAdapterMetricUseCase = updateAdapterMetricUseCase
        self.streamLocalesUseCase = streamLocalesUseCase
        self.streamColorSchemeUseCase = streamColorSchemeUseCase
        self.navigationPath = navigationPath
    }
}
