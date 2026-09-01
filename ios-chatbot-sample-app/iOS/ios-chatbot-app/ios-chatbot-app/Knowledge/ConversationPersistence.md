# Conversation Persistence

Keep chats private by default or inject application-owned storage.

## Choose a lifecycle

``ChatConversationLifecycle/newConversation`` creates a fresh conversation for each chatbot view lifetime. ``ChatConversationLifecycle/resume(conversationID:)`` loads and saves a stable identifier through ``ChatHistoryStore``.

```swift
let configuration = ChatbotConfiguration(
    conversationLifecycle: .resume(conversationID: currentConversationID)
)
```

The default ``InMemoryChatHistoryStore`` doesn't survive process termination. Implement a custom actor when durable storage is appropriate:

```swift
actor AppChatHistoryStore: ChatHistoryStore {
    let database: ChatDatabase

    func conversation(id: String) async throws -> ChatConversation? {
        try await database.loadConversation(id: id)
    }

    func save(_ conversation: ChatConversation) async throws {
        try await database.save(conversation)
    }

    func deleteConversation(id: String) async throws {
        try await database.deleteConversation(id: id)
    }
}
```

## Privacy recommendations

- Encrypt sensitive durable history using application-appropriate data protection.
- Scope conversation identifiers to the signed-in user.
- Delete history when the corresponding account or feature data is deleted.
- Don't persist incomplete streaming content as a successful answer.
- Make retention and export behavior visible to the person using the application.
- Apply the host application's authentication and authorization before restoring history.
