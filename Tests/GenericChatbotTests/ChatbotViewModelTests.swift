import Foundation
import Testing
@testable import GenericChatbot

@Suite("Chatbot view model")
@MainActor
struct ChatbotViewModelTests {
    @Test("Streams a general response and attaches retrieved sources")
    func streamsResponse() async {
        // Given
        let session = ChatModelSessionSpyingStub(
            events: [.textDelta("Hello"), .textDelta(" world"), .completed]
        )
        let knowledge = ChatKnowledgeItem(
            id: "guide",
            title: "Application guide",
            content: "Relevant content"
        )
        let sut = makeViewModel(
            session: session,
            knowledgeSource: ChatKnowledgeSourceStub(items: [knowledge]),
            answerPolicy: .general
        )
        await sut.prepare()

        // When
        sut.draft = "How does this work?"
        sut.send()
        await sut.waitForCurrentResponse()

        // Then
        #expect(sut.conversation.messages.count == 2)
        #expect(sut.conversation.messages.last?.content == "Hello world")
        #expect(sut.conversation.messages.last?.status == .complete)
        #expect(sut.conversation.messages.last?.sources.map(\.id) == ["guide"])
        #expect(await session.requests.count == 1)
    }

    @Test("Grounded mode doesn't call the model without knowledge")
    func groundedModeRequiresKnowledge() async {
        // Given
        let session = ChatModelSessionSpyingStub(events: [.textDelta("Unexpected")])
        let sut = makeViewModel(
            session: session,
            knowledgeSource: ChatKnowledgeSourceStub(),
            answerPolicy: .groundedOnly
        )
        await sut.prepare()

        // When
        sut.draft = "Unknown question"
        sut.send()
        await sut.waitForCurrentResponse()

        // Then
        #expect(await session.requests.isEmpty)
        #expect(
            sut.conversation.messages.last?.content
                == sut.configuration.strings.informationUnavailableMessage
        )
    }

    @Test("Retrieval errors become retryable message failures")
    func retrievalFailure() async {
        // Given
        let session = ChatModelSessionSpyingStub()
        let sut = makeViewModel(
            session: session,
            knowledgeSource: ChatKnowledgeSourceStub(error: .networkUnavailable),
            answerPolicy: .general
        )
        await sut.prepare()

        // When
        sut.draft = "Question"
        sut.send()
        await sut.waitForCurrentResponse()

        // Then
        #expect(sut.activity == .idle)
        #expect(sut.conversation.messages.last?.status == .failed)
        #expect(sut.conversation.messages.last?.failure == .networkUnavailable)
        #expect(await session.requests.isEmpty)
    }

    @Test("Unavailable models create a blocking state")
    func unavailableModel() async {
        // Given
        let session = ChatModelSessionSpyingStub()
        let provider = ChatModelProviderStub(
            currentAvailability: .unavailable(.deviceNotEligible),
            session: session
        )
        let sut = ChatbotViewModel(
            configuration: ChatbotConfiguration(answerPolicy: .general),
            provider: provider,
            knowledgeSource: EmptyChatKnowledgeSource(),
            historyStore: InMemoryChatHistoryStore(),
            reporter: NoOpChatbotErrorReporter()
        )

        // When
        await sut.prepare()

        // Then
        #expect(sut.availability == .unavailable(.deviceNotEligible))
        #expect(sut.blockingFailure?.scope == .blocking)
        #expect(sut.isSendEnabled == false)
    }

    @Test("Forwards response language behavior when creating a model session")
    func forwardsResponseLanguage() async {
        // Given
        let locale = Locale(identifier: "es_ES")
        let recorder = ChatSessionConfigurationRecorder()
        let provider = ChatModelProviderStub(
            session: ChatModelSessionSpyingStub(),
            configurationRecorder: recorder
        )
        let sut = ChatbotViewModel(
            configuration: ChatbotConfiguration(
                answerPolicy: .general,
                responseLanguage: .fixed(locale)
            ),
            provider: provider,
            knowledgeSource: EmptyChatKnowledgeSource(),
            historyStore: InMemoryChatHistoryStore(),
            reporter: NoOpChatbotErrorReporter()
        )

        // When
        await sut.prepare()

        // Then
        let configurations = await recorder.configurations
        #expect(configurations.count == 1)
        #expect(configurations.first?.responseLanguage == .fixed(locale))
    }

    @Test("Cancelling a stream leaves a cancelled assistant message")
    func cancelsStreamingResponse() async {
        // Given
        let session = ControlledChatModelSession()
        let sut = makeViewModel(
            session: session,
            knowledgeSource: ChatKnowledgeSourceStub(),
            answerPolicy: .general
        )
        await sut.prepare()
        sut.draft = "Long answer"
        sut.send()
        await session.waitUntilStarted()
        await session.yield(.textDelta("Partial"))
        let completion = Task { await sut.waitForCurrentResponse() }

        // When
        sut.cancelResponse()
        await session.finish()
        await completion.value

        // Then
        #expect(sut.activity == .idle)
        #expect(sut.conversation.messages.last?.status == .cancelled)
    }

    private func makeViewModel(
        session: any ChatModelSession,
        knowledgeSource: any ChatKnowledgeSource,
        answerPolicy: ChatAnswerPolicy
    ) -> ChatbotViewModel {
        ChatbotViewModel(
            configuration: ChatbotConfiguration(answerPolicy: answerPolicy),
            provider: ChatModelProviderStub(session: session),
            knowledgeSource: knowledgeSource,
            historyStore: InMemoryChatHistoryStore(),
            reporter: NoOpChatbotErrorReporter()
        )
    }
}
