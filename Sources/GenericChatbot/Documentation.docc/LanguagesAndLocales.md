# Languages and Locales

Let people change languages naturally or keep every response in a locale selected by the application.

## Follow the person by default

``ChatbotConfiguration`` defaults to ``ChatbotResponseLanguage/matchingUserInput(fallback:)`` with `Locale.current` as its fallback. For every request, the Foundation Models provider identifies the language from the person's original message on device and gives the model a concrete response locale. This lets one conversation switch from Spanish to English, or from English to Spanish, without creating a new session.

The provider will:

- Respond in the language of the person's latest request.
- Follow an explicit request to switch to another supported language.
- Continue the person's most recently identifiable language for short or ambiguous follow-ups.
- Use the fallback locale only when the conversation doesn't establish a language.

The most recently identified language is restored from persisted conversation history. Very short or low-confidence messages such as “OK” keep that language; the fallback is used only when no request establishes one. This per-request policy prevents the app locale, English developer instructions, internal grounding prompts, or application knowledge from anchoring the entire conversation to one language.

```swift
let configuration = ChatbotConfiguration(
    instructions: "Help people use this application.",
    responseLanguage: .matchingUserInput(fallback: .current)
)
```

## Use the app language

Choose ``ChatbotResponseLanguage/appLocale`` when generated text needs to match the app's current language regardless of the language used in a request:

```swift
let configuration = ChatbotConfiguration(
    responseLanguage: .appLocale
)
```

The Apple provider resolves `Locale.current` when it creates a session. This includes a language selected for the app in system settings. If an app manages a separate in-app language preference, pass that locale with ``ChatbotResponseLanguage/fixed(_:)`` instead.

## Require a locale

Use ``ChatbotResponseLanguage/fixed(_:)`` for experiences that must always respond using a developer-selected language and regional conventions:

```swift
let configuration = ChatbotConfiguration(
    responseLanguage: .fixed(Locale(identifier: "es_ES"))
)
```

The Foundation Models provider checks fixed and app locales with `SystemLanguageModel.supportsLocale(_:)` before creating a session. For matching-user behavior, it checks the locale selected for each request before generation. An unsupported locale produces ``ChatbotError/unsupportedLanguageOrLocale``.

## Localize the interface separately

Response language doesn't translate button labels, empty states, or error messages. Supply localized ``ChatbotStrings`` for presentation text independently of the model policy.

Application knowledge can be written in a different supported language from the response. The provider treats that knowledge as context rather than a response-language preference, but you should test domain terminology and translations on every OS and model version your app supports.

## Support language behavior in custom providers

Every ``ChatModelProvider`` receives the selected value through ``ChatSessionConfiguration/responseLanguage``. A custom local or remote provider needs to map the policy to its own system prompt, locale option, or language controls. Report a known unsupported language as ``ChatbotError/unsupportedLanguageOrLocale``.
