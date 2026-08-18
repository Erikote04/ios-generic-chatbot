import Foundation

/// Controls whether a model may answer without retrieved application knowledge.
public enum ChatAnswerPolicy: String, Codable, Sendable {
    /// Answer only when the configured knowledge source returns relevant context.
    case groundedOnly

    /// Prefer retrieved context but allow the model to use its general capabilities.
    case general
}

/// Controls how a conversation is initialized when the chatbot appears.
public enum ChatConversationLifecycle: Codable, Equatable, Sendable {
    /// Create a new, private in-memory conversation for each view lifetime.
    case newConversation

    /// Load and save a stable conversation through the configured history store.
    case resume(conversationID: String)
}

/// Localized text used by the default chatbot style and error presenter.
///
/// Initialize this value with strings localized by the host application. Keeping
/// localization outside the package lets one chatbot support every app language.
public struct ChatbotStrings: Equatable, Sendable {
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
    public init(
        launcherAccessibilityLabel: String = "Open assistant",
        emptyTitle: String = "How can I help?",
        emptyMessage: String = "Ask a question to start a conversation.",
        composerPlaceholder: String = "Message",
        send: String = "Send",
        cancel: String = "Stop",
        retry: String = "Retry",
        close: String = "Close",
        newConversation: String = "New conversation",
        checkingAvailabilityTitle: String = "Preparing assistant",
        checkingAvailabilityMessage: String = "Checking whether the configured model is available.",
        genericErrorTitle: String = "Something went wrong",
        genericErrorMessage: String = "The assistant couldn't complete that request.",
        unsupportedDeviceMessage: String = "This device doesn't support the configured model.",
        serviceDisabledMessage: String = "The model service isn't enabled in system settings.",
        modelNotReadyMessage: String = "The model isn't ready yet. Its assets may still be downloading.",
        unsupportedLanguageMessage: String = "The model doesn't support the current language or locale.",
        offlineMessage: String = "A required network connection isn't available.",
        timeoutMessage: String = "The request took too long to complete.",
        authenticationMessage: String = "The configured service couldn't authenticate this request.",
        safetyMessage: String = "I can't help with that request.",
        refusalMessage: String = "The model chose not to answer that request.",
        contextWindowMessage: String = "This conversation is too long for the model. Start a new conversation to continue.",
        informationUnavailableMessage: String = "I couldn't find that information in the available app content.",
        sources: String = "Sources"
    ) {
        self.launcherAccessibilityLabel = launcherAccessibilityLabel
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.composerPlaceholder = composerPlaceholder
        self.send = send
        self.cancel = cancel
        self.retry = retry
        self.close = close
        self.newConversation = newConversation
        self.checkingAvailabilityTitle = checkingAvailabilityTitle
        self.checkingAvailabilityMessage = checkingAvailabilityMessage
        self.genericErrorTitle = genericErrorTitle
        self.genericErrorMessage = genericErrorMessage
        self.unsupportedDeviceMessage = unsupportedDeviceMessage
        self.serviceDisabledMessage = serviceDisabledMessage
        self.modelNotReadyMessage = modelNotReadyMessage
        self.unsupportedLanguageMessage = unsupportedLanguageMessage
        self.offlineMessage = offlineMessage
        self.timeoutMessage = timeoutMessage
        self.authenticationMessage = authenticationMessage
        self.safetyMessage = safetyMessage
        self.refusalMessage = refusalMessage
        self.contextWindowMessage = contextWindowMessage
        self.informationUnavailableMessage = informationUnavailableMessage
        self.sources = sources
    }

    /// English defaults suitable for evaluation and previews.
    public static let `default` = ChatbotStrings()
}

/// Configures the reusable chatbot behavior without assuming an application domain.
public struct ChatbotConfiguration: Equatable, Sendable {
    /// The assistant title displayed by the default style.
    public var title: String

    /// Trusted developer instructions applied to every model session.
    public var instructions: String

    /// Whether answers require retrieved knowledge.
    public var answerPolicy: ChatAnswerPolicy

    /// How conversations are initialized and restored.
    public var conversationLifecycle: ChatConversationLifecycle

    /// The maximum number of knowledge items requested for each prompt.
    public var retrievalLimit: Int

    /// Localized strings used for built-in presentation and failures.
    public var strings: ChatbotStrings

    /// Creates a chatbot configuration.
    ///
    /// - Parameters:
    ///   - title: The assistant title.
    ///   - instructions: Trusted instructions written by the integrating developer.
    ///   - answerPolicy: Whether retrieved knowledge is required.
    ///   - conversationLifecycle: Whether to create or restore a conversation.
    ///   - retrievalLimit: The maximum number of context items per prompt. Values
    ///     below zero are treated as zero.
    ///   - strings: Localized interface and error text.
    /// - Tip: Keep instructions concise because they consume model context on every
    ///   request. Put large, changing data behind ``ChatKnowledgeSource`` instead.
    public init(
        title: String = "Assistant",
        instructions: String = "Answer clearly and concisely.",
        answerPolicy: ChatAnswerPolicy = .groundedOnly,
        conversationLifecycle: ChatConversationLifecycle = .newConversation,
        retrievalLimit: Int = 5,
        strings: ChatbotStrings = .default
    ) {
        self.title = title
        self.instructions = instructions
        self.answerPolicy = answerPolicy
        self.conversationLifecycle = conversationLifecycle
        self.retrievalLimit = max(0, retrievalLimit)
        self.strings = strings
    }
}
