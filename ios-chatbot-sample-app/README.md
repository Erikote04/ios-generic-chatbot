# GenericChatbot Sample App

A small SwiftUI app showing how to add an app-aware assistant with `GenericChatbot`. The example keeps integration at the view boundary and demonstrates configuration, custom strings, theming, grounded answers, and an application-owned knowledge source.

## Requirements

- iOS 26 or later
- Xcode 26 or later
- Swift 6.2 or later
- An Apple Intelligence-capable device with Apple Intelligence enabled and the on-device model available

## Run the sample

1. Open `ios-chatbot-app/ios-chatbot-app.xcodeproj` in Xcode.
2. Wait for Swift Package Manager to resolve `GenericChatbot`.
3. Select a compatible device and run the `ios-chatbot-app` scheme.
4. Tap **Open assistant** and try one of the suggested questions.

If Foundation Models are unavailable, the chatbot presents the library's normalized availability error instead of starting a conversation.

## What the integration demonstrates

The implementation lives in `ios-chatbot-app/ios-chatbot-app/ContentView.swift` and uses:

- `ChatbotLauncher` to present the assistant.
- `ChatbotConfiguration` to define instructions, grounded-only answers, strings, and retrieval behavior.
- `FoundationModelsChatProvider` for Apple's on-device model.
- `SampleKnowledgeSource` to provide app-owned context without retraining the model.
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
