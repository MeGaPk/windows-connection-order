import Foundation
import Domain
import Repository
import Utils

package actor LocalizationRepositoryImpl: LocalizationRepository {
    private static let selectedLocaleDefaultsKey = "selectedLocale"
    private let settings: AsyncCurrentValue<LocaleSettings>

    package init(
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

    package func streamLocales() async -> AsyncStream<LocaleSettings> {
        await settings.stream()
    }

    package func setLocale(_ locale: AppLocale) async {
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
