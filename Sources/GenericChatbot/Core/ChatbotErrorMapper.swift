import Foundation

enum ChatbotErrorMapper {
    static func map(_ error: any Error, fallback: ChatbotError = .unknown) -> ChatbotError {
        if let chatbotError = error as? ChatbotError {
            return chatbotError
        }

        if error is CancellationError {
            return .unknown
        }

        guard let urlError = error as? URLError else {
            return fallback
        }

        switch urlError.code {
        case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff:
            return .networkUnavailable
        case .networkConnectionLost:
            return .connectionLost
        case .timedOut:
            return .timedOut
        case .cannotFindHost, .dnsLookupFailed:
            return .hostResolutionFailed
        case .cannotConnectToHost, .resourceUnavailable, .backgroundSessionWasDisconnected:
            return .serverUnavailable
        case .userAuthenticationRequired, .userCancelledAuthentication:
            return .authenticationFailed
        case .badServerResponse, .cannotDecodeContentData, .cannotDecodeRawData, .cannotParseResponse:
            return .invalidResponse
        default:
            return fallback
        }
    }
}

#if DEBUG
actor ChatModelSessionSpyingStub: ChatModelSession {
    var events: [ChatResponseEvent]
    var error: (any Error)?
    private(set) var requests: [ChatRequest] = []

    init(events: [ChatResponseEvent] = [], error: (any Error)? = nil) {
        self.events = events
        self.error = error
    }

    func streamResponse(
        to request: ChatRequest
    ) -> AsyncThrowingStream<ChatResponseEvent, Error> {
        requests.append(request)
        let events = events
        let error = error
        return AsyncThrowingStream { continuation in
            for event in events {
                continuation.yield(event)
            }
            continuation.finish(throwing: error)
        }
    }
}

actor ControlledChatModelSession: ChatModelSession {
    private var continuation: AsyncThrowingStream<ChatResponseEvent, Error>.Continuation?
    private(set) var requests: [ChatRequest] = []

    func streamResponse(
        to request: ChatRequest
    ) -> AsyncThrowingStream<ChatResponseEvent, Error> {
        requests.append(request)
        return AsyncThrowingStream { continuation in
            self.continuation = continuation
        }
    }

    func waitUntilStarted() async {
        while continuation == nil {
            await Task.yield()
        }
    }

    func yield(_ event: ChatResponseEvent) {
        continuation?.yield(event)
    }

    func finish(throwing error: (any Error)? = nil) {
        continuation?.finish(throwing: error)
        continuation = nil
    }
}

struct ChatModelProviderStub: ChatModelProvider {
    var currentAvailability: ChatModelAvailability = .available
    var session: any ChatModelSession

    func availability() async -> ChatModelAvailability {
        currentAvailability
    }

    func makeSession(
        configuration: ChatSessionConfiguration
    ) async throws -> any ChatModelSession {
        session
    }
}

struct ChatKnowledgeSourceStub: ChatKnowledgeSource {
    var items: [ChatKnowledgeItem] = []
    var error: ChatbotError?

    func knowledge(for query: String, limit: Int) async throws -> [ChatKnowledgeItem] {
        if let error { throw error }
        return Array(items.prefix(limit))
    }
}
#endif
