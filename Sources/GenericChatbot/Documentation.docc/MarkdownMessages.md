# Formatting Model Messages with Markdown

Present structured answers that remain readable and easy to copy.

## Default rendering

``DefaultChatbotStyle`` interprets Markdown in assistant messages. It uses Apple's native `AttributedString` Markdown parsing for inline formatting and presents fenced code as horizontally scrollable, monospaced blocks.

Supported formatting includes:

- Bold text using `**bold**` or `__bold__`
- Italic text using `*italic*` or `_italic_`
- Inline code using backticks
- Fenced code blocks using three backticks or tildes, with an optional language identifier
- Links using standard Markdown link syntax
- Plain web addresses, email addresses, and phone numbers, detected automatically
- Underlined text using the package's `<u>underlined</u>` extension

> Note: CommonMark doesn't define underline syntax. GenericChatbot recognizes `<u>...</u>` in assistant messages and converts it to a native underline attribute without displaying the tags.

User messages remain literal, so text entered by a person is never unexpectedly reformatted.

## Interactive contact information

The default style turns contact information in assistant messages into native system links:

- Web URLs use `https:` or `http:` and open a Universal Link destination when available, or the person's default browser.
- Email addresses use `mailto:` and open the person's configured mail application.
- Phone numbers use `tel:` and ask the system to hand the call to the configured calling application.

The model can return either explicit Markdown, such as `[See frequently asked questions](https://example.com/faqs)`, or plain contact information such as `help@example.com` and `+34 912 34 56 78`. GenericChatbot detects the plain forms automatically. It doesn't make contact information inside inline or fenced code interactive.

All interactions use SwiftUI's `openURL` environment action. A host application can observe, allow, replace, or discard destinations without modifying the library:

```swift
ChatbotView(configuration: configuration, provider: provider)
    .environment(\.openURL, OpenURLAction { url in
        analytics.recordChatbotLink(url)
        return .systemAction
    })
```

> Important: Treat model-generated destinations as untrusted content. For sensitive applications, constrain allowed destinations in developer instructions or provide a custom `OpenURLAction` that validates the URL before returning `.systemAction`.

## Ask a model to format useful answers

Markdown rendering doesn't force a provider to generate Markdown. Add concise formatting guidance to the trusted developer instructions when structured answers are useful:

```swift
let configuration = ChatbotConfiguration(
    instructions: """
    Help people use this application.
    Use Markdown when it improves clarity. Put source code in fenced code blocks
    with a language identifier. Use <u>...</u> only when underline is necessary.
    """,
    answerPolicy: .general
)
```

Every ``ChatModelProvider`` still returns ordinary strings through ``ChatResponseEvent``. The presentation layer interprets formatting, so persisted conversations and custom providers don't need a different message format.

## Selection and copying

The default style enables native text selection for user and assistant messages, including inline Markdown and code blocks. On iOS, touch and hold the relevant text to show the system copy menu. Selection behavior follows the platform.

## Custom styles

A custom ``ChatbotStyle`` receives the raw Markdown string in ``ChatbotMessageConfiguration/message``. Delegate message rows to ``DefaultChatbotStyle`` to inherit Markdown rendering and selection, or parse the content into an `AttributedString` and apply SwiftUI's `textSelection(_:)` modifier in your own row.

During streaming, an unfinished Markdown construct is kept readable. An opening code fence is presented as a code block even before its closing fence arrives, and invalid inline Markdown falls back to plain text.
