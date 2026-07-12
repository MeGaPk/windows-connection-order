import Domain
import Localization
import SwiftCrossUI

public enum AdapterSelectionState: Sendable, Equatable {
    case selectionRequired
    case selected(name: String)
}

@MainActor
@ObservableObject
public final class MainViewModel {
    private let dependencies: MainDependencies
    private var adaptersStreamTask: Task<Void, Never>?
    private var localesStreamTask: Task<Void, Never>?

    public var colorScheme: ColorScheme = .light
    public var adapters: [NetworkAdapter] = []
    public var localeSettings: LocaleSettings?
    public var selectedAdapterID: NetworkAdapter.ID?
    public var metricInput = ""
    public var adapterSelectionState: AdapterSelectionState = .selectionRequired

    public init(dependencies: MainDependencies) {
        self.dependencies = dependencies
    }

    deinit {
        adaptersStreamTask?.cancel()
        localesStreamTask?.cancel()
    }

    public func start() {
        startAdaptersStream()
        startLocalesStream()
        refreshAdapters()
    }

    public func toggleColorScheme() {
        switch colorScheme {
            case .light:
                colorScheme = .dark
            case .dark:
                colorScheme = .light
        }
    }

    public func selectLocale(_ locale: AppLocale) {
        let setLocaleUseCase = dependencies.setLocaleUseCase
        Task {
            await setLocaleUseCase.execute(locale: locale)
        }
    }

    public func selectAdapter(id: NetworkAdapter.ID) {
        selectedAdapterID = id
        guard let adapter = adapters.first(where: { $0.id == id }) else {
            return
        }
        metricInput = String(adapter.metric)
        adapterSelectionState = .selected(name: adapter.name)
    }

    public func moveSelectedAdapter(by offset: Int) {
        guard let selectedAdapterID else {
            adapterSelectionState = .selectionRequired
            return
        }

        let reorderAdaptersUseCase = dependencies.reorderAdaptersUseCase
        Task {
            _ = await reorderAdaptersUseCase.execute(
                selectedAdapterID: selectedAdapterID,
                offset: offset
            )
        }
    }

    public func applyMetric() {
        guard let selectedAdapterID,
              let metric = Int(metricInput),
              metric >= 0
        else {
            return
        }

        let updateAdapterMetricUseCase = dependencies.updateAdapterMetricUseCase
        Task {
            _ = await updateAdapterMetricUseCase.execute(
                adapterID: selectedAdapterID,
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
            }
        }
    }

    private func startLocalesStream() {
        guard localesStreamTask == nil else {
            return
        }

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

    private func refreshAdapters() {
        let refreshAdaptersUseCase = dependencies.refreshAdaptersUseCase
        Task {
            await refreshAdaptersUseCase.execute()
        }
    }
}
