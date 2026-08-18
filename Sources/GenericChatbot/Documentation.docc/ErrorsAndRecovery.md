# Errors and Recovery

Present safe, actionable failures without losing the conversation.

## Availability

The Apple provider covers every current `SystemLanguageModel` unavailable reason:

| Apple reason | GenericChatbot state | Recovery |
| --- | --- | --- |
| `deviceNotEligible` | Device unsupported | Dismiss or use a host fallback |
| `appleIntelligenceNotEnabled` | Service disabled | Enable the service, then recheck |
| `modelNotReady` | Assets not ready | Wait and retry availability |

Apple's model runs on-device once its assets are ready. A disconnected network must not disable it. Network availability applies only to injected providers or knowledge sources that require connectivity.

## Foundation Models generation errors

GenericChatbot covers every current `LanguageModelSession.GenerationError`:

- `exceededContextWindowSize`: offer a new conversation without hiding existing history.
- `assetsUnavailable`: display a retryable model-assets failure.
- `guardrailViolation`: discard partial output and display a neutral safety response.
- `unsupportedGuide`: report a developer configuration failure without exposing diagnostics.
- `unsupportedLanguageOrLocale`: display an unsupported-language state.
- `decodingFailure`: mark the message failed and offer retry.
- `rateLimited`: offer retry without inventing a retry interval.
- `concurrentRequests`: recover the session invariant and report it.
- `refusal`: stream Apple's explanation when possible, otherwise use the configured refusal message.

The provider also covers `LanguageModelSession.ToolCallError`, `CancellationError`, and unknown future SDK cases.

## Connectivity and remote services

Provider-neutral errors cover offline status, connection loss, timeout, host resolution, server availability, authentication, invalid responses, retrieval, persistence, provider failures, and unknown transports.

```swift
do {
    return try await client.stream(request)
} catch let error as URLError where error.code == .notConnectedToInternet {
    throw ChatbotError.networkUnavailable
}
```

The package maps common `URLError` values automatically when they escape an injected dependency.

## Custom diagnostics

Use ``ChatbotErrorReporter`` to collect sanitized operational data. Don't include prompts, retrieved content, generated messages, secrets, or personal information in diagnostic context.

```swift
struct ErrorReporter: ChatbotErrorReporter {
    func report(_ error: ChatbotError, context: ChatbotDiagnosticContext) async {
        telemetry.record(error: error, operation: context.operation)
    }
}
```
