import Domain
import SwiftCrossUI

@MainActor
@ObservableObject
public final class MainViewModel {
    private let dependencies: MainDependencies
    private var adaptersStreamTask: Task<Void, Never>?
    private var localesStreamTask: Task<Void, Never>?
    private var colorSchemeStreamTask: Task<Void, Never>?

    public var adapters: [NetworkAdapter] = []
    public var selectedAdapter: NetworkAdapter?
    public var metricInput = ""
    public var localeSettings: LocaleSettings?
    public var appColorScheme: AppColorScheme = .automatic

    public init(dependencies: MainDependencies) {
        self.dependencies = dependencies
        startAdaptersStream()
        startLocalesStream()
        startColorSchemeStream()
        refreshAdapters()
    }

    deinit {
        adaptersStreamTask?.cancel()
        localesStreamTask?.cancel()
        colorSchemeStreamTask?.cancel()
    }

    public func showSettings() {
        dependencies.navigationPath.wrappedValue.append(AppNavigationDestination.settings)
    }

    public func goBack() {
        dependencies.navigationPath.wrappedValue.removeLast()
    }

    public func selectAdapter(id: NetworkAdapter.ID) {
        guard let adapter = adapters.first(where: { $0.id == id }) else {
            return
        }
        selectedAdapter = adapter
        metricInput = String(adapter.metric)
    }

    public func moveSelectedAdapter(by offset: Int) {
        guard let selectedAdapter else {
            return
        }

        let reorderAdaptersUseCase = dependencies.reorderAdaptersUseCase
        Task {
            _ = await reorderAdaptersUseCase.execute(
                selectedAdapterID: selectedAdapter.id,
                offset: offset
            )
        }
    }

    public func applyMetric() {
        guard let selectedAdapter,
              let metric = Int(metricInput),
              metric >= 0
        else {
            return
        }

        let updateAdapterMetricUseCase = dependencies.updateAdapterMetricUseCase
        Task {
            _ = await updateAdapterMetricUseCase.execute(
                adapterID: selectedAdapter.id,
                metric: metric
            )
        }
    }

    private func startAdaptersStream() {
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
                if let selectedAdapterID = self?.selectedAdapter?.id {
                    self?.selectedAdapter = adapters.first { $0.id == selectedAdapterID }
                }
            }
        }
    }

    private func refreshAdapters() {
        let refreshAdaptersUseCase = dependencies.refreshAdaptersUseCase
        Task {
            await refreshAdaptersUseCase.execute()
        }
    }

    private func startLocalesStream() {
        let streamLocalesUseCase = dependencies.streamLocalesUseCase
        localesStreamTask = Task { [weak self] in
            let localesStream = await streamLocalesUseCase.execute()

            for await localeSettings in localesStream {
                guard !Task.isCancelled else {
                    return
                }

                self?.localeSettings = localeSettings
            }
        }
    }

    private func startColorSchemeStream() {
        let streamColorSchemeUseCase = dependencies.streamColorSchemeUseCase
        colorSchemeStreamTask = Task { [weak self] in
            let colorSchemeStream = await streamColorSchemeUseCase.execute()

            for await colorScheme in colorSchemeStream {
                guard !Task.isCancelled else {
                    return
                }

                self?.appColorScheme = colorScheme
            }
        }
    }
}
