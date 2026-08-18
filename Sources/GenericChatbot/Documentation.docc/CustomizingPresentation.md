# Customizing Presentation

Replace every visual slot while retaining package-owned behavior.

## Change semantic appearance

Use ``ChatbotTheme`` when the default structure is appropriate:

```swift
ChatbotView(
    configuration: configuration,
    provider: provider,
    theme: ChatbotTheme(
        accentColor: .purple,
        userBubbleColor: .purple,
        assistantBubbleColor: .gray.opacity(0.15)
    )
)
```

## Implement a complete style

``ChatbotStyle`` provides typed configurations for the header, message, source, empty, composer, availability, and error slots. A custom style can replace selected slots and delegate the remainder to ``DefaultChatbotStyle``.

```swift
struct BrandChatbotStyle: ChatbotStyle {
    private let base = DefaultChatbotStyle()

    func makeHeader(configuration: ChatbotHeaderConfiguration) -> some View {
        base.makeHeader(configuration: configuration)
            .background(.purple.opacity(0.1))
    }

    func makeMessage(configuration: ChatbotMessageConfiguration) -> some View {
        base.makeMessage(configuration: configuration)
    }

    func makeSource(configuration: ChatbotSourceConfiguration) -> some View {
        base.makeSource(configuration: configuration)
    }

    func makeEmptyState(configuration: ChatbotEmptyStateConfiguration) -> some View {
        base.makeEmptyState(configuration: configuration)
    }

    func makeComposer(configuration: ChatbotComposerConfiguration) -> some View {
        base.makeComposer(configuration: configuration)
    }

    func makeAvailability(configuration: ChatbotAvailabilityConfiguration) -> some View {
        base.makeAvailability(configuration: configuration)
    }

    func makeError(configuration: ChatbotErrorConfiguration) -> some View {
        base.makeError(configuration: configuration)
    }
}
```

Custom slots receive presentation data and narrowly scoped actions. They must not create model sessions, retrieve knowledge, persist messages, or launch duplicate asynchronous requests.

## Accessibility recommendations

- Keep interactive targets at least 44 points.
- Preserve Dynamic Type and VoiceOver labels.
- Expose send, cancel, retry, close, and new-conversation actions as buttons.
- Don't communicate streaming, errors, or authorship using color alone.
- Respect Reduce Motion when adding custom animation.
