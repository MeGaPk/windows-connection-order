import Domain

package protocol LocalizationRepository: Sendable {
    func streamLocales() async -> AsyncStream<LocaleSettings>
    func setLocale(_ locale: AppLocale) async
}
