import Foundation
import FoundationModels
import Testing
@testable import GenericChatbot

@Suite("Error mapping")
struct ErrorMappingTests {
    @Test("Maps common URL failures without exposing transport types")
    func mapsURLFailures() {
        // Given
        let cases: [(URLError.Code, ChatbotError)] = [
            (.notConnectedToInternet, .networkUnavailable),
            (.dataNotAllowed, .networkUnavailable),
            (.networkConnectionLost, .connectionLost),
            (.timedOut, .timedOut),
            (.cannotFindHost, .hostResolutionFailed),
            (.dnsLookupFailed, .hostResolutionFailed),
            (.cannotConnectToHost, .serverUnavailable),
            (.userAuthenticationRequired, .authenticationFailed),
            (.badServerResponse, .invalidResponse),
            (.cannotDecodeContentData, .invalidResponse),
        ]

        // When / Then
        for (code, expected) in cases {
            #expect(ChatbotErrorMapper.map(URLError(code)) == expected)
        }
    }

    @Test("Preserves errors already normalized by a provider")
    func preservesChatbotError() {
        // Given
        let error = ChatbotError.rateLimited

        // When
        let mapped = ChatbotErrorMapper.map(error)

        // Then
        #expect(mapped == .rateLimited)
    }

    @Test("Maps every current Foundation Models generation error")
    func mapsFoundationModelsGenerationErrors() {
        // Given
        let context = LanguageModelSession.GenerationError.Context(debugDescription: "test")
        let cases: [(LanguageModelSession.GenerationError, ChatbotError)] = [
            (.exceededContextWindowSize(context), .contextWindowExceeded),
            (.assetsUnavailable(context), .assetsUnavailable),
            (.guardrailViolation(context), .guardrailViolation),
            (.unsupportedGuide(context), .unsupportedGuide),
            (.unsupportedLanguageOrLocale(context), .unsupportedLanguageOrLocale),
            (.decodingFailure(context), .decodingFailure),
            (.rateLimited(context), .rateLimited),
            (.concurrentRequests(context), .concurrentRequest),
        ]

        // When / Then
        for (error, expected) in cases {
            #expect(FoundationModelsErrorMapper.map(error) == expected)
        }
    }

    @Test("Maps every current Foundation Models availability reason")
    func mapsFoundationModelsAvailability() {
        // Given / When / Then
        #expect(FoundationModelsChatProvider.mapAvailability(.available) == .available)
        #expect(
            FoundationModelsChatProvider.mapAvailability(.unavailable(.deviceNotEligible))
                == .unavailable(.deviceNotEligible)
        )
        #expect(
            FoundationModelsChatProvider.mapAvailability(.unavailable(.appleIntelligenceNotEnabled))
                == .unavailable(.serviceNotEnabled)
        )
        #expect(
            FoundationModelsChatProvider.mapAvailability(.unavailable(.modelNotReady))
                == .unavailable(.modelNotReady)
        )
    }
}
