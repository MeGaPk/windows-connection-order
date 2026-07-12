import Domain
import Localization
import SwiftCrossUI
import UseCase

public protocol MainViewModelDependencies: Sendable {
    associatedtype StreamAdapters: StreamAdaptersUseCase
    associatedtype RefreshAdapters: RefreshAdaptersUseCase
    associatedtype ReorderAdapters: ReorderAdaptersUseCase
    associatedtype UpdateAdapterMetric: UpdateAdapterMetricUseCase

    var streamAdaptersUseCase: StreamAdapters { get }
    var refreshAdaptersUseCase: RefreshAdapters { get }
    var reorderAdaptersUseCase: ReorderAdapters { get }
    var updateAdapterMetricUseCase: UpdateAdapterMetric { get }
}

public struct MainDependencies<
    StreamAdapters: StreamAdaptersUseCase,
    RefreshAdapters: RefreshAdaptersUseCase,
    ReorderAdapters: ReorderAdaptersUseCase,
    UpdateAdapterMetric: UpdateAdapterMetricUseCase
>: MainViewModelDependencies {
    public let streamAdaptersUseCase: StreamAdapters
    public let refreshAdaptersUseCase: RefreshAdapters
    public let reorderAdaptersUseCase: ReorderAdapters
    public let updateAdapterMetricUseCase: UpdateAdapterMetric

    public init(
        streamAdaptersUseCase: StreamAdapters,
        refreshAdaptersUseCase: RefreshAdapters,
        reorderAdaptersUseCase: ReorderAdapters,
        updateAdapterMetricUseCase: UpdateAdapterMetric
    ) {
        self.streamAdaptersUseCase = streamAdaptersUseCase
        self.refreshAdaptersUseCase = refreshAdaptersUseCase
        self.reorderAdaptersUseCase = reorderAdaptersUseCase
        self.updateAdapterMetricUseCase = updateAdapterMetricUseCase
    }
}

@MainActor
@ObservableObject
public final class MainViewModel<Dependencies: MainViewModelDependencies> {
    private let dependencies: Dependencies
    private var adaptersStreamTask: Task<Void, Never>?

    public var locale: AppLocale
    public var colorScheme: ColorScheme = .light
    public var localizables: Localizables
    public var adapters: [NetworkAdapter] = []
    public var selectedAdapterID: NetworkAdapter.ID?
    public var metricInput = ""
    public var statusMessage = ""

    public init(dependencies: Dependencies, localizables: Localizables) {
        self.dependencies = dependencies
        self.localizables = localizables
        locale = .systemDefault
    }

    deinit {
        adaptersStreamTask?.cancel()
    }

    public func start() {
        guard adaptersStreamTask == nil else {
            return
        }

        let streamAdaptersUseCase = dependencies.streamAdaptersUseCase
        adaptersStreamTask = Task { [weak self] in
            let adaptersStream = await streamAdaptersUseCase.execute()

            for await adapters in adaptersStream {
                guard !Task.isCancelled else {
                    return
                }

                self?.adapters = adapters
            }
        }

        let refreshAdaptersUseCase = dependencies.refreshAdaptersUseCase
        Task {
            await refreshAdaptersUseCase.execute()
        }
    }

    public func selectLocale(_ locale: AppLocale) {
        self.locale = locale
        localizables = Localizables(locale: locale)
        statusMessage = ""
    }

    public func toggleColorScheme() {
        switch colorScheme {
            case .light:
                colorScheme = .dark
            case .dark:
                colorScheme = .light
        }
    }

    public func selectAdapter(id: NetworkAdapter.ID) {
        selectedAdapterID = id
        guard let adapter = adapters.first(where: { $0.id == id }) else {
            return
        }
        metricInput = String(adapter.metric)
        statusMessage = localizables.main.statusSelected(adapter.name)
    }

    public func moveSelectedAdapter(by offset: Int) {
        guard let selectedAdapterID else {
            statusMessage = localizables.main.statusNothingSelected
            return
        }

        let reorderAdaptersUseCase = dependencies.reorderAdaptersUseCase
        Task { [weak self] in
            let didReorder = await reorderAdaptersUseCase.execute(
                selectedAdapterID: selectedAdapterID,
                offset: offset
            )

            if !didReorder {
                self?.statusMessage = self?.localizables.main.statusNothingSelected ?? ""
            }
        }
    }

    public func applyAdapterOrder() {
        statusMessage = localizables.main.statusDemoApplied
    }

    public func applyMetric() {
        guard let selectedAdapterID,
              let metric = Int(metricInput),
              metric >= 0,
              let adapter = adapters.first(where: { $0.id == selectedAdapterID })
        else {
            statusMessage = localizables.main.statusInvalidMetric
            return
        }

        let updateAdapterMetricUseCase = dependencies.updateAdapterMetricUseCase
        let adapterName = adapter.name
        Task { [weak self] in
            let didUpdate = await updateAdapterMetricUseCase.execute(
                adapterID: selectedAdapterID,
                metric: metric
            )

            self?.statusMessage = didUpdate
                ? self?.localizables.main.statusMetricApplied(adapterName, metric) ?? ""
                : self?.localizables.main.statusInvalidMetric ?? ""
        }
    }
}
