# Configuration and Errors API

Public declarations for chatbot activity, configuration, diagnostics, normalized errors, reporting, failures, and failure scope.

```swift
/// Work currently performed by the chatbot.
public enum ChatbotActivity : String, Equatable, Sendable {

    /// No request is active.
    case idle

    /// The chatbot is retrieving application knowledge.
    case retrieving

    /// The model is streaming an answer.
    case responding
}

/// Presentation data for model availability checks and blocking failures.
@MainActor public struct ChatbotAvailabilityConfiguration {

    /// The latest availability, or `nil` while it is being checked.
    @MainActor public let availability: GenericChatbot.ChatModelAvailability?

    /// A blocking failure derived from availability or session creation.
    @MainActor public let failure: GenericChatbot.ChatbotFailure?

    /// Performs a recovery action exposed by the failure.
    @MainActor public let perform: (GenericChatbot.ChatbotRecoveryAction) -> Void
}

/// Bindings and actions for a chatbot composer.
@MainActor public struct ChatbotComposerConfiguration {

    /// The current draft binding.
    @MainActor public let text: Binding<String>

    /// Placeholder text for the editor.
    @MainActor public let placeholder: String

    /// Whether the draft can be sent.
    @MainActor public let isSendEnabled: Bool

    /// Whether a model request is active.
    @MainActor public let activity: GenericChatbot.ChatbotActivity

    /// Submits the current draft.
    @MainActor public let send: () -> Void

    /// Cancels the active response.
    @MainActor public let cancel: () -> Void
}

/// Configures the reusable chatbot behavior without assuming an application domain.
public struct ChatbotConfiguration : Equatable, Sendable {

    /// The assistant title displayed by the default style.
    public var title: String

    /// Trusted developer instructions applied to every model session.
    public var instructions: String

    /// Whether answers require retrieved knowledge.
    public var answerPolicy: GenericChatbot.ChatAnswerPolicy

    /// How conversations are initialized and restored.
    public var conversationLifecycle: GenericChatbot.ChatConversationLifecycle

    /// The maximum number of knowledge items requested for each prompt.
    public var retrievalLimit: Int

    /// The language and regional conventions used for model responses.
    public var responseLanguage: GenericChatbot.ChatbotResponseLanguage

    /// Localized strings used for built-in presentation and failures.
    public var strings: GenericChatbot.ChatbotStrings

    /// Creates a chatbot configuration.
    ///
    /// - Parameters:
    ///   - title: The assistant title.
    ///   - instructions: Trusted instructions written by the integrating developer.
    ///   - answerPolicy: Whether retrieved knowledge is required.
    ///   - conversationLifecycle: Whether to create or restore a conversation.
    ///   - retrievalLimit: The maximum number of context items per prompt. Values
    ///     below zero are treated as zero.
    ///   - responseLanguage: How the model selects its response language. The default
    ///     follows the person's latest request and uses the app locale as a fallback.
    ///   - strings: Localized interface and error text.
    /// - Tip: Keep instructions concise because they consume model context on every
    ///   request. Put large, changing data behind ``ChatKnowledgeSource`` instead.
    public init(title: String = "Assistant", instructions: String = "Answer clearly and concisely.", answerPolicy: GenericChatbot.ChatAnswerPolicy = .groundedOnly, conversationLifecycle: GenericChatbot.ChatConversationLifecycle = .newConversation, retrievalLimit: Int = 5, responseLanguage: GenericChatbot.ChatbotResponseLanguage = .matchingUserInput(), strings: GenericChatbot.ChatbotStrings = .default)
}

/// Context attached to a sanitized diagnostic event.
public struct ChatbotDiagnosticContext : Equatable, Sendable {

    /// The operation that failed, such as `model.response` or `history.save`.
    public let operation: String

    /// A provider-generated description intended for developers, not end users.
    public let details: String?

    /// Creates diagnostic context.
    ///
    /// - Parameters:
    ///   - operation: A stable operation name.
    ///   - details: Optional diagnostic detail that contains no conversation text.
    public init(operation: String, details: String? = nil)
}

/// Presentation data for the empty conversation state.
@MainActor public struct ChatbotEmptyStateConfiguration {

    /// A concise empty-state title.
    @MainActor public let title: String

    /// Guidance shown below the title.
    @MainActor public let message: String
}

/// A normalized chatbot failure independent of a specific model or transport.
public enum ChatbotError : Error, Codable, Equatable, Sendable {

    /// The model isn't available for the associated reason.
    case modelUnavailable(GenericChatbot.ChatModelUnavailableReason)

    /// The active session exceeded its context window.
    case contextWindowExceeded

    /// Required model assets became unavailable.
    case assetsUnavailable

    /// Model safety guardrails rejected input or output.
    case guardrailViolation

    /// A schema guide isn't supported by the selected model.
    case unsupportedGuide

    /// The model doesn't support the requested language or locale.
    case unsupportedLanguageOrLocale

    /// The provider couldn't decode a model response.
    case decodingFailure

    /// The provider is temporarily rate limited.
    case rateLimited

    /// More than one request reached a session that only permits one.
    case concurrentRequest

    /// The model declined to answer the request.
    case refusal

    /// A model-invoked tool failed.
    case toolCallFailed

    /// A required network connection isn't available.
    case networkUnavailable

    /// An active network connection was lost.
    case connectionLost

    /// A remote operation timed out.
    case timedOut

    /// A remote host couldn't be resolved.
    case hostResolutionFailed

    /// A remote service couldn't accept the request.
    case serverUnavailable

    /// A remote service rejected the supplied credentials.
    case authenticationFailed

    /// A remote service returned an invalid response.
    case invalidResponse

    /// The configured knowledge source failed.
    case retrievalFailed

    /// The configured history store failed.
    case persistenceFailed

    /// A provider failed without a more specific classification.
    case providerFailure

    /// An operation failed for an unrecognized reason.
    case unknown
}

extension ChatbotError : LocalizedError {

    /// A developer-oriented description suitable for diagnostics.
    public var errorDescription: String? { get }
}

/// Presentation data for an inline or conversation-level failure.
@MainActor public struct ChatbotErrorConfiguration {

    /// The failure to display.
    @MainActor public let failure: GenericChatbot.ChatbotFailure

    /// Performs one of the failure's recovery actions.
    @MainActor public let perform: (GenericChatbot.ChatbotRecoveryAction) -> Void
}

/// Receives normalized failures without prescribing analytics or logging.
public protocol ChatbotErrorReporter : Sendable {

    /// Reports a sanitized operational failure.
    ///
    /// - Parameters:
    ///   - error: The normalized package error.
    ///   - context: Non-user-facing operation metadata.
    func report(_ error: GenericChatbot.ChatbotError, context: GenericChatbot.ChatbotDiagnosticContext) async
}

/// A user-presentable failure and its supported recovery actions.
public struct ChatbotFailure : Identifiable, Equatable, Sendable {

    /// A stable identity for SwiftUI presentation.
    public let id: UUID

    /// The normalized underlying failure.
    public let error: GenericChatbot.ChatbotError

    /// The recommended visual scope.
    public let scope: GenericChatbot.ChatbotFailureScope

    /// A short localized title.
    public let title: String

    /// A localized explanation that doesn't expose internal diagnostics.
    public let message: String

    /// Recovery actions valid for this failure.
    public let recoveryActions: [GenericChatbot.ChatbotRecoveryAction]

    /// Creates a user-presentable failure.
    ///
    /// - Parameters:
    ///   - id: The presentation identity.
    ///   - error: The normalized failure.
    ///   - scope: Where the failure should appear.
    ///   - title: A concise localized title.
    ///   - message: A safe localized explanation.
    ///   - recoveryActions: Actions the interface may offer.
    public init(id: UUID = UUID(), error: GenericChatbot.ChatbotError, scope: GenericChatbot.ChatbotFailureScope, title: String, message: String, recoveryActions: [GenericChatbot.ChatbotRecoveryAction])
}

/// The visual scope of a chatbot failure.
public enum ChatbotFailureScope : String, Codable, Sendable {

    /// The failure replaces the chat content until it is resolved.
    case blocking

    /// The failure appears above or below the conversation.
    case conversation

    /// The failure is attached to an individual message.
    case message
}
```
