# Core Knowledge and Conversation API

Public declarations for answer policies, conversations, history, application knowledge, messages, and message state.

```swift
import Foundation
import FoundationModels
import NaturalLanguage
import Observation
import SwiftUI

/// Controls whether a model may answer without retrieved application knowledge.
public enum ChatAnswerPolicy : String, Codable, Sendable {

    /// Answer only when the configured knowledge source returns relevant context.
    case groundedOnly

    /// Prefer retrieved context but allow the model to use its general capabilities.
    case general
}

/// A persistable conversation and its ordered messages.
public struct ChatConversation : Identifiable, Codable, Equatable, Sendable {

    /// The identifier used by an optional ``ChatHistoryStore``.
    public let id: String

    /// Messages in display order.
    public var messages: [GenericChatbot.ChatMessage]

    /// The last time the conversation changed.
    public var updatedAt: Date

    /// Creates a conversation.
    ///
    /// - Parameters:
    ///   - id: A stable identifier, commonly tied to a user or app feature.
    ///   - messages: Previously persisted messages in display order.
    ///   - updatedAt: The last modification time.
    public init(id: String = UUID().uuidString, messages: [GenericChatbot.ChatMessage] = [], updatedAt: Date = Date())
}

/// Controls how a conversation is initialized when the chatbot appears.
public enum ChatConversationLifecycle : Codable, Equatable, Sendable {

    /// Create a new, private in-memory conversation for each view lifetime.
    case newConversation

    /// Load and save a stable conversation through the configured history store.
    case resume(conversationID: String)
}

/// Loads and stores conversations without prescribing a persistence technology.
public protocol ChatHistoryStore : Sendable {

    /// Loads a conversation by identifier.
    ///
    /// - Parameter id: The stable conversation identifier.
    /// - Returns: The stored conversation, or `nil` if one doesn't exist.
    /// - Throws: A persistence error.
    func conversation(id: String) async throws -> GenericChatbot.ChatConversation?

    /// Saves the latest stable conversation state.
    ///
    /// - Parameter conversation: The conversation to insert or replace.
    /// - Throws: A persistence error.
    func save(_ conversation: GenericChatbot.ChatConversation) async throws

    /// Deletes a conversation.
    ///
    /// - Parameter id: The stable conversation identifier.
    /// - Throws: A persistence error.
    func deleteConversation(id: String) async throws
}

/// A piece of application-owned information retrieved for a prompt.
public struct ChatKnowledgeItem : Identifiable, Codable, Equatable, Sendable {

    /// A stable identifier for the knowledge item.
    public let id: String

    /// A concise title suitable for a source card.
    public let title: String

    /// The trusted context supplied to the model.
    public let content: String

    /// An optional location where the person can inspect the source.
    public let url: URL?

    /// Optional values used by custom source-card styles.
    public let metadata: [String : String]

    /// Creates an application knowledge item.
    ///
    /// - Parameters:
    ///   - id: A stable identifier.
    ///   - title: A human-readable title.
    ///   - content: The context supplied to the model.
    ///   - url: An optional source destination.
    ///   - metadata: Additional domain-specific display values.
    public init(id: String, title: String, content: String, url: URL? = nil, metadata: [String : String] = [:])

    /// A display source derived from this knowledge item.
    public var source: GenericChatbot.ChatSource { get }
}

/// Retrieves application-owned information relevant to a user prompt.
public protocol ChatKnowledgeSource : Sendable {

    /// Retrieves context for a prompt.
    ///
    /// - Parameters:
    ///   - query: The person's original message.
    ///   - limit: The maximum number of items requested by the chatbot.
    /// - Returns: Relevant items ordered from most to least useful.
    /// - Throws: A retrieval or transport error. The chatbot never silently
    ///   downgrades a failed retrieval to general generation.
    func knowledge(for query: String, limit: Int) async throws -> [GenericChatbot.ChatKnowledgeItem]
}

/// A single user or assistant message.
public struct ChatMessage : Identifiable, Codable, Equatable, Sendable {

    /// The stable message identifier.
    public let id: UUID

    /// The message author.
    public let role: GenericChatbot.ChatRole

    /// The current textual content.
    public var content: String

    /// The time at which the message was created.
    public let createdAt: Date

    /// The message's current delivery state.
    public var status: GenericChatbot.ChatMessageStatus

    /// Sources supplied while producing an assistant response.
    public var sources: [GenericChatbot.ChatSource]

    /// A normalized failure associated with this message, when present.
    public var failure: GenericChatbot.ChatbotError?

    /// Creates a conversation message.
    ///
    /// - Parameters:
    ///   - id: The message identifier. Preserve it when persisting history.
    ///   - role: The message author.
    ///   - content: The message text.
    ///   - createdAt: The creation time.
    ///   - status: The delivery state.
    ///   - sources: Context sources associated with an assistant answer.
    ///   - failure: A normalized failure when generation didn't complete.
    public init(id: UUID = UUID(), role: GenericChatbot.ChatRole, content: String, createdAt: Date = Date(), status: GenericChatbot.ChatMessageStatus = .complete, sources: [GenericChatbot.ChatSource] = [], failure: GenericChatbot.ChatbotError? = nil)
}

/// The delivery state of a message.
public enum ChatMessageStatus : String, Codable, Sendable {

    /// The message has been accepted but processing has not finished.
    case pending

    /// The assistant is currently streaming this message.
    case streaming

    /// The message completed successfully.
    case complete

    /// The message could not be completed.
    case failed

    /// Generation was cancelled by the person or host application.
    case cancelled
}
```
