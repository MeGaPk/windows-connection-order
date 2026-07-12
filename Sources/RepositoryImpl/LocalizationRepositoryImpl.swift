import Localization
import Repository
import Utils

public actor LocalizationRepositoryImpl: LocalizationRepository {
    private let settings: AsyncCurrentValue<LocaleSettings>

    public init(
        availableLocales: [AppLocale] = AppLocale.allCases,
        selectedLocale: AppLocale = .systemDefault
    ) {
        let initialLocale = availableLocales.contains(selectedLocale)
            ? selectedLocale
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
    }
}
