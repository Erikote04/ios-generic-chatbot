import Foundation
import SwiftUI
import Testing
@testable import GenericChatbot

@Suite("Markdown presentation")
@MainActor
struct MarkdownPresentationTests {
    @Test("Fenced code is separated from surrounding Markdown")
    func parsesFencedCodeBlocks() {
        // Given
        let markdown = """
        Use this implementation:

        ```swift
        let greeting = "Hello"
        print(greeting)
        ```

        Then run the application.
        """

        // When
        let blocks = ChatbotMarkdownParser.blocks(in: markdown)

        // Then
        #expect(
            blocks == [
                .text("Use this implementation:"),
                .code(language: "swift", content: "let greeting = \"Hello\"\nprint(greeting)"),
                .text("Then run the application."),
            ]
        )
    }

    @Test("An unfinished streamed fence remains readable as code")
    func parsesUnfinishedCodeBlock() {
        // Given
        let markdown = """
        ```json
        { "ready": true }
        """

        // When
        let blocks = ChatbotMarkdownParser.blocks(in: markdown)

        // Then
        #expect(blocks == [.code(language: "json", content: "{ \"ready\": true }")])
    }

    @Test("Inline Markdown includes emphasis, code, and the underline extension")
    func formatsInlineMarkdown() {
        // Given
        let markdown = "**Bold**, _italic_, `code`, and <u>underlined</u>."

        // When
        let attributed = ChatbotMarkdownParser.attributedString(from: markdown)
        let intents = attributed.runs.compactMap(\.inlinePresentationIntent)

        // Then
        #expect(String(attributed.characters) == "Bold, italic, code, and underlined.")
        #expect(intents.contains { $0.contains(.stronglyEmphasized) })
        #expect(intents.contains { $0.contains(.emphasized) })
        #expect(intents.contains { $0.contains(.code) })
        #expect(attributed.runs.contains { $0.underlineStyle == .single })
    }

    @Test("Accessible text omits Markdown control characters")
    func createsPlainAccessibleText() {
        // Given
        let markdown = """
        **Important** and <u>underlined</u>.

        ```swift
        print("Hello")
        ```
        """

        // When
        let plainText = ChatbotMarkdownParser.plainText(from: markdown)

        // Then
        #expect(plainText == "Important and underlined.\nprint(\"Hello\")")
    }

    @Test("Plain URLs, email addresses, and phone numbers become system links")
    func detectsContactLinks() {
        // Given
        let markdown = "See https://example.com/faqs, email help@example.com, or call +34 912 34 56 78."

        // When
        let attributed = ChatbotMarkdownParser.attributedString(from: markdown)
        let links = attributed.runs.compactMap { $0.link?.absoluteString }

        // Then
        #expect(links.contains("https://example.com/faqs"))
        #expect(links.contains("mailto:help@example.com"))
        #expect(links.contains("tel:+34%20912%2034%2056%2078"))
    }

    @Test("Explicit Markdown links keep their destination")
    func preservesExplicitMarkdownLinks() {
        // Given
        let markdown = "[help@example.com](mailto:priority@example.com)"

        // When
        let attributed = ChatbotMarkdownParser.attributedString(from: markdown)

        // Then
        #expect(attributed.runs.compactMap(\.link) == [URL(string: "mailto:priority@example.com")!])
    }

    @Test("Contact details inside inline code are not interactive")
    func doesNotLinkInlineCode() {
        // Given
        let markdown = "Use `help@example.com` as the fixture value."

        // When
        let attributed = ChatbotMarkdownParser.attributedString(from: markdown)

        // Then
        #expect(attributed.runs.allSatisfy { $0.link == nil })
    }
}
