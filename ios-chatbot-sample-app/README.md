# GenericChatbot Sample App

A small SwiftUI app showing how to add an app-aware assistant with `GenericChatbot`. The examples keep integration at the view boundary and demonstrate configuration, custom strings, theming, grounded answers, an application-owned knowledge source, and multiple presentation patterns.

## Requirements

- iOS 26 or later
- Xcode 26 or later
- Swift 6.2 or later
- An Apple Intelligence-capable device with Apple Intelligence enabled and the on-device model available

## Run the sample

1. Open `ios-chatbot-app/ios-chatbot-app.xcodeproj` in Xcode.
2. Wait for Swift Package Manager to resolve `GenericChatbot`.
3. Select a compatible device and run the `ios-chatbot-app` scheme.
4. Tap the assistant button in the bottom-trailing corner and try one of the suggested questions.

> **Recommendation:** Test this sample—and any chatbot you build with GenericChatbot—on a real Apple Intelligence-capable device. Foundation Models may be unavailable or behave inconsistently in the simulator, so simulator results might not accurately represent the experience on a supported device.

If Foundation Models are unavailable, the chatbot presents the library's normalized availability error instead of starting a conversation.

## Examples

The implementation lives in `ios-chatbot-app/ios-chatbot-app/ContentView.swift` and includes three Xcode previews:

- **Floating assistant:** The original landing screen with a chatbot launcher fixed to the bottom-trailing corner. This is the example shown when the app runs.
- **Assistant tab:** A five-item tab bar with Home, Search, AI Assistant, Notifications, and Profile. The AI Assistant tab embeds `ChatbotView` directly instead of presenting it modally.
- **Tabs with floating assistant:** A four-item custom bottom navigation bar with Home, Discovery, Activity, and Profile, aligned beside a separate chatbot launcher.

## What the integration demonstrates

The examples use:

- `ChatbotLauncher` to present the assistant from a floating button.
- `ChatbotView` directly as the content of a tab.
- `ChatbotConfiguration` to define instructions, grounded-only answers, response-language behavior, strings, and retrieval behavior.
- `FoundationModelsChatProvider` for Apple's on-device model.
- The bundled `Knowledge` articles containing the DocC integration guides and public API grouped by responsibility.
- `SampleKnowledgeSource` to rank those articles for each question and provide only focused app-owned context without retraining the model or exhausting the model's context window.
- `ChatbotTheme` to apply the sample's indigo accent.

The essential presentation code is:

```swift
ChatbotLauncher(tint: .indigo) { close in
    ChatbotView(
        configuration: configuration,
        provider: FoundationModelsChatProvider(),
        knowledgeSource: SampleKnowledgeSource(),
        theme: ChatbotTheme(
            accentColor: .indigo,
            userBubbleColor: .indigo
        ),
        close: close
    )
}
```

Replace the sample instructions, strings, theme, and knowledge source with values and adapters owned by your app. See the [complete GenericChatbot documentation](https://erikote04.github.io/ios-generic-chatbot/documentation/genericchatbot/) for all configuration and extension points.

The sample keeps the documentation as focused Markdown articles because headings, paragraphs, lists, and code fences make each source easy to maintain and retrieve. The knowledge source reads the articles, divides only oversized API references into bounded chunks, and supplies at most the three most relevant results. It never sends the complete documentation corpus for every question. Markdown improves structure and maintainability rather than changing the model's underlying knowledge.

GenericChatbot detects the language of each user message on device by default, allowing the person to change languages without starting a new conversation. Short or ambiguous follow-ups retain the latest identifiable language. Use `.appLocale` or `.fixed(Locale(...))` when your product requires a stable response language.
