import SwiftUI

/// A complete, embeddable chatbot whose behavior is independent of its style.
///
/// ```swift
/// ChatbotView(
///     configuration: ChatbotConfiguration(instructions: "Help with this app."),
///     provider: FoundationModelsChatProvider(),
///     knowledgeSource: AppKnowledgeSource()
/// )
/// ```
@MainActor
public struct ChatbotView<Style: ChatbotStyle>: View {
    @State private var viewModel: ChatbotViewModel

    private let style: Style
    private let close: (() -> Void)?

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
    public init(
        configuration: ChatbotConfiguration,
        provider: any ChatModelProvider,
        knowledgeSource: any ChatKnowledgeSource = EmptyChatKnowledgeSource(),
        historyStore: any ChatHistoryStore = InMemoryChatHistoryStore(),
        reporter: any ChatbotErrorReporter = NoOpChatbotErrorReporter(),
        style: Style,
        close: (() -> Void)? = nil
    ) {
        _viewModel = State(
            initialValue: ChatbotViewModel(
                configuration: configuration,
                provider: provider,
                knowledgeSource: knowledgeSource,
                historyStore: historyStore,
                reporter: reporter
            )
        )
        self.style = style
        self.close = close
    }

    /// The chatbot interface.
    public var body: some View {
        Group {
            switch style.headerPresentation {
            case .inline:
                chatbotContent(showsInlineHeader: true)
            case .navigationBar:
                NavigationStack {
                    chatbotContent(showsInlineHeader: false)
                        .navigationTitle(viewModel.configuration.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            navigationToolbar
                        }
                }
                .tint(style.navigationTint)
            }
        }
        .task {
            await viewModel.prepare()
        }
    }

    private func chatbotContent(showsInlineHeader: Bool) -> some View {
        VStack(spacing: 0) {
            if showsInlineHeader {
                style.makeHeader(
                    configuration: ChatbotHeaderConfiguration(
                        title: viewModel.configuration.title,
                        activity: viewModel.activity,
                        startNewConversation: viewModel.startNewConversation,
                        close: close
                    )
                )

                Divider()
            }

            if viewModel.availability != .available || viewModel.blockingFailure != nil {
                style.makeAvailability(
                    configuration: ChatbotAvailabilityConfiguration(
                        availability: viewModel.availability,
                        failure: viewModel.blockingFailure,
                        perform: perform
                    )
                )
            } else {
                conversationContent
            }
        }
    }

    @ToolbarContentBuilder
    private var navigationToolbar: some ToolbarContent {
        if let close {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    viewModel.configuration.strings.close,
                    systemImage: "xmark",
                    action: close
                )
                .labelStyle(.iconOnly)
                .accessibilityLabel(viewModel.configuration.strings.close)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(
                viewModel.configuration.strings.newConversation,
                systemImage: "square.and.pencil",
                action: viewModel.startNewConversation
            )
            .labelStyle(.iconOnly)
            .accessibilityLabel(viewModel.configuration.strings.newConversation)
        }
    }

    @ViewBuilder
    private var conversationContent: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            ChatbotConversationView(
                viewModel: viewModel,
                style: style,
                perform: perform
            )

            if let failure = viewModel.conversationFailure {
                style.makeError(
                    configuration: ChatbotErrorConfiguration(
                        failure: failure,
                        perform: perform
                    )
                )
                .padding(.vertical, 8)
            }

            style.makeComposer(
                configuration: ChatbotComposerConfiguration(
                    text: $viewModel.draft,
                    placeholder: viewModel.configuration.strings.composerPlaceholder,
                    isSendEnabled: viewModel.isSendEnabled,
                    activity: viewModel.activity,
                    send: viewModel.send,
                    cancel: viewModel.cancelResponse
                )
            )
        }
    }

    private func perform(_ action: ChatbotRecoveryAction) {
        if action == .dismiss {
            close?()
        } else {
            viewModel.perform(action)
        }
    }
}

extension ChatbotView where Style == DefaultChatbotStyle {
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
    public init(
        configuration: ChatbotConfiguration,
        provider: any ChatModelProvider,
        knowledgeSource: any ChatKnowledgeSource = EmptyChatKnowledgeSource(),
        historyStore: any ChatHistoryStore = InMemoryChatHistoryStore(),
        reporter: any ChatbotErrorReporter = NoOpChatbotErrorReporter(),
        theme: ChatbotTheme = .default,
        close: (() -> Void)? = nil
    ) {
        self.init(
            configuration: configuration,
            provider: provider,
            knowledgeSource: knowledgeSource,
            historyStore: historyStore,
            reporter: reporter,
            style: DefaultChatbotStyle(theme: theme, strings: configuration.strings),
            close: close
        )
    }
}

@MainActor
private struct ChatbotConversationView<Style: ChatbotStyle>: View {
    let viewModel: ChatbotViewModel
    let style: Style
    let perform: (ChatbotRecoveryAction) -> Void

    var body: some View {
        if viewModel.conversation.messages.isEmpty {
            style.makeEmptyState(
                configuration: ChatbotEmptyStateConfiguration(
                    title: viewModel.configuration.strings.emptyTitle,
                    message: viewModel.configuration.strings.emptyMessage
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.conversation.messages) { message in
                            messageContent(message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.conversation.messages.last?.content) {
                    guard let id = viewModel.conversation.messages.last?.id else { return }
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func messageContent(_ message: ChatMessage) -> some View {
        let failure = message.failure.map {
            ChatbotFailureFactory.make(
                $0,
                strings: viewModel.configuration.strings,
                scope: .message
            )
        }
        let canRetry = failure?.recoveryActions.contains(where: {
            $0 == .retryRetrieval || $0 == .retryResponse
        }) == true

        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
            style.makeMessage(
                configuration: ChatbotMessageConfiguration(
                    message: message,
                    retry: canRetry ? { viewModel.retry(messageID: message.id) } : nil
                )
            )

            if !message.sources.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(message.sources) { source in
                            style.makeSource(
                                configuration: ChatbotSourceConfiguration(source: source)
                            )
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }

            if let failure, failure.recoveryActions.isEmpty {
                style.makeError(
                    configuration: ChatbotErrorConfiguration(
                        failure: failure,
                        perform: perform
                    )
                )
            }
        }
    }
}
