import Foundation

/// Values used to create an isolated model conversation.
public struct ChatSessionConfiguration: Equatable, Sendable {
    /// Trusted developer instructions for the model.
    public let instructions: String

    /// Stable history that the session can restore.
    public let conversation: ChatConversation

    /// Creates model-session configuration.
    ///
    /// - Parameters:
    ///   - instructions: Trusted instructions owned by the host application.
    ///   - conversation: Existing complete messages to restore.
    public init(instructions: String, conversation: ChatConversation) {
        self.instructions = instructions
        self.conversation = conversation
    }
}

/// A model request with retrieved application context kept separate from user text.
public struct ChatRequest: Equatable, Sendable {
    /// The person's original, unmodified message.
    public let prompt: String

    /// Relevant context returned by the application's knowledge source.
    public let knowledge: [ChatKnowledgeItem]

    /// The policy governing use of general model knowledge.
    public let answerPolicy: ChatAnswerPolicy

    /// Creates a model request.
    ///
    /// - Parameters:
    ///   - prompt: The person's question or instruction.
    ///   - knowledge: Context selected by the host application.
    ///   - answerPolicy: Whether the answer must be grounded in that context.
    public init(
        prompt: String,
        knowledge: [ChatKnowledgeItem] = [],
        answerPolicy: ChatAnswerPolicy
    ) {
        self.prompt = prompt
        self.knowledge = knowledge
        self.answerPolicy = answerPolicy
    }
}

/// An incremental event produced while a model generates an answer.
public enum ChatResponseEvent: Equatable, Sendable {
    /// Text to append to the current assistant message.
    case textDelta(String)

    /// Sources the provider associated with its answer.
    case sources([ChatSource])

    /// The provider finished the response successfully.
    case completed
}

/// Creates independent conversational sessions for a model implementation.
public protocol ChatModelProvider: Sendable {
    /// Reports whether the provider can currently create a session.
    ///
    /// - Returns: The current provider availability.
    func availability() async -> ChatModelAvailability

    /// Creates an isolated session for one chatbot conversation.
    ///
    /// - Parameter configuration: Trusted instructions and restorable history.
    /// - Returns: A session that accepts one request at a time.
    /// - Throws: ``ChatbotError/modelUnavailable(_:)`` or a provider-specific
    ///   error when session creation fails.
    func makeSession(
        configuration: ChatSessionConfiguration
    ) async throws -> any ChatModelSession
}

/// A single conversational model session.
public protocol ChatModelSession: Sendable {
    /// Streams a response to a user request.
    ///
    /// - Parameter request: The prompt, retrieved context, and answer policy.
    /// - Returns: A single-consumer stream of response events.
    /// - Throws: An error encountered before streaming begins. Errors encountered
    ///   during generation terminate the returned stream.
    /// - Important: Implementations must honor task cancellation and must not
    ///   process concurrent calls on the same session.
    func streamResponse(
        to request: ChatRequest
    ) async throws -> AsyncThrowingStream<ChatResponseEvent, Error>
}

/// Retrieves application-owned information relevant to a user prompt.
public protocol ChatKnowledgeSource: Sendable {
    /// Retrieves context for a prompt.
    ///
    /// - Parameters:
    ///   - query: The person's original message.
    ///   - limit: The maximum number of items requested by the chatbot.
    /// - Returns: Relevant items ordered from most to least useful.
    /// - Throws: A retrieval or transport error. The chatbot never silently
    ///   downgrades a failed retrieval to general generation.
    func knowledge(for query: String, limit: Int) async throws -> [ChatKnowledgeItem]
}

/// A knowledge source that intentionally returns no application context.
public struct EmptyChatKnowledgeSource: ChatKnowledgeSource {
    /// Creates an empty knowledge source.
    public init() {}

    /// Returns an empty collection.
    ///
    /// - Parameters:
    ///   - query: Ignored.
    ///   - limit: Ignored.
    /// - Returns: An empty array.
    public func knowledge(for query: String, limit: Int) async throws -> [ChatKnowledgeItem] {
        []
    }
}

/// Loads and stores conversations without prescribing a persistence technology.
public protocol ChatHistoryStore: Sendable {
    /// Loads a conversation by identifier.
    ///
    /// - Parameter id: The stable conversation identifier.
    /// - Returns: The stored conversation, or `nil` if one doesn't exist.
    /// - Throws: A persistence error.
    func conversation(id: String) async throws -> ChatConversation?

    /// Saves the latest stable conversation state.
    ///
    /// - Parameter conversation: The conversation to insert or replace.
    /// - Throws: A persistence error.
    func save(_ conversation: ChatConversation) async throws

    /// Deletes a conversation.
    ///
    /// - Parameter id: The stable conversation identifier.
    /// - Throws: A persistence error.
    func deleteConversation(id: String) async throws
}

/// An actor-backed history store that keeps conversations only in memory.
public actor InMemoryChatHistoryStore: ChatHistoryStore {
    private var conversations: [String: ChatConversation]

    /// Creates an in-memory store, optionally seeded with conversations.
    ///
    /// - Parameter conversations: Initial conversations indexed by identifier.
    public init(conversations: [String: ChatConversation] = [:]) {
        self.conversations = conversations
    }

    /// Returns the conversation matching an identifier.
    ///
    /// - Parameter id: The stable conversation identifier.
    /// - Returns: The stored conversation, or `nil` when none exists.
    public func conversation(id: String) -> ChatConversation? {
        conversations[id]
    }

    /// Stores or replaces a conversation.
    ///
    /// - Parameter conversation: The conversation to insert or replace.
    public func save(_ conversation: ChatConversation) {
        conversations[conversation.id] = conversation
    }

    /// Deletes a conversation from memory.
    ///
    /// - Parameter id: The stable conversation identifier.
    public func deleteConversation(id: String) {
        conversations[id] = nil
    }
}

/// Context attached to a sanitized diagnostic event.
public struct ChatbotDiagnosticContext: Equatable, Sendable {
    /// The operation that failed, such as `model.response` or `history.save`.
    public let operation: String

    /// A provider-generated description intended for developers, not end users.
    public let details: String?

    /// Creates diagnostic context.
    ///
    /// - Parameters:
    ///   - operation: A stable operation name.
    ///   - details: Optional diagnostic detail that contains no conversation text.
    public init(operation: String, details: String? = nil) {
        self.operation = operation
        self.details = details
    }
}

/// Receives normalized failures without prescribing analytics or logging.
public protocol ChatbotErrorReporter: Sendable {
    /// Reports a sanitized operational failure.
    ///
    /// - Parameters:
    ///   - error: The normalized package error.
    ///   - context: Non-user-facing operation metadata.
    func report(_ error: ChatbotError, context: ChatbotDiagnosticContext) async
}

/// An error reporter that intentionally discards every event.
public struct NoOpChatbotErrorReporter: ChatbotErrorReporter {
    /// Creates a no-op reporter.
    public init() {}

    /// Discards the supplied failure.
    ///
    /// - Parameters:
    ///   - error: The normalized package error.
    ///   - context: Sanitized diagnostic context.
    public func report(_ error: ChatbotError, context: ChatbotDiagnosticContext) async {}
}
