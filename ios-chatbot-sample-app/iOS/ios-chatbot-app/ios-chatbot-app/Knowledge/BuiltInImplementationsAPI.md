# Built-in Implementations API

Public declarations for the empty knowledge source, Apple Foundation Models provider, in-memory history store, and no-op error reporter.

```swift
/// A knowledge source that intentionally returns no application context.
public struct EmptyChatKnowledgeSource : GenericChatbot.ChatKnowledgeSource {

    /// Creates an empty knowledge source.
    public init()

    /// Returns an empty collection.
    ///
    /// - Parameters:
    ///   - query: Ignored.
    ///   - limit: Ignored.
    /// - Returns: An empty array.
    public func knowledge(for query: String, limit: Int) async throws -> [GenericChatbot.ChatKnowledgeItem]
}

/// A model provider backed by Apple's on-device Foundation Models framework.
///
/// The provider doesn't require connectivity after system model assets are ready.
/// Always inspect ``availability()`` before presenting an enabled composer.
@available(iOS 26.0, macOS 26.0, *)
public struct FoundationModelsChatProvider : GenericChatbot.ChatModelProvider {

    /// Creates an Apple Foundation Models provider.
    ///
    /// - Parameters:
    ///   - model: The system model to use. Pass an adapter-backed model when your
    ///     application manages a custom Apple adapter.
    ///   - options: Generation options applied to every request.
    /// - Tip: Keep the default guardrails unless the application's use case has
    ///   been reviewed against Apple's generative-AI safety guidance.
    public init(model: SystemLanguageModel = .default, options: GenerationOptions = GenerationOptions())

    /// Reports the current system-model availability.
    ///
    /// - Returns: A provider-neutral availability value covering every current
    ///   `SystemLanguageModel.Availability.UnavailableReason`.
    public func availability() async -> GenericChatbot.ChatModelAvailability

    /// Creates a Foundation Models session and restores complete conversation history.
    ///
    /// - Parameter configuration: Trusted instructions and persisted messages.
    /// - Returns: A serial session that streams Apple model responses.
    /// - Throws: ``ChatbotError/modelUnavailable(_:)`` when Apple Intelligence
    ///   cannot currently provide the model.
    public func makeSession(configuration: GenericChatbot.ChatSessionConfiguration) async throws -> any GenericChatbot.ChatModelSession
}

/// An actor-backed history store that keeps conversations only in memory.
public actor InMemoryChatHistoryStore : GenericChatbot.ChatHistoryStore {

    /// Creates an in-memory store, optionally seeded with conversations.
    ///
    /// - Parameter conversations: Initial conversations indexed by identifier.
    public init(conversations: [String : GenericChatbot.ChatConversation] = [:])

    /// Returns the conversation matching an identifier.
    ///
    /// - Parameter id: The stable conversation identifier.
    /// - Returns: The stored conversation, or `nil` when none exists.
    public func conversation(id: String) -> GenericChatbot.ChatConversation?

    /// Stores or replaces a conversation.
    ///
    /// - Parameter conversation: The conversation to insert or replace.
    public func save(_ conversation: GenericChatbot.ChatConversation)

    /// Deletes a conversation from memory.
    ///
    /// - Parameter id: The stable conversation identifier.
    public func deleteConversation(id: String)
}

/// An error reporter that intentionally discards every event.
public struct NoOpChatbotErrorReporter : GenericChatbot.ChatbotErrorReporter {

    /// Creates a no-op reporter.
    public init()

    /// Discards the supplied failure.
    ///
    /// - Parameters:
    ///   - error: The normalized package error.
    ///   - context: Sanitized diagnostic context.
    public func report(_ error: GenericChatbot.ChatbotError, context: GenericChatbot.ChatbotDiagnosticContext) async
}
```
