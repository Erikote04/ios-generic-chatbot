# Model Providers

Use Apple's on-device model or adapt any local or remote service.

## Apple Foundation Models

``FoundationModelsChatProvider`` restores complete conversation messages into a `LanguageModelSession`, streams snapshot deltas, and maps Apple errors into ``ChatbotError``.

```swift
let provider = FoundationModelsChatProvider(
    model: .default,
    options: GenerationOptions(temperature: 0.7)
)
```

An application that owns a trained and deployed Apple adapter can construct a `SystemLanguageModel(adapter:)` and pass it to the same initializer. GenericChatbot doesn't train, download, or version adapters.

## Adapt another model

A provider reports availability and creates one session per conversation. The session must serialize requests and honor cancellation.

```swift
struct RemoteModelProvider: ChatModelProvider {
    let client: RemoteModelClient

    func availability() async -> ChatModelAvailability {
        await client.isAuthenticated
            ? .available
            : .unavailable(.authenticationRequired)
    }

    func makeSession(
        configuration: ChatSessionConfiguration
    ) async throws -> any ChatModelSession {
        RemoteModelSession(client: client, configuration: configuration)
    }
}

actor RemoteModelSession: ChatModelSession {
    let client: RemoteModelClient
    let configuration: ChatSessionConfiguration

    func streamResponse(
        to request: ChatRequest
    ) async throws -> AsyncThrowingStream<ChatResponseEvent, Error> {
        client.events(for: request, configuration: configuration)
    }
}
```

Nonstreaming services can emit one ``ChatResponseEvent/textDelta(_:)`` followed by ``ChatResponseEvent/completed``.

Custom providers receive ``ChatSessionConfiguration/responseLanguage`` when the session is created. Translate that value into the provider's native language option or trusted system instructions. For matching-user behavior, prefer the language of the latest user message, continue the last identifiable user language for ambiguous follow-ups, and use the associated locale only as a fallback.

## Provider recommendations

- Use actors for mutable session state.
- Make every public value crossing isolation boundaries `Sendable`.
- Return provider-neutral values rather than exposing SDK-specific types.
- End every stream and propagate cancellation to network/model work.
- Throw ``ChatbotError`` when the provider can classify a failure precisely.
- Honor ``ChatSessionConfiguration/responseLanguage`` without treating retrieved context as a language preference.
- Never expose raw server or SDK diagnostics in user-facing strings.
