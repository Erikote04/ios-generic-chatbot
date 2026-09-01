import SwiftUI

/// The modal presentation used by ``ChatbotLauncher``.
public enum ChatbotPresentationStyle: String, CaseIterable, Sendable {
    /// Present the chatbot in a system sheet.
    case sheet

    /// Present the chatbot in a full-screen cover.
    ///
    /// macOS presents a sheet because SwiftUI doesn't provide full-screen covers
    /// on that platform.
    case fullScreenCover
}

/// A reusable button that presents arbitrary chatbot content.
///
/// The content builder receives a close action so an embedded ``ChatbotView`` can
/// display a working close control without knowing how it was presented.
@MainActor
public struct ChatbotLauncher<Label: View, Content: View>: View {
    @State private var activePresentation: Presentation?

    @ViewBuilder private let label: Label
    private let presentationStyle: ChatbotPresentationStyle
    private let accessibilityLabel: String
    private let content: (@escaping () -> Void) -> Content

    /// Creates a launcher with a custom label and chatbot content.
    ///
    /// - Parameters:
    ///   - presentationStyle: Whether to use a sheet or full-screen cover.
    ///   - accessibilityLabel: A localized description of the launch action.
    ///   - label: The visible button label.
    ///   - content: Chatbot content. Pass the supplied closure to `ChatbotView.close`.
    public init(
        presentationStyle: ChatbotPresentationStyle = .sheet,
        accessibilityLabel: String = ChatbotStrings.default.launcherAccessibilityLabel,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content
    ) {
        self.presentationStyle = presentationStyle
        self.accessibilityLabel = accessibilityLabel
        self.label = label()
        self.content = content
    }

    /// The launcher button and its modal presentation.
    public var body: some View {
        switch presentationStyle {
        case .sheet:
            launcherButton
                .sheet(item: $activePresentation) { _ in
                    content(dismiss)
                }
        case .fullScreenCover:
#if os(macOS)
            launcherButton
                .sheet(item: $activePresentation) { _ in
                    content(dismiss)
                }
#else
            launcherButton
                .fullScreenCover(item: $activePresentation) { _ in
                    content(dismiss)
                }
#endif
        }
    }

    private var launcherButton: some View {
        Button {
            activePresentation = Presentation()
        } label: {
            label
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func dismiss() {
        activePresentation = nil
    }

    private struct Presentation: Identifiable {
        let id = UUID()
    }
}

extension ChatbotLauncher where Label == DefaultChatbotLauncherLabel {
    /// Creates a launcher with the package's round SF Symbol label.
    ///
    /// - Parameters:
    ///   - presentationStyle: Whether to use a sheet or full-screen cover.
    ///   - accessibilityLabel: A localized description of the button.
    ///   - tint: The label background color.
    ///   - content: Chatbot content that receives a close action.
    public init(
        presentationStyle: ChatbotPresentationStyle = .sheet,
        accessibilityLabel: String = ChatbotStrings.default.launcherAccessibilityLabel,
        tint: Color = .accentColor,
        @ViewBuilder content: @escaping (@escaping () -> Void) -> Content
    ) {
        self.init(
            presentationStyle: presentationStyle,
            accessibilityLabel: accessibilityLabel,
            label: { DefaultChatbotLauncherLabel(tint: tint) },
            content: content
        )
    }
}

/// The default round launcher label containing an SF Symbol.
@MainActor
public struct DefaultChatbotLauncherLabel: View {
    /// The circular glass tint.
    public var tint: Color

    /// Creates the default launcher label.
    ///
    /// - Parameter tint: The circular background color.
    public init(tint: Color = .accentColor) {
        self.tint = tint
    }

    /// A round, 56-point launcher label.
    public var body: some View {
        Image(systemName: "bubble.left.and.bubble.right.fill")
            .font(.title3)
            .foregroundStyle(.white)
            .frame(width: 56, height: 56)
            .glassEffect(
                .regular.tint(tint).interactive(),
                in: .circle
            )
            .contentShape(Circle())
    }
}
