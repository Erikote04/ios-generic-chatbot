# GenericChatbot

`GenericChatbot` is a domain-neutral SwiftUI chatbot component for iOS 26 and later. It ships with an Apple Foundation Models provider and protocol-based extension points for any local or remote model, application knowledge source, history store, diagnostics destination, and visual style.

## Requirements

- iOS 26+
- Xcode 26+
- Swift 6.2+

Apple's provider requires an Apple Intelligence-capable device with Apple Intelligence enabled and model assets ready. Remote providers and knowledge sources may additionally require connectivity.

## Installation

### Xcode

1. In Xcode, select **File > Add Package Dependencies**.
2. Enter `https://github.com/Erikote04/ios-generic-chatbot.git`.
3. Select **Up to Next Major Version** and choose the latest release.
4. Add the `GenericChatbot` product to your application target.

### Package.swift

Add GenericChatbot to your package dependencies and application target:

```swift
dependencies: [
    .package(
        url: "https://github.com/Erikote04/ios-generic-chatbot.git",
        from: "1.0.0"
    )
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "GenericChatbot", package: "ios-generic-chatbot")
        ]
    )
]
```

Then import the library where you want to use it:

```swift
import GenericChatbot
```

## Quick start

```swift
import GenericChatbot
import SwiftUI

struct AssistantButton: View {
    var body: some View {
        ChatbotLauncher { close in
            ChatbotView(
                configuration: ChatbotConfiguration(
                    instructions: "Help people understand and use this application.",
                    answerPolicy: .general
                ),
                provider: FoundationModelsChatProvider(),
                close: close
            )
        }
    }
}
```

The default launcher is a round SF Symbol button. `ChatbotView` can also be embedded directly, and `ChatbotStyle` allows every visual slot to be replaced without moving model or persistence behavior into the UI.

## Response language

By default, the assistant detects the language of each new message on device and follows language changes within the same conversation. Short or ambiguous follow-ups continue in the person's most recently identifiable language, including after restoring history, with the app locale as a fallback.

Developers can instead keep responses in the app language or require a specific locale:

```swift
ChatbotConfiguration(responseLanguage: .appLocale)
ChatbotConfiguration(responseLanguage: .fixed(Locale(identifier: "es_ES")))
```

Interface localization remains controlled separately through `ChatbotStrings`. Unsupported Foundation Models languages are reported through `ChatbotError.unsupportedLanguageOrLocale`.

## Documentation

Read the complete [GenericChatbot documentation](https://erikote04.github.io/ios-generic-chatbot/documentation/genericchatbot/) for guides covering model providers, arbitrary application knowledge, errors and recovery, styling, persistence, localization, privacy, and integration best practices.

You can also build the package's DocC archive locally in Xcode. Every public declaration includes English DocC comments with parameter descriptions, behavior, errors, tips, and sample usage where applicable.

## Privacy

The package performs no analytics, logging, remote networking, or durable storage by itself. Those effects occur only through dependencies supplied by the integrating application.

## License

GenericChatbot is available under the MIT license.
