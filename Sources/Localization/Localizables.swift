import Foundation

public struct Localizables {
    let bundle: Bundle
    let locale: Locale

    public init(locale: AppLocale) {
        self.locale = Locale(identifier: locale.rawValue)

        if let languageURL = Bundle.module.url(forResource: locale.rawValue, withExtension: "lproj"),
           let languageBundle = Bundle(url: languageURL) {
            bundle = languageBundle
        }
        else if let englishURL = Bundle.module.url(forResource: AppLocale.english.rawValue, withExtension: "lproj"),
                let englishBundle = Bundle(url: englishURL) {
            bundle = englishBundle
        }
        else {
            bundle = Bundle.module
        }
    }
}
