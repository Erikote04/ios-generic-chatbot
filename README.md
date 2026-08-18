# GenericChatbot

`GenericChatbot` is a domain-neutral SwiftUI chatbot component for iOS 26 and later. It ships with an Apple Foundation Models provider and protocol-based extension points for any local or remote model, application knowledge source, history store, diagnostics destination, and visual style.

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

## Requirements

- iOS 26+
- Xcode 26+
- Swift 6.2+

Apple's provider requires an Apple Intelligence-capable device with Apple Intelligence enabled and model assets ready. Remote providers and knowledge sources may additionally require connectivity.

## Documentation

Build the package's DocC archive in Xcode for complete guides covering model providers, arbitrary application knowledge, errors and recovery, styling, persistence, localization, privacy, and integration best practices. Every public declaration includes English DocC comments, parameter descriptions, behavior, errors, tips, and sample usage where applicable.

## Privacy

The package performs no analytics, logging, remote networking, or durable storage by itself. Those effects occur only through dependencies supplied by the integrating application.

## License

GenericChatbot is available under the MIT license.
