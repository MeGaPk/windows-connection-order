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

    public var adapterError: NetworkAdapterError?

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
        adapterError = nil
    }

    public func moveSelectedAdapter(by offset: Int) {
        guard let selectedAdapter else {
            return
        }

        let reorderAdaptersUseCase = dependencies.reorderAdaptersUseCase
        let adapterID = selectedAdapter.id
        Task { [weak self] in
            do {
                _ = try await reorderAdaptersUseCase.execute(
                    selectedAdapterID: adapterID,
                    offset: offset
                )
                self?.adapterError = nil
            } catch {
                self?.adapterError = Self.networkAdapterError(from: error)
            }
        }
    }

    public func applyMetric() {
        guard let selectedAdapter else {
            return
        }
        guard let metric = Int(metricInput), metric >= 0 else {
            adapterError = .invalidMetricValue(value: -1)
            return
        }

        let updateAdapterMetricUseCase = dependencies.updateAdapterMetricUseCase
        let adapterID = selectedAdapter.id
        Task { [weak self] in
            do {
                try await updateAdapterMetricUseCase.execute(
                    adapterID: adapterID,
                    metric: metric
                )
                self?.adapterError = nil
            } catch {
                self?.adapterError = Self.networkAdapterError(from: error)
            }
        }
    }

    public func clearError() {
        adapterError = nil
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
        Task { [weak self] in
            do {
                try await refreshAdaptersUseCase.execute()
            } catch {
                self?.adapterError = Self.networkAdapterError(from: error)
            }
        }
    }

    private static func networkAdapterError(from error: any Error) -> NetworkAdapterError {
        error as? NetworkAdapterError ?? .unknown
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
