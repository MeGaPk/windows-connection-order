import SwiftCrossUI

/// Centralized, semantic color palette.
///
/// The palette is organized by role, not by raw color. New code should use the
/// semantic groups (`surface/*`, `text/*`, `accent/*`, `divider/*`). The
/// historical flat names remain as aliases for backward compatibility.
public enum UIColors {
    // MARK: - Surface (backgrounds)

    public enum Surface {
        public static let page = Color.adaptive(
            light: Color(white: 0.96),
            dark: Color(white: 0.08)
        )

        public static let table = Color.adaptive(
            light: .white,
            dark: Color(white: 0.13)
        )

        public static let tableHeader = Color.adaptive(
            light: Color(white: 0.9),
            dark: Color(white: 0.2)
        )

        public static let rowAlternate = Color.adaptive(
            light: Color(white: 0.94),
            dark: Color(white: 0.17)
        )

        public static let selected = Color.adaptive(
            light: Color.blue.opacity(0.2),
            dark: Color.blue.opacity(0.38)
        )

        public static let control = Color.adaptive(
            light: Color(white: 1.0),
            dark: Color(white: 0.18)
        )

        public static let error = Color.adaptive(
            light: Color(red: 1.0, green: 0.9, blue: 0.9),
            dark: Color(red: 0.4, green: 0.15, blue: 0.15)
        )
    }

    // MARK: - Text / Foreground

    public enum Text {
        public static let error = Color.adaptive(
            light: Color(red: 0.6, green: 0.0, blue: 0.0),
            dark: Color(red: 1.0, green: 0.7, blue: 0.7)
        )

        public static let disabled = Color.adaptive(
            light: Color(white: 0.55),
            dark: Color(white: 0.55)
        )
    }

    // MARK: - Accent

    public enum Accent {
        public static let primary = Color.adaptive(
            light: Color.blue,
            dark: Color(red: 0.4, green: 0.7, blue: 1.0)
        )

        public static let muted = Color.adaptive(
            light: Color.blue.opacity(0.6),
            dark: Color(red: 0.4, green: 0.7, blue: 1.0).opacity(0.6)
        )
    }

    // MARK: - Divider

    public enum Divider {
        public static let `default` = Color.adaptive(
            light: Color(white: 0.85),
            dark: Color(white: 0.25)
        )
    }

    // MARK: - Backward-compatible aliases

    public static var pageBackground: Color { Surface.page }
    public static var tableBackground: Color { Surface.table }
    public static var tableHeaderBackground: Color { Surface.tableHeader }
    public static var alternateRowBackground: Color { Surface.rowAlternate }
    public static var selectedRowBackground: Color { Surface.selected }
    public static var errorBackground: Color { Surface.error }
    public static var errorForeground: Color { Text.error }
}
