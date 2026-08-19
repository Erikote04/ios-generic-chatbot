import Foundation
import Observation

/// Work currently performed by the chatbot.
public enum ChatbotActivity: String, Equatable, Sendable {
    /// No request is active.
    case idle

    /// The chatbot is retrieving application knowledge.
    case retrieving

    /// The model is streaming an answer.
    case responding
}

@MainActor
@Observable
final class ChatbotViewModel {
    private(set) var conversation: ChatConversation
    var draft = ""
    private(set) var availability: ChatModelAvailability?
    private(set) var activity: ChatbotActivity = .idle
    private(set) var blockingFailure: ChatbotFailure?
    private(set) var conversationFailure: ChatbotFailure?

    let configuration: ChatbotConfiguration

    private let provider: any ChatModelProvider
    private let knowledgeSource: any ChatKnowledgeSource
    private let historyStore: any ChatHistoryStore
    private let reporter: any ChatbotErrorReporter
    private var session: (any ChatModelSession)?
    private var responseTask: Task<Void, Never>?
    private var availabilityTask: Task<Void, Never>?
    private var hasPrepared = false

    init(
        configuration: ChatbotConfiguration,
        provider: any ChatModelProvider,
        knowledgeSource: any ChatKnowledgeSource,
        historyStore: any ChatHistoryStore,
        reporter: any ChatbotErrorReporter
    ) {
        self.configuration = configuration
        self.provider = provider
        self.knowledgeSource = knowledgeSource
        self.historyStore = historyStore
        self.reporter = reporter

        switch configuration.conversationLifecycle {
        case .newConversation:
            conversation = ChatConversation()
        case .resume(let conversationID):
            conversation = ChatConversation(id: conversationID)
        }
    }

    var isSendEnabled: Bool {
        guard case .available = availability else { return false }
        return activity == .idle && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func prepare() async {
        guard !hasPrepared else { return }
        hasPrepared = true
        await checkAvailabilityAndCreateSession(loadHistory: true)
    }

    func retryAvailability() {
        availabilityTask?.cancel()
        availabilityTask = Task { [weak self] in
            await self?.checkAvailabilityAndCreateSession(loadHistory: false)
        }
    }

    func send() {
        guard isSendEnabled else { return }
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        draft = ""
        responseTask = Task { [weak self] in
            await self?.sendNewPrompt(prompt)
        }
    }

    func cancelResponse() {
        responseTask?.cancel()
        responseTask = nil
    }

    func waitForCurrentResponse() async {
        let task = responseTask
        await task?.value
    }

    func retry(messageID: UUID) {
        guard activity == .idle,
              let assistantIndex = conversation.messages.firstIndex(where: { $0.id == messageID }),
              conversation.messages[assistantIndex].role == .assistant,
              conversation.messages[assistantIndex].status == .failed,
              assistantIndex > conversation.messages.startIndex
        else { return }

        let userIndex = conversation.messages.index(before: assistantIndex)
        let userMessage = conversation.messages[userIndex]
        guard userMessage.role == .user else { return }

        let restoredMessages = Array(conversation.messages[..<userIndex])
        conversation.messages.remove(at: assistantIndex)
        session = nil
        conversationFailure = nil

        responseTask = Task { [weak self] in
            guard let self else { return }
            let history = ChatConversation(
                id: self.conversation.id,
                messages: restoredMessages,
                updatedAt: self.conversation.updatedAt
            )
            await self.generateResponse(
                to: userMessage.content,
                restoring: history
            )
        }
    }

    func startNewConversation() {
        cancelResponse()
        session = nil
        blockingFailure = nil
        conversationFailure = nil
        activity = .idle

        let previousID = conversation.id
        switch configuration.conversationLifecycle {
        case .newConversation:
            conversation = ChatConversation()
        case .resume(let conversationID):
            conversation = ChatConversation(id: conversationID)
        }

        responseTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await self.historyStore.deleteConversation(id: previousID)
                try await self.historyStore.save(self.conversation)
                self.session = try await self.makeSession(restoring: self.conversation)
            } catch is CancellationError {
                return
            } catch {
                await self.handlePersistenceError(error, operation: "history.reset")
            }
        }
    }

    func perform(_ action: ChatbotRecoveryAction, messageID: UUID? = nil) {
        switch action {
        case .retryAvailability:
            retryAvailability()
        case .retryRetrieval, .retryResponse:
            if let messageID {
                retry(messageID: messageID)
            }
        case .cancel:
            cancelResponse()
        case .startNewConversation:
            startNewConversation()
        case .dismiss:
            break
        }
    }

    private func checkAvailabilityAndCreateSession(loadHistory: Bool) async {
        blockingFailure = nil
        availability = nil

        let currentAvailability = await provider.availability()
        availability = currentAvailability

        guard case .available = currentAvailability else {
            guard case .unavailable(let reason) = currentAvailability else { return }
            blockingFailure = ChatbotFailureFactory.make(
                .modelUnavailable(reason),
                strings: configuration.strings,
                scope: .blocking
            )
            return
        }

        if loadHistory,
           case .resume(let conversationID) = configuration.conversationLifecycle {
            do {
                if let stored = try await historyStore.conversation(id: conversationID) {
                    conversation = stored
                }
            } catch {
                await handlePersistenceError(error, operation: "history.load")
            }
        }

        do {
            session = try await makeSession(restoring: conversation)
        } catch is CancellationError {
            return
        } catch {
            await handleBlockingError(error, operation: "model.session")
        }
    }

    private func sendNewPrompt(_ prompt: String) async {
        let historyBeforePrompt = conversation
        conversationFailure = nil
        let userMessage = ChatMessage(role: .user, content: prompt)
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()
        await generateResponse(to: prompt, restoring: historyBeforePrompt)
    }

    private func generateResponse(
        to prompt: String,
        restoring history: ChatConversation
    ) async {
        do {
            activity = .retrieving
            let knowledge = try await knowledgeSource.knowledge(
                for: prompt,
                limit: configuration.retrievalLimit
            )
            try Task.checkCancellation()

            if configuration.answerPolicy == .groundedOnly, knowledge.isEmpty {
                conversation.messages.append(
                    ChatMessage(
                        role: .assistant,
                        content: configuration.strings.informationUnavailableMessage
                    )
                )
                activity = .idle
                await persistConversation()
                return
            }

            if session == nil {
                session = try await makeSession(restoring: history)
            }
            guard let session else {
                throw ChatbotError.providerFailure
            }

            let assistantID = UUID()
            conversation.messages.append(
                ChatMessage(
                    id: assistantID,
                    role: .assistant,
                    content: "",
                    status: .streaming,
                    sources: knowledge.map(\.source)
                )
            )
            activity = .responding

            let stream = try await session.streamResponse(
                to: ChatRequest(
                    prompt: prompt,
                    knowledge: knowledge,
                    answerPolicy: configuration.answerPolicy
                )
            )

            for try await event in stream {
                try Task.checkCancellation()
                apply(event, to: assistantID)
            }

            try Task.checkCancellation()
            completeMessage(id: assistantID)
            activity = .idle
            responseTask = nil
            await persistConversation()
        } catch is CancellationError {
            markStreamingMessageCancelled()
            activity = .idle
            responseTask = nil
            await persistConversation()
        } catch {
            let fallback: ChatbotError = activity == .retrieving ? .retrievalFailed : .providerFailure
            let mapped = ChatbotErrorMapper.map(error, fallback: fallback)
            handleResponseError(mapped)
            activity = .idle
            responseTask = nil
            await reporter.report(
                mapped,
                context: ChatbotDiagnosticContext(
                    operation: fallback == .retrievalFailed ? "knowledge.retrieve" : "model.response",
                    details: String(describing: type(of: error))
                )
            )
            await persistConversation()
        }
    }

    private func makeSession(restoring history: ChatConversation) async throws -> any ChatModelSession {
        try await provider.makeSession(
            configuration: ChatSessionConfiguration(
                instructions: configuration.instructions,
                conversation: history,
                responseLanguage: configuration.responseLanguage
            )
        )
    }

    private func apply(_ event: ChatResponseEvent, to messageID: UUID) {
        guard let index = conversation.messages.firstIndex(where: { $0.id == messageID }) else {
            return
        }

        switch event {
        case .textDelta(let text):
            conversation.messages[index].content += text
        case .sources(let sources):
            let existing = Set(conversation.messages[index].sources.map(\.id))
            conversation.messages[index].sources.append(
                contentsOf: sources.filter { !existing.contains($0.id) }
            )
        case .completed:
            conversation.messages[index].status = .complete
        }
        conversation.updatedAt = Date()
    }

    private func completeMessage(id: UUID) {
        guard let index = conversation.messages.firstIndex(where: { $0.id == id }) else { return }
        conversation.messages[index].status = .complete
        conversation.messages[index].failure = nil
        conversation.updatedAt = Date()
    }

    private func markStreamingMessageCancelled() {
        guard let index = conversation.messages.lastIndex(where: { $0.status == .streaming }) else {
            return
        }
        conversation.messages[index].status = .cancelled
        conversation.updatedAt = Date()
    }

    private func handleResponseError(_ error: ChatbotError) {
        if let index = conversation.messages.lastIndex(where: { $0.status == .streaming }) {
            switch error {
            case .guardrailViolation:
                conversation.messages[index].content = configuration.strings.safetyMessage
                conversation.messages[index].status = .complete
            case .refusal:
                conversation.messages[index].content = configuration.strings.refusalMessage
                conversation.messages[index].status = .complete
            default:
                conversation.messages[index].status = .failed
            }
            conversation.messages[index].failure = error
        } else {
            conversation.messages.append(
                ChatMessage(
                    role: .assistant,
                    content: "",
                    status: .failed,
                    failure: error
                )
            )
        }

        if error == .contextWindowExceeded {
            conversationFailure = ChatbotFailureFactory.make(
                error,
                strings: configuration.strings,
                scope: .conversation
            )
        }
        conversation.updatedAt = Date()
    }

    private func handleBlockingError(_ error: any Error, operation: String) async {
        let mapped = ChatbotErrorMapper.map(error, fallback: .providerFailure)
        blockingFailure = ChatbotFailureFactory.make(
            mapped,
            strings: configuration.strings,
            scope: .blocking
        )
        await reporter.report(
            mapped,
            context: ChatbotDiagnosticContext(
                operation: operation,
                details: String(describing: type(of: error))
            )
        )
    }

    private func handlePersistenceError(_ error: any Error, operation: String) async {
        let mapped = ChatbotError.persistenceFailed
        conversationFailure = ChatbotFailureFactory.make(
            mapped,
            strings: configuration.strings,
            scope: .conversation
        )
        await reporter.report(
            mapped,
            context: ChatbotDiagnosticContext(
                operation: operation,
                details: String(describing: type(of: error))
            )
        )
    }

    private func persistConversation() async {
        do {
            try await historyStore.save(conversation)
        } catch {
            await handlePersistenceError(error, operation: "history.save")
        }
    }

    isolated deinit {
        responseTask?.cancel()
        availabilityTask?.cancel()
    }
}

enum ChatbotFailureFactory {
    static func make(
        _ error: ChatbotError,
        strings: ChatbotStrings,
        scope requestedScope: ChatbotFailureScope? = nil
    ) -> ChatbotFailure {
        let presentation = presentation(for: error, strings: strings)
        return ChatbotFailure(
            error: error,
            scope: requestedScope ?? presentation.scope,
            title: presentation.title,
            message: presentation.message,
            recoveryActions: presentation.actions
        )
    }

    private static func presentation(
        for error: ChatbotError,
        strings: ChatbotStrings
    ) -> (
        scope: ChatbotFailureScope,
        title: String,
        message: String,
        actions: [ChatbotRecoveryAction]
    ) {
        switch error {
        case .modelUnavailable(.deviceNotEligible):
            return (.blocking, strings.genericErrorTitle, strings.unsupportedDeviceMessage, [.dismiss])
        case .modelUnavailable(.serviceNotEnabled):
            return (.blocking, strings.genericErrorTitle, strings.serviceDisabledMessage, [.retryAvailability, .dismiss])
        case .modelUnavailable(.modelNotReady), .assetsUnavailable:
            return (.blocking, strings.checkingAvailabilityTitle, strings.modelNotReadyMessage, [.retryAvailability, .dismiss])
        case .modelUnavailable(.networkUnavailable), .networkUnavailable, .connectionLost:
            return (.conversation, strings.genericErrorTitle, strings.offlineMessage, [.retryResponse])
        case .modelUnavailable(.authenticationRequired), .authenticationFailed:
            return (.blocking, strings.genericErrorTitle, strings.authenticationMessage, [.retryAvailability, .dismiss])
        case .modelUnavailable(.unknown):
            return (.blocking, strings.genericErrorTitle, strings.genericErrorMessage, [.retryAvailability, .dismiss])
        case .contextWindowExceeded:
            return (.conversation, strings.genericErrorTitle, strings.contextWindowMessage, [.startNewConversation])
        case .guardrailViolation:
            return (.message, strings.genericErrorTitle, strings.safetyMessage, [])
        case .unsupportedLanguageOrLocale:
            return (.blocking, strings.genericErrorTitle, strings.unsupportedLanguageMessage, [.dismiss])
        case .timedOut:
            return (.message, strings.genericErrorTitle, strings.timeoutMessage, [.retryResponse])
        case .retrievalFailed, .toolCallFailed:
            return (.message, strings.genericErrorTitle, strings.genericErrorMessage, [.retryRetrieval])
        case .unsupportedGuide:
            return (.blocking, strings.genericErrorTitle, strings.genericErrorMessage, [.dismiss])
        case .refusal:
            return (.message, strings.genericErrorTitle, strings.refusalMessage, [])
        case .persistenceFailed:
            return (.conversation, strings.genericErrorTitle, strings.genericErrorMessage, [])
        case .decodingFailure, .rateLimited, .concurrentRequest, .hostResolutionFailed,
             .serverUnavailable, .invalidResponse, .providerFailure, .unknown:
            return (.message, strings.genericErrorTitle, strings.genericErrorMessage, [.retryResponse])
        }
    }
}
