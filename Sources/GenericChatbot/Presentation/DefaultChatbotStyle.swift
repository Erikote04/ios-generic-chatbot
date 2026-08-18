import SwiftUI

/// The package's system-adaptive, accessible chatbot appearance.
@MainActor
public struct DefaultChatbotStyle: ChatbotStyle {
    /// Semantic colors and typography used by the style.
    public var theme: ChatbotTheme

    /// Localized button and state labels.
    public var strings: ChatbotStrings

    /// Creates the default chatbot style.
    ///
    /// - Parameters:
    ///   - theme: Semantic colors and message typography.
    ///   - strings: Localized interface labels.
    public init(theme: ChatbotTheme = .default, strings: ChatbotStrings = .default) {
        self.theme = theme
        self.strings = strings
    }

    /// Creates the default header.
    ///
    /// - Parameter configuration: Header presentation data and actions.
    /// - Returns: A system-adaptive header.
    public func makeHeader(configuration: ChatbotHeaderConfiguration) -> some View {
        HStack(spacing: 12) {
            if let close = configuration.close {
                Button(strings.close, systemImage: "xmark", action: close)
                    .labelStyle(.iconOnly)
                    .accessibilityLabel(strings.close)
            }

            Text(configuration.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if configuration.activity != .idle {
                ProgressView()
                    .controlSize(.small)
                    .accessibilityLabel(configuration.activity == .retrieving ? "Retrieving information" : "Generating response")
            }

            Button(
                strings.newConversation,
                systemImage: "square.and.pencil",
                action: configuration.startNewConversation
            )
            .labelStyle(.iconOnly)
            .accessibilityLabel(strings.newConversation)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    /// Creates the default message bubble.
    ///
    /// - Parameter configuration: The message and optional retry action.
    /// - Returns: A bubble aligned for the message role.
    public func makeMessage(configuration: ChatbotMessageConfiguration) -> some View {
        VStack(alignment: configuration.message.role == .user ? .trailing : .leading, spacing: 8) {
            Text(configuration.message.content)
                .font(theme.messageFont)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(
                    configuration.message.role == .user
                        ? theme.userTextColor
                        : theme.assistantTextColor
                )
                .background(
                    configuration.message.role == .user
                        ? theme.userBubbleColor
                        : theme.assistantBubbleColor,
                    in: .rect(cornerRadius: 18)
                )

            if configuration.message.status == .streaming {
                ProgressView()
                    .controlSize(.mini)
                    .accessibilityLabel("Generating response")
            }

            if let retry = configuration.retry {
                Button(strings.retry, systemImage: "arrow.clockwise", action: retry)
                    .font(.caption)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: configuration.message.role == .user ? .trailing : .leading
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            configuration.message.role == .user
                ? "You: \(configuration.message.content)"
                : "Assistant: \(configuration.message.content)"
        )
    }

    /// Creates the default source card.
    ///
    /// - Parameter configuration: The source to present.
    /// - Returns: A link when the source has a URL, or a static card otherwise.
    public func makeSource(configuration: ChatbotSourceConfiguration) -> some View {
        Group {
            if let url = configuration.source.url {
                Link(destination: url) {
                    sourceLabel(configuration.source)
                }
            } else {
                sourceLabel(configuration.source)
            }
        }
        .buttonStyle(.plain)
    }

    /// Creates the default empty state.
    ///
    /// - Parameter configuration: The localized empty-state text.
    /// - Returns: A system content-unavailable view.
    public func makeEmptyState(configuration: ChatbotEmptyStateConfiguration) -> some View {
        ContentUnavailableView(
            configuration.title,
            systemImage: "bubble.left.and.bubble.right",
            description: Text(configuration.message)
        )
    }

    /// Creates the default composer.
    ///
    /// - Parameter configuration: Draft binding, activity, and composer actions.
    /// - Returns: A multiline composer with send or cancel controls.
    public func makeComposer(configuration: ChatbotComposerConfiguration) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                configuration.placeholder,
                text: configuration.text,
                axis: .vertical
            )
            .lineLimit(1...6)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.send)
            .onSubmit(configuration.send)

            if configuration.activity == .responding {
                Button(strings.cancel, systemImage: "stop.fill", action: configuration.cancel)
                    .labelStyle(.iconOnly)
                    .accessibilityLabel(strings.cancel)
            } else {
                Button(strings.send, systemImage: "arrow.up.circle.fill", action: configuration.send)
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(theme.accentColor)
                    .disabled(!configuration.isSendEnabled)
                    .accessibilityLabel(strings.send)
            }
        }
        .padding()
        .background(.bar)
    }

    /// Creates the default model-availability state.
    ///
    /// - Parameter configuration: Current availability and recovery actions.
    /// - Returns: A progress state or blocking failure view.
    public func makeAvailability(configuration: ChatbotAvailabilityConfiguration) -> some View {
        Group {
            if let failure = configuration.failure {
                failureView(failure, perform: configuration.perform)
            } else {
                ContentUnavailableView {
                    Label(strings.checkingAvailabilityTitle, systemImage: "sparkles")
                } description: {
                    Text(strings.checkingAvailabilityMessage)
                } actions: {
                    ProgressView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Creates the default inline error state.
    ///
    /// - Parameter configuration: The normalized failure and recovery actions.
    /// - Returns: An inline content-unavailable view.
    public func makeError(configuration: ChatbotErrorConfiguration) -> some View {
        failureView(configuration.failure, perform: configuration.perform)
            .padding(.horizontal)
    }

    private func sourceLabel(_ source: ChatSource) -> some View {
        Label(source.title, systemImage: source.url == nil ? "doc.text" : "link")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(theme.sourceBackgroundColor, in: .rect(cornerRadius: 10))
    }

    private func failureView(
        _ failure: ChatbotFailure,
        perform: @escaping (ChatbotRecoveryAction) -> Void
    ) -> some View {
        ContentUnavailableView {
            Label(failure.title, systemImage: symbol(for: failure.error))
        } description: {
            Text(failure.message)
        } actions: {
            ForEach(failure.recoveryActions, id: \.self) { action in
                Button(label(for: action)) {
                    perform(action)
                }
            }
        }
    }

    private func label(for action: ChatbotRecoveryAction) -> String {
        switch action {
        case .retryAvailability, .retryRetrieval, .retryResponse: strings.retry
        case .cancel: strings.cancel
        case .startNewConversation: strings.newConversation
        case .dismiss: strings.close
        }
    }

    private func symbol(for error: ChatbotError) -> String {
        switch error {
        case .networkUnavailable, .connectionLost, .timedOut, .hostResolutionFailed,
             .serverUnavailable:
            "wifi.exclamationmark"
        case .guardrailViolation, .refusal:
            "hand.raised.fill"
        case .modelUnavailable(.deviceNotEligible):
            "iphone.slash"
        default:
            "exclamationmark.triangle.fill"
        }
    }
}
