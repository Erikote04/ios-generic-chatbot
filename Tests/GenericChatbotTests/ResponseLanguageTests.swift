import Foundation
import Testing
@testable import GenericChatbot

@Suite("Response language")
struct ResponseLanguageTests {
    @Test("Defaults to matching the latest user input with the app locale as fallback")
    func defaultBehavior() {
        // Given / When
        let configuration = ChatbotConfiguration()

        // Then
        #expect(configuration.responseLanguage == .matchingUserInput(fallback: .current))
    }

    @Test("Matching-user instructions preserve developer instructions and permit language changes")
    func matchingUserInputInstructions() {
        // Given
        let configuration = ChatSessionConfiguration(
            instructions: "Answer using application knowledge.",
            conversation: ChatConversation(),
            responseLanguage: .matchingUserInput(fallback: Locale(identifier: "es_ES"))
        )

        // When
        let instructions = FoundationModelsChatProvider.makeInstructions(for: configuration)

        // Then
        #expect(instructions.hasPrefix("Answer using application knowledge."))
        #expect(instructions.contains("The person's locale is es_ES."))
        #expect(instructions.contains("MUST respond in the language used in the person's most recent request"))
        #expect(instructions.contains("Follow an explicit request to respond in another supported language"))
        #expect(instructions.contains("continue using the language the person most recently used"))
    }

    @Test("Matching-user instructions omit the locale phrase for U.S. English")
    func matchingUSLocaleInstructions() {
        // Given
        let configuration = ChatSessionConfiguration(
            instructions: "",
            conversation: ChatConversation(),
            responseLanguage: .matchingUserInput(fallback: Locale(identifier: "en_US"))
        )

        // When
        let instructions = FoundationModelsChatProvider.makeInstructions(for: configuration)

        // Then
        #expect(!instructions.contains("The person's locale is"))
        #expect(instructions.contains("MUST respond in the language used"))
    }

    @Test("App-locale instructions resolve the locale when the session is created")
    func appLocaleInstructions() {
        // Given
        let configuration = ChatSessionConfiguration(
            instructions: "",
            conversation: ChatConversation(),
            responseLanguage: .appLocale
        )

        // When
        let instructions = FoundationModelsChatProvider.makeInstructions(
            for: configuration,
            currentLocale: Locale(identifier: "fr_FR")
        )

        // Then
        #expect(instructions.contains("The person's locale is fr_FR."))
        #expect(instructions.contains("MUST respond in the language of the person's locale"))
    }

    @Test("Fixed-language instructions name the selected language and regional conventions")
    func fixedLanguageInstructions() {
        // Given
        let configuration = ChatSessionConfiguration(
            instructions: "",
            conversation: ChatConversation(),
            responseLanguage: .fixed(Locale(identifier: "es_ES"))
        )

        // When
        let instructions = FoundationModelsChatProvider.makeInstructions(for: configuration)

        // Then
        #expect(instructions.contains("The person's locale is es_ES."))
        #expect(instructions.contains("MUST respond in Spanish"))
        #expect(instructions.contains("cultural conventions of es_ES"))
    }
}
