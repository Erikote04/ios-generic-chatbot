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

    @Test("Matching-user instructions delegate language selection to every prompt")
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
        #expect(!instructions.contains("The person's locale is es_ES."))
        #expect(instructions.contains("follow the RESPONSE LANGUAGE specified in each prompt"))
        #expect(instructions.contains("may change languages between requests"))
    }

    @Test("Matching-user policy switches from Spanish to English in one conversation")
    func switchesFromSpanishToEnglish() {
        // Given
        let policy = ChatbotResponseLanguage.matchingUserInput(
            fallback: Locale(identifier: "es_ES")
        )

        // When: the first request establishes Spanish.
        let spanish = FoundationModelsResponseLanguageResolver.resolve(
            prompt: "¿Puedes resumir esta información en dos frases?",
            responseLanguage: policy,
            previousUserLocale: nil
        )
        let english = FoundationModelsResponseLanguageResolver.resolve(
            prompt: "Can you now explain the main idea in English?",
            responseLanguage: policy,
            previousUserLocale: spanish.identifiedUserLocale
        )

        // Then
        #expect(spanish.responseLocale.identifier == "es_ES")
        #expect(isLanguage("en", equivalentTo: english.responseLocale))
    }

    @Test("Matching-user policy switches from English to Spanish in one conversation")
    func switchesFromEnglishToSpanish() {
        // Given
        let policy = ChatbotResponseLanguage.matchingUserInput(
            fallback: Locale(identifier: "es_ES")
        )

        // When: the first request establishes English.
        let english = FoundationModelsResponseLanguageResolver.resolve(
            prompt: "Can you summarize this information in two sentences?",
            responseLanguage: policy,
            previousUserLocale: nil
        )
        let spanish = FoundationModelsResponseLanguageResolver.resolve(
            prompt: "¿Puedes explicarme ahora la idea principal en español?",
            responseLanguage: policy,
            previousUserLocale: english.identifiedUserLocale
        )

        // Then
        #expect(isLanguage("en", equivalentTo: english.responseLocale))
        #expect(spanish.responseLocale.identifier == "es_ES")
    }

    @Test("An ambiguous follow-up keeps the most recently identified language")
    func ambiguousFollowUpKeepsPreviousLanguage() {
        // Given
        let previousLocale = Locale(identifier: "en_GB")

        // When
        let resolution = FoundationModelsResponseLanguageResolver.resolve(
            prompt: "OK",
            responseLanguage: .matchingUserInput(fallback: Locale(identifier: "es_ES")),
            previousUserLocale: previousLocale
        )

        // Then
        #expect(resolution.responseLocale == previousLocale)
        #expect(resolution.identifiedUserLocale == nil)
    }

    @Test("A restored conversation remembers its latest identifiable user language")
    func restoredConversationLanguage() {
        // Given
        let conversation = ChatConversation(messages: [
            ChatMessage(role: .user, content: "Explícame esta información en español."),
            ChatMessage(role: .assistant, content: "Aquí tienes la explicación."),
            ChatMessage(role: .user, content: "Now explain the next part in English."),
            ChatMessage(role: .assistant, content: "Here is the explanation."),
        ])

        // When
        let locale = FoundationModelsResponseLanguageResolver.mostRecentLocale(
            in: conversation,
            responseLanguage: .matchingUserInput(fallback: Locale(identifier: "es_ES"))
        )

        // Then
        #expect(locale.map { isLanguage("en", equivalentTo: $0) } == true)
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

    @Test("Prompt ends with user text and does not expose an end-user delimiter")
    func promptDoesNotExposeTrailingDelimiter() {
        // Given
        let request = ChatRequest(
            prompt: "What can you help me with?",
            answerPolicy: .general
        )

        // When
        let prompt = FoundationModelsPromptBuilder.makePrompt(
            for: request,
            responseLocale: Locale(identifier: "en_US"),
            allowsExplicitLanguageOverride: true
        )

        // Then
        #expect(prompt.contains("MUST respond in English"))
        #expect(prompt.contains("explicitly requests another supported language"))
        #expect(!prompt.contains("END USER REQUEST"))
        #expect(prompt.hasSuffix(request.prompt))
    }

    private func isLanguage(_ identifier: String, equivalentTo locale: Locale) -> Bool {
        Locale.Language(identifier: identifier).isEquivalent(to: locale.language)
    }
}
