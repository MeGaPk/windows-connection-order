import SwiftCrossUI

public enum UIColors {
    public static let pageBackground = Color.adaptive(
        light: Color(white: 0.96),
        dark: Color(white: 0.08)
    )

    public static let tableBackground = Color.adaptive(
        light: .white,
        dark: Color(white: 0.13)
    )

    public static let tableHeaderBackground = Color.adaptive(
        light: Color(white: 0.9),
        dark: Color(white: 0.2)
    )

    public static let selectedRowBackground = Color.adaptive(
        light: Color.blue.opacity(0.2),
        dark: Color.blue.opacity(0.38)
    )

    public static let alternateRowBackground = Color.adaptive(
        light: Color(white: 0.94),
        dark: Color(white: 0.17)
    )
}
