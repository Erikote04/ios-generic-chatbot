import SwiftUI

/// Determines whether a chatbot style draws its own header or uses a system navigation bar.
public enum ChatbotHeaderPresentation: Sendable {
    /// Render the header returned by ``ChatbotStyle/makeHeader(configuration:)``
    /// directly above the chatbot content.
    case inline

    /// Present the title and actions in a native navigation toolbar.
    ///
    /// On supported Apple platforms, the system automatically gives toolbar
    /// controls Liquid Glass styling and coordinates them with scroll content.
    case navigationBar
}

/// Semantic appearance values used by ``DefaultChatbotStyle``.
@MainActor
public struct ChatbotTheme {
    /// The primary interactive color.
    public var accentColor: Color
    /// The user-message bubble color.
    public var userBubbleColor: Color
    /// The assistant-message bubble color.
    public var assistantBubbleColor: Color
    /// The foreground color used on user-message bubbles.
    public var userTextColor: Color
    /// The foreground color used on assistant-message bubbles.
    public var assistantTextColor: Color
    /// The source-card background color.
    public var sourceBackgroundColor: Color
    /// The font used for message content.
    public var messageFont: Font

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
    public init(
        accentColor: Color = .accentColor,
        userBubbleColor: Color = .accentColor,
        assistantBubbleColor: Color = .secondary.opacity(0.14),
        userTextColor: Color = .white,
        assistantTextColor: Color = .primary,
        sourceBackgroundColor: Color = .secondary.opacity(0.1),
        messageFont: Font = .body
    ) {
        self.accentColor = accentColor
        self.userBubbleColor = userBubbleColor
        self.assistantBubbleColor = assistantBubbleColor
        self.userTextColor = userTextColor
        self.assistantTextColor = assistantTextColor
        self.sourceBackgroundColor = sourceBackgroundColor
        self.messageFont = messageFont
    }

    /// A system-adaptive theme suitable for previews and initial integration.
    public static let `default` = ChatbotTheme()
}

/// Presentation data and actions for a chatbot header.
@MainActor
public struct ChatbotHeaderConfiguration {
    /// The configured assistant title.
    public let title: String
    /// Whether the chatbot is retrieving context or generating a response.
    public let activity: ChatbotActivity
    /// Starts a new conversation.
    public let startNewConversation: () -> Void
    /// Closes the presentation when the chatbot was given a close action.
    public let close: (() -> Void)?
}

/// Presentation data and actions for a message row.
@MainActor
public struct ChatbotMessageConfiguration {
    /// The message to display.
    public let message: ChatMessage
    /// Retries this message when it failed and can be retried.
    public let retry: (() -> Void)?
}

/// Presentation data for an application source card.
@MainActor
public struct ChatbotSourceConfiguration {
    /// The source represented by the card.
    public let source: ChatSource
}

/// Presentation data for the empty conversation state.
@MainActor
public struct ChatbotEmptyStateConfiguration {
    /// A concise empty-state title.
    public let title: String
    /// Guidance shown below the title.
    public let message: String
}

/// Bindings and actions for a chatbot composer.
@MainActor
public struct ChatbotComposerConfiguration {
    /// The current draft binding.
    public let text: Binding<String>
    /// Placeholder text for the editor.
    public let placeholder: String
    /// Whether the draft can be sent.
    public let isSendEnabled: Bool
    /// Whether a model request is active.
    public let activity: ChatbotActivity
    /// Submits the current draft.
    public let send: () -> Void
    /// Cancels the active response.
    public let cancel: () -> Void
}

/// Presentation data for model availability checks and blocking failures.
@MainActor
public struct ChatbotAvailabilityConfiguration {
    /// The latest availability, or `nil` while it is being checked.
    public let availability: ChatModelAvailability?
    /// A blocking failure derived from availability or session creation.
    public let failure: ChatbotFailure?
    /// Performs a recovery action exposed by the failure.
    public let perform: (ChatbotRecoveryAction) -> Void
}

/// Presentation data for an inline or conversation-level failure.
@MainActor
public struct ChatbotErrorConfiguration {
    /// The failure to display.
    public let failure: ChatbotFailure
    /// Performs one of the failure's recovery actions.
    public let perform: (ChatbotRecoveryAction) -> Void
}

/// Creates each visual slot in ``ChatbotView`` while the package retains behavior.
///
/// Implement this protocol to replace the complete presentation without taking
/// ownership of model sessions, retrieval, persistence, cancellation, or retries.
@MainActor
public protocol ChatbotStyle {
    /// The header view type.
    associatedtype Header: View
    /// The message-row view type.
    associatedtype Message: View
    /// The source-card view type.
    associatedtype Source: View
    /// The empty-state view type.
    associatedtype EmptyState: View
    /// The composer view type.
    associatedtype Composer: View
    /// The availability view type.
    associatedtype Availability: View
    /// The error view type.
    associatedtype ErrorView: View

    /// How the chatbot presents its title and primary navigation actions.
    var headerPresentation: ChatbotHeaderPresentation { get }

    /// The tint used by a system navigation header.
    var navigationTint: Color { get }

    /// Creates the chatbot header.
    ///
    /// - Parameter configuration: Header presentation data and actions.
    /// - Returns: The style's header view.
    @ViewBuilder func makeHeader(configuration: ChatbotHeaderConfiguration) -> Header

    /// Creates a message row.
    ///
    /// - Parameter configuration: The message and its optional retry action.
    /// - Returns: The style's message view.
    @ViewBuilder func makeMessage(configuration: ChatbotMessageConfiguration) -> Message

    /// Creates a source card.
    ///
    /// - Parameter configuration: The source to present.
    /// - Returns: The style's source view.
    @ViewBuilder func makeSource(configuration: ChatbotSourceConfiguration) -> Source

    /// Creates the empty conversation state.
    ///
    /// - Parameter configuration: Empty-state text.
    /// - Returns: The style's empty-state view.
    @ViewBuilder func makeEmptyState(configuration: ChatbotEmptyStateConfiguration) -> EmptyState

    /// Creates the text composer.
    ///
    /// - Parameter configuration: Draft binding, state, and composer actions.
    /// - Returns: The style's composer view.
    @ViewBuilder func makeComposer(configuration: ChatbotComposerConfiguration) -> Composer

    /// Creates the availability or blocking-error state.
    ///
    /// - Parameter configuration: Availability state and recovery actions.
    /// - Returns: The style's availability view.
    @ViewBuilder func makeAvailability(configuration: ChatbotAvailabilityConfiguration) -> Availability

    /// Creates an inline or conversation-level error.
    ///
    /// - Parameter configuration: The normalized failure and recovery actions.
    /// - Returns: The style's error view.
    @ViewBuilder func makeError(configuration: ChatbotErrorConfiguration) -> ErrorView
}

public extension ChatbotStyle {
    /// Keeps custom styles source-compatible with the original inline header.
    var headerPresentation: ChatbotHeaderPresentation { .inline }

    /// Uses the host application's accent color by default.
    var navigationTint: Color { .accentColor }
}
