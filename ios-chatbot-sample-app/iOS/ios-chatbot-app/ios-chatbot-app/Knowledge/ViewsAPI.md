# Views API

Public declarations for the embeddable chatbot view, launcher label, and default presentation style.

```swift
/// A complete, embeddable chatbot whose behavior is independent of its style.
///
/// ```swift
/// ChatbotView(
///     configuration: ChatbotConfiguration(instructions: "Help with this app."),
///     provider: FoundationModelsChatProvider(),
///     knowledgeSource: AppKnowledgeSource()
/// )
/// ```
@MainActor public struct ChatbotView<Style> : View where Style : GenericChatbot.ChatbotStyle {

    /// Creates an embeddable chatbot with a custom style.
    ///
    /// - Parameters:
    ///   - configuration: Domain-neutral assistant behavior and localized strings.
    ///   - provider: A local or remote model provider.
    ///   - knowledgeSource: Application context retrieval. Use
    ///     ``EmptyChatKnowledgeSource`` with the `.general` answer policy when no
    ///     application knowledge is needed.
    ///   - historyStore: Conversation persistence. The default store is in memory.
    ///   - reporter: A sanitized error-reporting destination.
    ///   - style: The implementation that creates every visual slot.
    ///   - close: An optional close action, commonly supplied by ``ChatbotLauncher``.
    @MainActor public init(configuration: GenericChatbot.ChatbotConfiguration, provider: any GenericChatbot.ChatModelProvider, knowledgeSource: any GenericChatbot.ChatKnowledgeSource = EmptyChatKnowledgeSource(), historyStore: any GenericChatbot.ChatHistoryStore = InMemoryChatHistoryStore(), reporter: any GenericChatbot.ChatbotErrorReporter = NoOpChatbotErrorReporter(), style: Style, close: (() -> Void)? = nil)

    /// The chatbot interface.
    @MainActor public var body: some View { get }
}

extension ChatbotView where Style == GenericChatbot.DefaultChatbotStyle {

    /// Creates a chatbot using the package's default accessible style.
    ///
    /// - Parameters:
    ///   - configuration: Domain-neutral assistant behavior and localized strings.
    ///   - provider: A local or remote model provider.
    ///   - knowledgeSource: Application context retrieval.
    ///   - historyStore: Optional conversation persistence.
    ///   - reporter: Optional sanitized diagnostics.
    ///   - theme: Semantic colors and message typography.
    ///   - close: An optional close action.
    @MainActor public init(configuration: GenericChatbot.ChatbotConfiguration, provider: any GenericChatbot.ChatModelProvider, knowledgeSource: any GenericChatbot.ChatKnowledgeSource = EmptyChatKnowledgeSource(), historyStore: any GenericChatbot.ChatHistoryStore = InMemoryChatHistoryStore(), reporter: any GenericChatbot.ChatbotErrorReporter = NoOpChatbotErrorReporter(), theme: GenericChatbot.ChatbotTheme = .default, close: (() -> Void)? = nil)
}

/// The default round launcher label containing an SF Symbol.
@MainActor public struct DefaultChatbotLauncherLabel : View {

    /// The circular background color.
    @MainActor public var tint: Color

    /// Creates the default launcher label.
    ///
    /// - Parameter tint: The circular background color.
    @MainActor public init(tint: Color = .accentColor)

    /// A round, 56-point launcher label.
    @MainActor public var body: some View { get }
}

/// The package's system-adaptive, accessible chatbot appearance.
@MainActor public struct DefaultChatbotStyle : GenericChatbot.ChatbotStyle {

    /// Semantic colors and typography used by the style.
    @MainActor public var theme: GenericChatbot.ChatbotTheme

    /// Localized button and state labels.
    @MainActor public var strings: GenericChatbot.ChatbotStrings

    /// Uses the native navigation toolbar and its automatic Liquid Glass treatment.
    @MainActor public var headerPresentation: GenericChatbot.ChatbotHeaderPresentation { get }

    /// Applies the developer-selected accent color to navigation controls.
    @MainActor public var navigationTint: Color { get }

    /// Creates the default chatbot style.
    ///
    /// - Parameters:
    ///   - theme: Semantic colors and message typography.
    ///   - strings: Localized interface labels.
    @MainActor public init(theme: GenericChatbot.ChatbotTheme = .default, strings: GenericChatbot.ChatbotStrings = .default)

    /// Provides the default style's inline-header placeholder.
    ///
    /// ``ChatbotView`` presents this style's header through the native navigation
    /// bar, so no inline content is necessary.
    ///
    /// - Parameter configuration: Header presentation data and actions.
    /// - Returns: An empty inline-header placeholder.
    @MainActor public func makeHeader(configuration _: GenericChatbot.ChatbotHeaderConfiguration) -> some View


    /// Creates the default message bubble.
    ///
    /// - Parameter configuration: The message and optional retry action.
    /// - Returns: A bubble aligned for the message role.
    @MainActor public func makeMessage(configuration: GenericChatbot.ChatbotMessageConfiguration) -> some View


    /// Creates the default source card.
    ///
    /// - Parameter configuration: The source to present.
    /// - Returns: A link when the source has a URL, or a static card otherwise.
    @MainActor public func makeSource(configuration: GenericChatbot.ChatbotSourceConfiguration) -> some View


    /// Creates the default empty state.
    ///
    /// - Parameter configuration: The localized empty-state text.
    /// - Returns: A system content-unavailable view.
    @MainActor public func makeEmptyState(configuration: GenericChatbot.ChatbotEmptyStateConfiguration) -> some View


    /// Creates the default composer.
    ///
    /// - Parameter configuration: Draft binding, activity, and composer actions.
    /// - Returns: A multiline composer with send or cancel controls.
    @MainActor public func makeComposer(configuration: GenericChatbot.ChatbotComposerConfiguration) -> some View


    /// Creates the default model-availability state.
    ///
    /// - Parameter configuration: Current availability and recovery actions.
    /// - Returns: A progress state or blocking failure view.
    @MainActor public func makeAvailability(configuration: GenericChatbot.ChatbotAvailabilityConfiguration) -> some View


    /// Creates the default inline error state.
    ///
    /// - Parameter configuration: The normalized failure and recovery actions.
    /// - Returns: An inline content-unavailable view.
    @MainActor public func makeError(configuration: GenericChatbot.ChatbotErrorConfiguration) -> some View

}
```
