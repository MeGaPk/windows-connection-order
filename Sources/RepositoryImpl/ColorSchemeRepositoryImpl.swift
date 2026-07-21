import Foundation
import Domain
import Repository
import Utils

public actor ColorSchemeRepositoryImpl: ColorSchemeRepository {
    private static let colorSchemeDefaultsKey = "colorScheme"
    private let colorScheme: AsyncCurrentValue<AppColorScheme>

    public init(initialColorScheme: AppColorScheme = .automatic) {
        let storedColorScheme = UserDefaults.standard.string(forKey: Self.colorSchemeDefaultsKey)
            .flatMap(AppColorScheme.init(rawValue:))
        colorScheme = AsyncCurrentValue(storedColorScheme ?? initialColorScheme)
    }

    public func streamColorScheme() async -> AsyncStream<AppColorScheme> {
        await colorScheme.stream()
    }

    public func setColorScheme(_ colorScheme: AppColorScheme) async {
        await self.colorScheme.update(colorScheme)
        UserDefaults.standard.set(colorScheme.rawValue, forKey: Self.colorSchemeDefaultsKey)
    }
}
