import Domain
import Localization
import SwiftCrossUI
import UIUtils

@MainActor
@ObservableObject
public final class SettingsViewModel {
    private let dependencies: SettingsDependencies
    private weak var localizablesProvider: LocalizablesProvider?
    private var localesStreamTask: Task<Void, Never>?
    private var colorSchemeStreamTask: Task<Void, Never>?

    public var appColorScheme: AppColorScheme = .automatic
    public var localeSettings: LocaleSettings?

    public init(
        dependencies: SettingsDependencies,
        localizablesProvider: LocalizablesProvider
    ) {
        self.dependencies = dependencies
        self.localizablesProvider = localizablesProvider
        startLocalesStream()
        startColorSchemeStream()
    }

    deinit {
        localesStreamTask?.cancel()
        colorSchemeStreamTask?.cancel()
    }

    public func selectColorScheme(_ colorScheme: AppColorScheme) {
        let setColorSchemeUseCase = dependencies.setColorSchemeUseCase
        Task {
            await setColorSchemeUseCase.execute(colorScheme: colorScheme)
        }
    }

    public func selectLocale(_ locale: AppLocale) {
        let setLocaleUseCase = dependencies.setLocaleUseCase
        Task {
            await setLocaleUseCase.execute(locale: locale)
        }
    }

    public func goBack() {
        dependencies.navigationPath.wrappedValue.removeLast()
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
