# Getting Started

Add a round launcher button and configure a model in a few lines.

## Add the package

Add this repository as a Swift Package dependency and link the `GenericChatbot` product to an iOS 26-or-later target.

## Present the default chatbot

Use ``ChatbotLauncher`` when the package should own modal presentation. Its content closure receives the correct close action for either a sheet or full-screen cover.

```swift
import GenericChatbot
import SwiftUI

struct ContentView: View {
    private let provider = FoundationModelsChatProvider()

    var body: some View {
        ChatbotLauncher(
            presentationStyle: .sheet,
            accessibilityLabel: "Open help"
        ) { close in
            ChatbotView(
                configuration: ChatbotConfiguration(
                    title: "Help",
                    instructions: "Help people use the application.",
                    answerPolicy: .general
                ),
                provider: provider,
                close: close
            )
        }
    }
}
```

The Foundation Models provider checks whether the device supports Apple Intelligence, whether it is enabled, and whether model assets are ready. The composer remains disabled until the model is available.

The default ``ChatbotResponseLanguage/matchingUserInput(fallback:)`` behavior answers in the language of the person's latest message and follows language changes during the conversation. See <doc:LanguagesAndLocales> to use the app locale or require a developer-selected locale.

## Embed the chat directly

Place ``ChatbotView`` anywhere a SwiftUI view is accepted. Omit `close` when the host owns navigation outside the component.

```swift
NavigationStack {
    ChatbotView(
        configuration: ChatbotConfiguration(answerPolicy: .general),
        provider: FoundationModelsChatProvider()
    )
}
```

## Recommended next steps

- Use ``ChatKnowledgeSource`` for large or changing application information.
- Keep developer instructions short because they consume model context.
- Choose an explicit ``ChatbotResponseLanguage`` when responses must remain in the app language or a fixed locale.
- Default to ``ChatAnswerPolicy/groundedOnly`` when unsupported statements would be harmful.
- Inject localized ``ChatbotStrings`` from the host application.
- Add a ``ChatbotErrorReporter`` for sanitized operational diagnostics.
