import Foundation

public enum AppLocale: String, CaseIterable, Sendable {
    case english = "en"
    case russian = "ru"
    case estonian = "et"

    public static var systemDefault: AppLocale {
        for identifier in Locale.preferredLanguages {
            let languageCode = identifier.split(separator: "-").first.map(String.init)

            if let languageCode, let locale = AppLocale(rawValue: languageCode) {
                return locale
            }
        }

        return .english
    }
}

public struct LocaleSettings: Sendable, Equatable {
    public let availableLocales: [AppLocale]
    public let selectedLocale: AppLocale

    public init(availableLocales: [AppLocale], selectedLocale: AppLocale) {
        self.availableLocales = availableLocales
        self.selectedLocale = selectedLocale
    }
}
