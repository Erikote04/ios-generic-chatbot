import SwiftUI
import Testing
@testable import GenericChatbot

@Suite("History and presentation")
struct HistoryAndPresentationTests {
    @Test("In-memory history saves, loads, and deletes conversations")
    func inMemoryHistoryLifecycle() async {
        // Given
        let store = InMemoryChatHistoryStore()
        let conversation = ChatConversation(
            id: "stable",
            messages: [ChatMessage(role: .user, content: "Hello")]
        )

        // When
        await store.save(conversation)
        let loaded = await store.conversation(id: "stable")

        // Then
        #expect(loaded == conversation)

        // When
        await store.deleteConversation(id: "stable")

        // Then
        #expect(await store.conversation(id: "stable") == nil)
    }

    @Test("Resumed lifecycle restores persisted messages")
    @MainActor
    func restoresConversation() async {
        // Given
        let stored = ChatConversation(
            id: "stable",
            messages: [ChatMessage(role: .assistant, content: "Welcome back")]
        )
        let store = InMemoryChatHistoryStore(conversations: ["stable": stored])
        let session = ChatModelSessionSpyingStub()
        let sut = ChatbotViewModel(
            configuration: ChatbotConfiguration(
                answerPolicy: .general,
                conversationLifecycle: .resume(conversationID: "stable")
            ),
            provider: ChatModelProviderStub(session: session),
            knowledgeSource: EmptyChatKnowledgeSource(),
            historyStore: store,
            reporter: NoOpChatbotErrorReporter()
        )

        // When
        await sut.prepare()

        // Then
        #expect(sut.conversation == stored)
    }

    @Test("Default and custom-style views construct with provider abstractions")
    @MainActor
    func constructsPublicViews() {
        // Given
        let session = ChatModelSessionSpyingStub()
        let provider = ChatModelProviderStub(session: session)

        // When
        let defaultView = ChatbotView(
            configuration: ChatbotConfiguration(answerPolicy: .general),
            provider: provider
        )
        let customView = ChatbotView(
            configuration: ChatbotConfiguration(answerPolicy: .general),
            provider: provider,
            style: DefaultChatbotStyle(theme: .default)
        )
        let launcher = ChatbotLauncher { close in
            ChatbotView(
                configuration: ChatbotConfiguration(answerPolicy: .general),
                provider: provider,
                close: close
            )
        }

        // Then
        _ = defaultView
        _ = customView
        _ = launcher
    }
}
