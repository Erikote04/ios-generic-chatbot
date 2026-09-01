# Presentation and Language API

Public declarations for headers, launchers, presentation styles, recovery actions, response-language policies, and source presentation.

```swift
/// Presentation data and actions for a chatbot header.
@MainActor public struct ChatbotHeaderConfiguration {

    /// The configured assistant title.
    @MainActor public let title: String

    /// Whether the chatbot is retrieving context or generating a response.
    @MainActor public let activity: GenericChatbot.ChatbotActivity

    /// Starts a new conversation.
    @MainActor public let startNewConversation: () -> Void

    /// Closes the presentation when the chatbot was given a close action.
    @MainActor public let close: (() -> Void)?
}

/// Determines whether a chatbot style draws its own header or uses a system navigation bar.
public enum ChatbotHeaderPresentation : Sendable {

    /// Render the header returned by ``ChatbotStyle/makeHeader(configuration:)``
    /// directly above the chatbot content.
    case inline

    /// Present the title and actions in a native navigation toolbar.
    ///
    /// On supported Apple platforms, the system automatically gives toolbar
    /// controls Liquid Glass styling and coordinates them with scroll content.
    case navigationBar
}

/// A reusable button that presents arbitrary chatbot content.
///
/// The content builder receives a close action so an embedded ``ChatbotView`` can
/// display a working close control without knowing how it was presented.
@MainActor public struct ChatbotLauncher<Label, Content> : View where Label : View, Content : View {

    /// Creates a launcher with a custom label and chatbot content.
    ///
    /// - Parameters:
    ///   - presentationStyle: Whether to use a sheet or full-screen cover.
    ///   - accessibilityLabel: A localized description of the launch action.
    ///   - label: The visible button label.
    ///   - content: Chatbot content. Pass the supplied closure to `ChatbotView.close`.
    @MainActor public init(presentationStyle: GenericChatbot.ChatbotPresentationStyle = .sheet, accessibilityLabel: String = ChatbotStrings.default.launcherAccessibilityLabel, @ViewBuilder label: () -> Label, @ViewBuilder content: @escaping (@escaping () -> Void) -> Content)

    /// The launcher button and its modal presentation.
    @MainActor public var body: some View { get }
}

extension ChatbotLauncher where Label == GenericChatbot.DefaultChatbotLauncherLabel {

    /// Creates a launcher with the package's round SF Symbol label.
    ///
    /// - Parameters:
    ///   - presentationStyle: Whether to use a sheet or full-screen cover.
    ///   - accessibilityLabel: A localized description of the button.
    ///   - tint: The label background color.
    ///   - content: Chatbot content that receives a close action.
    @MainActor public init(presentationStyle: GenericChatbot.ChatbotPresentationStyle = .sheet, accessibilityLabel: String = ChatbotStrings.default.launcherAccessibilityLabel, tint: Color = .accentColor, @ViewBuilder content: @escaping (@escaping () -> Void) -> Content)
}

/// Presentation data and actions for a message row.
@MainActor public struct ChatbotMessageConfiguration {

    /// The message to display.
    @MainActor public let message: GenericChatbot.ChatMessage

    /// Retries this message when it failed and can be retried.
    @MainActor public let retry: (() -> Void)?
}

/// The modal presentation used by ``ChatbotLauncher``.
public enum ChatbotPresentationStyle : String, CaseIterable, Sendable {

    /// Present the chatbot in a system sheet.
    case sheet

    /// Present the chatbot in a full-screen cover.
    ///
    /// macOS presents a sheet because SwiftUI doesn't provide full-screen covers
    /// on that platform.
    case fullScreenCover
}

/// A recovery action that a style can present for a failure.
public enum ChatbotRecoveryAction : String, Codable, CaseIterable, Sendable {

    /// Check provider availability again.
    case retryAvailability

    /// Retrieve application context again.
    case retryRetrieval

    /// Generate the failed answer again.
    case retryResponse

    /// Cancel the active operation.
    case cancel

    /// Clear the active context and begin a new conversation.
    case startNewConversation

    /// Close the chatbot presentation.
    case dismiss
}

/// Controls the language and regional conventions used for model responses.
public enum ChatbotResponseLanguage : Equatable, Sendable {

    /// Follow the language of the person's latest request.
    ///
    /// The model continues using the person's most recently identifiable language
    /// for short or ambiguous follow-ups, and uses `fallback` when the conversation
    /// doesn't establish a language.
    case matchingUserInput(fallback: Locale = .current)

    /// Always respond using the application's current locale.
    ///
    /// `Locale.current` includes the language selected for the application in
    /// system settings. Resolve this locale when a model session is created.
    case appLocale

    /// Always respond using a developer-selected language and regional conventions.
    ///
    /// - Parameter locale: The required response locale.
    case fixed(Locale)
}

/// Presentation data for an application source card.
@MainActor public struct ChatbotSourceConfiguration {

    /// The source represented by the card.
    @MainActor public let source: GenericChatbot.ChatSource
}
```
