import Domain
import Localization
import SwiftCrossUI
import UIUtils

@MainActor
@ObservableObject
public final class MainViewModel {
    private let dependencies: MainDependencies
    private weak var localizablesProvider: LocalizablesProvider?
    private var adaptersStreamTask: Task<Void, Never>?
    private var localesStreamTask: Task<Void, Never>?
    private var colorSchemeStreamTask: Task<Void, Never>?

    public var adapters: [NetworkAdapter] = []
    public var selectedAdapter: NetworkAdapter?
    public var metricInput = ""
    public var localeSettings: LocaleSettings?
    public var appColorScheme: AppColorScheme = .automatic
    public var isRefreshing: Bool = false

    /// A system-level error (permission/system/unknown) that needs a global
    /// banner. `nil` means "no system error to show".
    public var systemError: String?

    /// An inline field error (e.g. invalid metric value) attached to the
    /// metric editor. `nil` means "no field error to show".
    public var metricFieldError: String?

    public init(
        dependencies: MainDependencies,
        localizablesProvider: LocalizablesProvider
    ) {
        self.dependencies = dependencies
        self.localizablesProvider = localizablesProvider
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
        metricFieldError = nil
        systemError = nil
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
                self?.systemError = nil
            } catch let error as NetworkAdapterError {
                self?.handleSystemError(error)
            }
        }
    }

    public func applyMetric() {
        guard let selectedAdapter else {
            return
        }
        guard let metric = Int(metricInput), metric >= 0 else {
            metricFieldError = localizedMessage(for: .invalidMetricValue(value: -1))
            return
        }

        metricFieldError = nil
        let updateAdapterMetricUseCase = dependencies.updateAdapterMetricUseCase
        let adapterID = selectedAdapter.id
        Task { [weak self] in
            do {
                try await updateAdapterMetricUseCase.execute(
                    adapterID: adapterID,
                    metric: metric
                )
                self?.systemError = nil
            } catch let error as NetworkAdapterError {
                self?.handleSystemError(error)
            }
        }
    }

    public func clearSystemError() {
        systemError = nil
    }

    private func handleSystemError(_ error: NetworkAdapterError) {
        // Field-level errors never reach here: invalidMetricValue is caught
        // in `applyMetric` before a use case is called.
        switch error {
            case .invalidMetricValue:
                metricFieldError = localizedMessage(for: error)
            default:
                systemError = localizedMessage(for: error)
        }
    }

    private func localizedMessage(for error: NetworkAdapterError) -> String {
        let localizables = currentLocalizables()
        switch error {
            case .permissionDenied:
                return localizables.main.errorPermissionDenied
            case .adapterNotFound:
                return localizables.main.errorAdapterNotFound
            case .invalidMetricValue:
                return localizables.main.errorInvalidMetricValue
            case .systemError(let code, let message):
                return localizables.main.errorSystemError(Int(code), message)
            case .unknown:
                return localizables.main.errorUnknown
        }
    }

    private func currentLocalizables() -> Localizables {
        if let current = localizablesProvider?.current {
            return current
        }
        if let selectedLocale = localeSettings?.selectedLocale {
            return Localizables(locale: selectedLocale)
        }
        return Localizables(locale: .systemDefault)
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
        isRefreshing = true
        Task { [weak self] in
            defer { self?.isRefreshing = false }
            do {
                try await refreshAdaptersUseCase.execute()
                self?.systemError = nil
            } catch let error as NetworkAdapterError {
                self?.handleSystemError(error)
            }
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
                if let provider = self?.localizablesProvider {
                    provider.update(to: localeSettings.selectedLocale)
                }
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
