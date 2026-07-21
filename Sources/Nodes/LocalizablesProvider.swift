import Domain
import Foundation
import Localization
import SwiftCrossUI

/// Holds the active ``Localizables`` instance for the current UI tree.
///
/// View models observe the locale stream and update `current` on the main
/// actor. Views read `current` instead of constructing a new ``Localizables``
/// on every `body` evaluation.
///
/// `LocalizablesProvider` is marked with SwiftCrossUI's `@ObservableObject`
/// macro so that mutations of `current` automatically trigger view re-renders.
/// It is intended to be held in the `@State` of a long-lived scene (e.g. the
/// app) so that both the main screen and any pushed destinations share the
/// same localizables instance.
///
/// The class is `@unchecked Sendable` because SwiftCrossUI's `State`
/// property wrapper does not yet model value transfer through actor
/// isolation; in practice all reads and writes happen on the main actor
/// (the only place SwiftCrossUI runs view code), so a runtime race cannot
/// occur.
@MainActor
@ObservableObject
public final class LocalizablesProvider {
    public var current: Localizables

    public init(initial: Localizables) {
        self.current = initial
    }

    public func update(to locale: AppLocale) {
        current = Localizables(locale: locale)
    }
}

private struct LocalizablesProviderKey: EnvironmentKey {
    static var defaultValue: LocalizablesProvider? { nil }
}

extension EnvironmentValues {
    /// The active localizables provider, or `nil` if no provider has been
    /// pushed into the environment yet.
    var localizablesProvider: LocalizablesProvider? {
        get { self[LocalizablesProviderKey.self] }
        set { self[LocalizablesProviderKey.self] = newValue }
    }
}

extension View {
    /// Pushes a ``LocalizablesProvider`` into the view environment so that
    /// descendants can read the current localizables without rebuilding them.
    public func localizablesProvider(_ provider: LocalizablesProvider) -> some View {
        environment(\.localizablesProvider, provider)
    }
}
