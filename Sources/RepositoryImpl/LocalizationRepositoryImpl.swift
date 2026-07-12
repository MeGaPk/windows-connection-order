import Foundation
import Localization
import Repository
import Utils

public actor LocalizationRepositoryImpl: LocalizationRepository {
    private static let selectedLocaleDefaultsKey = "selectedLocale"
    private let settings: AsyncCurrentValue<LocaleSettings>

    public init(
        availableLocales: [AppLocale] = AppLocale.allCases,
        selectedLocale: AppLocale = .systemDefault
    ) {
        let storedLocale = UserDefaults.standard.string(forKey: Self.selectedLocaleDefaultsKey)
            .flatMap(AppLocale.init(rawValue:))
        let requestedLocale = storedLocale ?? selectedLocale
        let initialLocale = availableLocales.contains(requestedLocale)
            ? requestedLocale
            : availableLocales.first ?? .english
        settings = AsyncCurrentValue(
            LocaleSettings(
                availableLocales: availableLocales,
                selectedLocale: initialLocale
            )
        )
    }

    public func streamLocales() async -> AsyncStream<LocaleSettings> {
        await settings.stream()
    }

    public func setLocale(_ locale: AppLocale) async {
        let currentSettings = await settings.current()
        guard currentSettings.availableLocales.contains(locale) else {
            return
        }

        await settings.update(
            LocaleSettings(
                availableLocales: currentSettings.availableLocales,
                selectedLocale: locale
            )
        )
        UserDefaults.standard.set(locale.rawValue, forKey: Self.selectedLocaleDefaultsKey)
    }
}
