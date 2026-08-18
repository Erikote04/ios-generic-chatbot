import Foundation

/// A reason that a configured model can't accept requests.
public enum ChatModelUnavailableReason: String, Codable, CaseIterable, Sendable {
    /// The device doesn't support the requested model.
    case deviceNotEligible

    /// Apple Intelligence or the configured model service is disabled.
    case serviceNotEnabled

    /// Model assets aren't ready on the device.
    case modelNotReady

    /// A remote provider requires a network connection that isn't available.
    case networkUnavailable

    /// The provider rejected the current credentials.
    case authenticationRequired

    /// The provider is unavailable for a reason it doesn't classify.
    case unknown
}

/// The current ability of a model provider to accept a request.
public enum ChatModelAvailability: Equatable, Sendable {
    /// The provider can create a model session.
    case available

    /// The provider can't currently create a session.
    case unavailable(ChatModelUnavailableReason)
}

/// A normalized chatbot failure independent of a specific model or transport.
public enum ChatbotError: Error, Codable, Equatable, Sendable {
    /// The model isn't available for the associated reason.
    case modelUnavailable(ChatModelUnavailableReason)
    /// The active session exceeded its context window.
    case contextWindowExceeded
    /// Required model assets became unavailable.
    case assetsUnavailable
    /// Model safety guardrails rejected input or output.
    case guardrailViolation
    /// A schema guide isn't supported by the selected model.
    case unsupportedGuide
    /// The model doesn't support the requested language or locale.
    case unsupportedLanguageOrLocale
    /// The provider couldn't decode a model response.
    case decodingFailure
    /// The provider is temporarily rate limited.
    case rateLimited
    /// More than one request reached a session that only permits one.
    case concurrentRequest
    /// The model declined to answer the request.
    case refusal
    /// A model-invoked tool failed.
    case toolCallFailed
    /// A required network connection isn't available.
    case networkUnavailable
    /// An active network connection was lost.
    case connectionLost
    /// A remote operation timed out.
    case timedOut
    /// A remote host couldn't be resolved.
    case hostResolutionFailed
    /// A remote service couldn't accept the request.
    case serverUnavailable
    /// A remote service rejected the supplied credentials.
    case authenticationFailed
    /// A remote service returned an invalid response.
    case invalidResponse
    /// The configured knowledge source failed.
    case retrievalFailed
    /// The configured history store failed.
    case persistenceFailed
    /// A provider failed without a more specific classification.
    case providerFailure
    /// An operation failed for an unrecognized reason.
    case unknown
}

extension ChatbotError: LocalizedError {
    /// A developer-oriented description suitable for diagnostics.
    public var errorDescription: String? {
        switch self {
        case .modelUnavailable(let reason): "The model is unavailable: \(reason.rawValue)."
        case .contextWindowExceeded: "The model session exceeded its context window."
        case .assetsUnavailable: "The required model assets are unavailable."
        case .guardrailViolation: "The request or response violated a model guardrail."
        case .unsupportedGuide: "The model doesn't support a requested generation guide."
        case .unsupportedLanguageOrLocale: "The model doesn't support the requested language or locale."
        case .decodingFailure: "The model response couldn't be decoded."
        case .rateLimited: "The model provider rate limited the request."
        case .concurrentRequest: "The model session received concurrent requests."
        case .refusal: "The model refused the request."
        case .toolCallFailed: "A model tool failed."
        case .networkUnavailable: "A required network connection is unavailable."
        case .connectionLost: "The network connection was lost."
        case .timedOut: "The operation timed out."
        case .hostResolutionFailed: "The remote host couldn't be resolved."
        case .serverUnavailable: "The remote service is unavailable."
        case .authenticationFailed: "The remote service rejected authentication."
        case .invalidResponse: "The remote service returned an invalid response."
        case .retrievalFailed: "The configured knowledge source failed."
        case .persistenceFailed: "The configured history store failed."
        case .providerFailure: "The configured model provider failed."
        case .unknown: "The chatbot operation failed for an unknown reason."
        }
    }
}

/// The visual scope of a chatbot failure.
public enum ChatbotFailureScope: String, Codable, Sendable {
    /// The failure replaces the chat content until it is resolved.
    case blocking

    /// The failure appears above or below the conversation.
    case conversation

    /// The failure is attached to an individual message.
    case message
}

/// A recovery action that a style can present for a failure.
public enum ChatbotRecoveryAction: String, Codable, CaseIterable, Sendable {
    /// Check provider availability again.
    case retryAvailability
    /// Retrieve application context again.
    case retryRetrieval
    /// Generate the failed answer again.
    case retryResponse
    /// Cancel the active operation.
    case cancel
    /// Clear the active context and begin a new conversation.
    case startNewConversation
    /// Close the chatbot presentation.
    case dismiss
}

/// A user-presentable failure and its supported recovery actions.
public struct ChatbotFailure: Identifiable, Equatable, Sendable {
    /// A stable identity for SwiftUI presentation.
    public let id: UUID

    /// The normalized underlying failure.
    public let error: ChatbotError

    /// The recommended visual scope.
    public let scope: ChatbotFailureScope

    /// A short localized title.
    public let title: String

    /// A localized explanation that doesn't expose internal diagnostics.
    public let message: String

    /// Recovery actions valid for this failure.
    public let recoveryActions: [ChatbotRecoveryAction]

    /// Creates a user-presentable failure.
    ///
    /// - Parameters:
    ///   - id: The presentation identity.
    ///   - error: The normalized failure.
    ///   - scope: Where the failure should appear.
    ///   - title: A concise localized title.
    ///   - message: A safe localized explanation.
    ///   - recoveryActions: Actions the interface may offer.
    public init(
        id: UUID = UUID(),
        error: ChatbotError,
        scope: ChatbotFailureScope,
        title: String,
        message: String,
        recoveryActions: [ChatbotRecoveryAction]
    ) {
        self.id = id
        self.error = error
        self.scope = scope
        self.title = title
        self.message = message
        self.recoveryActions = recoveryActions
    }
}
