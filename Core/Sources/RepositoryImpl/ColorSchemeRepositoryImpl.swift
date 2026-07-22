import Foundation
import Domain
import Repository
import Utils

package actor ColorSchemeRepositoryImpl: ColorSchemeRepository {
    private static let colorSchemeDefaultsKey = "colorScheme"
    private let colorScheme: AsyncCurrentValue<AppColorScheme>

    package init(initialColorScheme: AppColorScheme = .automatic) {
        let storedColorScheme = UserDefaults.standard.string(forKey: Self.colorSchemeDefaultsKey)
            .flatMap(AppColorScheme.init(rawValue:))
        colorScheme = AsyncCurrentValue(storedColorScheme ?? initialColorScheme)
    }

    package func streamColorScheme() async -> AsyncStream<AppColorScheme> {
        await colorScheme.stream()
    }

    package func setColorScheme(_ colorScheme: AppColorScheme) async {
        await self.colorScheme.update(colorScheme)
        UserDefaults.standard.set(colorScheme.rawValue, forKey: Self.colorSchemeDefaultsKey)
    }
}
