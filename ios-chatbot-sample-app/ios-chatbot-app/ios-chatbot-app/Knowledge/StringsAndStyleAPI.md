# Strings, Style, and Theme API

Public declarations for localized strings, complete presentation styles, and semantic theming.

```swift
/// Localized text used by the default chatbot style and error presenter.
///
/// Initialize this value with strings localized by the host application. Keeping
/// localization outside the package lets one chatbot support every app language.
public struct ChatbotStrings : Equatable, Sendable {

    /// The accessibility label for the default launcher button.
    public var launcherAccessibilityLabel: String

    /// The empty-state title.
    public var emptyTitle: String

    /// The empty-state guidance.
    public var emptyMessage: String

    /// The composer placeholder.
    public var composerPlaceholder: String

    /// The send button label.
    public var send: String

    /// The cancel-generation button label.
    public var cancel: String

    /// The retry button label.
    public var retry: String

    /// The close button label.
    public var close: String

    /// The new-conversation button label.
    public var newConversation: String

    /// The title displayed while checking model availability.
    public var checkingAvailabilityTitle: String

    /// The message displayed while checking model availability.
    public var checkingAvailabilityMessage: String

    /// The generic error title.
    public var genericErrorTitle: String

    /// The generic error message.
    public var genericErrorMessage: String

    /// The unsupported-device message.
    public var unsupportedDeviceMessage: String

    /// The disabled-service message.
    public var serviceDisabledMessage: String

    /// The model-not-ready message.
    public var modelNotReadyMessage: String

    /// The unsupported-language message.
    public var unsupportedLanguageMessage: String

    /// The offline message.
    public var offlineMessage: String

    /// The request-timeout message.
    public var timeoutMessage: String

    /// The authentication-failure message.
    public var authenticationMessage: String

    /// The safety-guardrail response.
    public var safetyMessage: String

    /// The refusal fallback response.
    public var refusalMessage: String

    /// The context-window error message.
    public var contextWindowMessage: String

    /// The response used when grounded retrieval returns no relevant content.
    public var informationUnavailableMessage: String

    /// The label introducing source cards.
    public var sources: String

    /// Creates the localized strings used by the chatbot.
    ///
    /// - Parameters:
    ///   - launcherAccessibilityLabel: Accessibility label for the default launcher.
    ///   - emptyTitle: Title shown before the first message.
    ///   - emptyMessage: Guidance shown before the first message.
    ///   - composerPlaceholder: Placeholder shown in the composer.
    ///   - send: Label for submitting a message.
    ///   - cancel: Label for stopping generation.
    ///   - retry: Label for retrying a failed operation.
    ///   - close: Label for closing the presentation.
    ///   - newConversation: Label for starting a new conversation.
    ///   - checkingAvailabilityTitle: Title shown during the availability check.
    ///   - checkingAvailabilityMessage: Explanation shown during the availability check.
    ///   - genericErrorTitle: Fallback failure title.
    ///   - genericErrorMessage: Fallback failure explanation.
    ///   - unsupportedDeviceMessage: Message for an ineligible device.
    ///   - serviceDisabledMessage: Message for a disabled model service.
    ///   - modelNotReadyMessage: Message for model assets that aren't ready.
    ///   - unsupportedLanguageMessage: Message for an unsupported language or locale.
    ///   - offlineMessage: Message when a required network is unavailable.
    ///   - timeoutMessage: Message when a request times out.
    ///   - authenticationMessage: Message when provider authentication fails.
    ///   - safetyMessage: Message when a safety guardrail blocks generation.
    ///   - refusalMessage: Fallback message when the model refuses a request.
    ///   - contextWindowMessage: Message when conversation context is too large.
    ///   - informationUnavailableMessage: Message when grounded retrieval finds no context.
    ///   - sources: Label introducing source cards.
    /// - Tip: Start from ``ChatbotStrings/default`` and override only strings your
    ///   application needs to customize.
    public init(launcherAccessibilityLabel: String = "Open assistant", emptyTitle: String = "How can I help?", emptyMessage: String = "Ask a question to start a conversation.", composerPlaceholder: String = "Message", send: String = "Send", cancel: String = "Stop", retry: String = "Retry", close: String = "Close", newConversation: String = "New conversation", checkingAvailabilityTitle: String = "Preparing assistant", checkingAvailabilityMessage: String = "Checking whether the configured model is available.", genericErrorTitle: String = "Something went wrong", genericErrorMessage: String = "The assistant couldn't complete that request.", unsupportedDeviceMessage: String = "This device doesn't support the configured model.", serviceDisabledMessage: String = "The model service isn't enabled in system settings.", modelNotReadyMessage: String = "The model isn't ready yet. Its assets may still be downloading.", unsupportedLanguageMessage: String = "The model doesn't support the current language or locale.", offlineMessage: String = "A required network connection isn't available.", timeoutMessage: String = "The request took too long to complete.", authenticationMessage: String = "The configured service couldn't authenticate this request.", safetyMessage: String = "I can't help with that request.", refusalMessage: String = "The model chose not to answer that request.", contextWindowMessage: String = "This conversation is too long for the model. Start a new conversation to continue.", informationUnavailableMessage: String = "I couldn't find that information in the available app content.", sources: String = "Sources")

    /// English defaults suitable for evaluation and previews.
    public static let `default`: GenericChatbot.ChatbotStrings
}

/// Creates each visual slot in ``ChatbotView`` while the package retains behavior.
///
/// Implement this protocol to replace the complete presentation without taking
/// ownership of model sessions, retrieval, persistence, cancellation, or retries.
@MainActor public protocol ChatbotStyle {

    /// The header view type.
    associatedtype Header : View

    /// The message-row view type.
    associatedtype Message : View

    /// The source-card view type.
    associatedtype Source : View

    /// The empty-state view type.
    associatedtype EmptyState : View

    /// The composer view type.
    associatedtype Composer : View

    /// The availability view type.
    associatedtype Availability : View

    /// The error view type.
    associatedtype ErrorView : View

    /// How the chatbot presents its title and primary navigation actions.
    @MainActor var headerPresentation: GenericChatbot.ChatbotHeaderPresentation { get }

    /// The tint used by a system navigation header.
    @MainActor var navigationTint: Color { get }

    /// Creates the chatbot header.
    ///
    /// - Parameter configuration: Header presentation data and actions.
    /// - Returns: The style's header view.
    @ViewBuilder @MainActor func makeHeader(configuration: GenericChatbot.ChatbotHeaderConfiguration) -> Self.Header

    /// Creates a message row.
    ///
    /// - Parameter configuration: The message and its optional retry action.
    /// - Returns: The style's message view.
    @ViewBuilder @MainActor func makeMessage(configuration: GenericChatbot.ChatbotMessageConfiguration) -> Self.Message

    /// Creates a source card.
    ///
    /// - Parameter configuration: The source to present.
    /// - Returns: The style's source view.
    @ViewBuilder @MainActor func makeSource(configuration: GenericChatbot.ChatbotSourceConfiguration) -> Self.Source

    /// Creates the empty conversation state.
    ///
    /// - Parameter configuration: Empty-state text.
    /// - Returns: The style's empty-state view.
    @ViewBuilder @MainActor func makeEmptyState(configuration: GenericChatbot.ChatbotEmptyStateConfiguration) -> Self.EmptyState

    /// Creates the text composer.
    ///
    /// - Parameter configuration: Draft binding, state, and composer actions.
    /// - Returns: The style's composer view.
    @ViewBuilder @MainActor func makeComposer(configuration: GenericChatbot.ChatbotComposerConfiguration) -> Self.Composer

    /// Creates the availability or blocking-error state.
    ///
    /// - Parameter configuration: Availability state and recovery actions.
    /// - Returns: The style's availability view.
    @ViewBuilder @MainActor func makeAvailability(configuration: GenericChatbot.ChatbotAvailabilityConfiguration) -> Self.Availability

    /// Creates an inline or conversation-level error.
    ///
    /// - Parameter configuration: The normalized failure and recovery actions.
    /// - Returns: The style's error view.
    @ViewBuilder @MainActor func makeError(configuration: GenericChatbot.ChatbotErrorConfiguration) -> Self.ErrorView
}

extension ChatbotStyle {

    /// Keeps custom styles source-compatible with the original inline header.
    @MainActor public var headerPresentation: GenericChatbot.ChatbotHeaderPresentation { get }

    /// Uses the host application's accent color by default.
    @MainActor public var navigationTint: Color { get }
}

/// Semantic appearance values used by ``DefaultChatbotStyle``.
@MainActor public struct ChatbotTheme {

    /// The primary interactive color.
    @MainActor public var accentColor: Color

    /// The user-message bubble color.
    @MainActor public var userBubbleColor: Color

    /// The assistant-message bubble color.
    @MainActor public var assistantBubbleColor: Color

    /// The foreground color used on user-message bubbles.
    @MainActor public var userTextColor: Color

    /// The foreground color used on assistant-message bubbles.
    @MainActor public var assistantTextColor: Color

    /// The source-card background color.
    @MainActor public var sourceBackgroundColor: Color

    /// The font used for message content.
    @MainActor public var messageFont: Font

    /// Creates semantic appearance values for the default interface.
    ///
    /// - Parameters:
    ///   - accentColor: The primary interactive color.
    ///   - userBubbleColor: The user-message bubble color.
    ///   - assistantBubbleColor: The assistant-message bubble color.
    ///   - userTextColor: The foreground color for user messages.
    ///   - assistantTextColor: The foreground color for assistant messages.
    ///   - sourceBackgroundColor: The source-card background color.
    ///   - messageFont: The font used for message content.
    @MainActor public init(accentColor: Color = .accentColor, userBubbleColor: Color = .accentColor, assistantBubbleColor: Color = .secondary.opacity(0.14), userTextColor: Color = .white, assistantTextColor: Color = .primary, sourceBackgroundColor: Color = .secondary.opacity(0.1), messageFont: Font = .body)

    /// A system-adaptive theme suitable for previews and initial integration.
    @MainActor public static let `default`: GenericChatbot.ChatbotTheme
}
```
