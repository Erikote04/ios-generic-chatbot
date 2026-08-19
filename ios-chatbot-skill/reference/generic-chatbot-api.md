# GenericChatbot API

Use the hosted DocC documentation as the authoritative public API reference:

https://erikote04.github.io/ios-generic-chatbot/documentation/genericchatbot/

## Minimal SwiftUI integration

```swift
import GenericChatbot
import SwiftUI

struct AssistantEntryPoint: View {
    var body: some View {
        ChatbotLauncher { close in
            ChatbotView(
                configuration: ChatbotConfiguration(
                    title: "Assistant",
                    instructions: "Help people use this application.",
                    answerPolicy: .general
                ),
                provider: FoundationModelsChatProvider(),
                close: close
            )
        }
    }
}
```

## Main extension points

- `ChatModelProvider`: Report availability and create one session per conversation.
- `ChatModelSession`: Stream normalized `ChatResponseEvent` values and honor cancellation.
- `ChatKnowledgeSource`: Retrieve relevant application-owned context for each prompt.
- `ChatHistoryStore`: Load, save, and delete conversations using host-owned persistence.
- `ChatbotErrorReporter`: Receive sanitized operational failures.
- `ChatbotStyle`: Replace every visual slot while retaining package behavior.
- `ChatbotTheme`: Customize semantic colors and message typography without replacing structure.
- `ChatbotStrings`: Supply host-localized interface and error text.

## Configuration choices

- Use `.groundedOnly` when answers must rely on returned application context. The model is not called when retrieval returns no items.
- Use `.general` when the model may answer from general capabilities and optionally prefer retrieved context.
- Use `.newConversation` for ephemeral sessions.
- Use `.resume(conversationID:)` with a `ChatHistoryStore` for restorable conversations.
- Keep the default `.matchingUserInput()` response language when people should be able to change languages during a conversation. Use `.appLocale` for the app's language or `.fixed(Locale(...))` for a required locale.
- Keep developer instructions concise; put large or changing information behind `ChatKnowledgeSource`.

## UIKit presentation

Build `ChatbotView` in the architecture's factory and present it with `UIHostingController`:

```swift
let controller = UIHostingController(
    rootView: ChatbotView(
        configuration: configuration,
        provider: provider,
        knowledgeSource: knowledgeSource,
        close: { [weak presentingController] in
            presentingController?.dismiss(animated: true)
        }
    )
)
presentingController.present(controller, animated: true)
```

Adapt the closure to the app's router or coordinator rather than retaining a view controller from a long-lived dependency.

## Foundation Models behavior

`FoundationModelsChatProvider` checks Apple model availability, restores complete history, applies the configured response-language behavior, streams response deltas, and normalizes all current Foundation Models availability and generation failures. Apple's model runs on-device once assets are ready; network reachability belongs only to remote providers or knowledge sources.
