import Domain
import Localization
import SwiftCrossUI
import UseCase

public protocol MainViewModelDependencies: Sendable {
    associatedtype StreamAdapters: StreamAdaptersUseCase
    associatedtype RefreshAdapters: RefreshAdaptersUseCase
    associatedtype ReorderAdapters: ReorderAdaptersUseCase

    var streamAdaptersUseCase: StreamAdapters { get }
    var refreshAdaptersUseCase: RefreshAdapters { get }
    var reorderAdaptersUseCase: ReorderAdapters { get }
}

public struct MainDependencies<
    StreamAdapters: StreamAdaptersUseCase,
    RefreshAdapters: RefreshAdaptersUseCase,
    ReorderAdapters: ReorderAdaptersUseCase
>: MainViewModelDependencies {
    public let streamAdaptersUseCase: StreamAdapters
    public let refreshAdaptersUseCase: RefreshAdapters
    public let reorderAdaptersUseCase: ReorderAdapters

    public init(
        streamAdaptersUseCase: StreamAdapters,
        refreshAdaptersUseCase: RefreshAdapters,
        reorderAdaptersUseCase: ReorderAdapters
    ) {
        self.streamAdaptersUseCase = streamAdaptersUseCase
        self.refreshAdaptersUseCase = refreshAdaptersUseCase
        self.reorderAdaptersUseCase = reorderAdaptersUseCase
    }
}

@MainActor
@ObservableObject
public final class MainViewModel<Dependencies: MainViewModelDependencies> {
    private let dependencies: Dependencies
    private var adaptersStreamTask: Task<Void, Never>?

    public var locale: AppLocale
    public var localizables: Localizables
    public var adapters: [NetworkAdapter] = []
    public var selectedAdapterID: NetworkAdapter.ID?
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

    public func selectAdapter(id: NetworkAdapter.ID) {
        selectedAdapterID = id
        statusMessage = ""
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
}
