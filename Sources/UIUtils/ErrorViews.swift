import SwiftCrossUI

/// A full-width banner that surfaces a system-level error message with a
/// dismiss action. Used for permission/system/unknown errors that the user
/// must acknowledge.
public struct ErrorBanner: View {
    private let message: String
    private let dismissTitle: String
    private let onDismiss: @MainActor @Sendable () -> Void

    public init(
        message: String,
        dismissTitle: String,
        onDismiss: @escaping @MainActor @Sendable () -> Void
    ) {
        self.message = message
        self.dismissTitle = dismissTitle
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(message)
                .foregroundColor(UIColors.Text.error)

            Spacer()

            Button(dismissTitle, action: onDismiss)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UIColors.Surface.error)
    }
}

/// A small inline hint rendered next to a field, e.g. under a metric editor.
/// Visually quieter than ``ErrorBanner``; it does not use the error surface
/// colour and stays attached to the field rather than spanning the screen.
public struct FieldHint: View {
    private let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .foregroundColor(UIColors.Text.error)
            .font(.system(size: 12))
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, minHeight: 18, alignment: .leading)
    }
}

/// A compact progress indicator intended to live next to a header button.
public struct HeaderProgressDot: View {
    public init() {}

    public var body: some View {
        ProgressView()
    }
}
