import Foundation
import SwiftUI

/// Renders model-authored Markdown while keeping code blocks readable and copyable.
@MainActor
struct ChatbotMarkdownMessage: View {
    let content: String
    let font: Font

    var body: some View {
        let blocks = ChatbotMarkdownParser.blocks(in: content)

        VStack(alignment: .leading, spacing: 12) {
            ForEach(blocks.indices, id: \.self) { index in
                switch blocks[index] {
                case .text(let markdown):
                    Text(ChatbotMarkdownParser.attributedString(from: markdown))
                        .font(font)

                case .code(let language, let code):
                    codeBlock(language: language, code: code)
                }
            }
        }
        .textSelection(.enabled)
    }

    private func codeBlock(language: String?, code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let language {
                Text(language)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

            ScrollView(.horizontal) {
                Text(code)
                    .font(.system(.callout, design: .monospaced))
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.secondary.opacity(0.12), in: .rect(cornerRadius: 12))
    }
}

enum ChatbotMarkdownBlock: Equatable, Sendable {
    case text(String)
    case code(language: String?, content: String)
}

@MainActor
enum ChatbotMarkdownParser {
    private static let contactDetector = try? NSDataDetector(
        types: NSTextCheckingResult.CheckingType.link.rawValue
            | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
    )

    static func blocks(in markdown: String) -> [ChatbotMarkdownBlock] {
        let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var blocks: [ChatbotMarkdownBlock] = []
        var textLines: [String] = []
        var codeLines: [String] = []
        var openFence: MarkdownFence?

        for line in lines {
            if let fence = openFence {
                if fence.isClosing(line) {
                    blocks.append(.code(language: fence.language, content: codeLines.joined(separator: "\n")))
                    codeLines.removeAll(keepingCapacity: true)
                    openFence = nil
                } else {
                    codeLines.append(line)
                }
            } else if let fence = MarkdownFence(openingLine: line) {
                appendTextBlock(textLines, to: &blocks)
                textLines.removeAll(keepingCapacity: true)
                openFence = fence
            } else {
                textLines.append(line)
            }
        }

        if let fence = openFence {
            blocks.append(.code(language: fence.language, content: codeLines.joined(separator: "\n")))
        } else {
            appendTextBlock(textLines, to: &blocks)
        }

        return blocks.isEmpty ? [.text("")] : blocks
    }

    static func attributedString(from markdown: String) -> AttributedString {
        let segments = underlineSegments(in: markdown)
        var result = AttributedString()

        for segment in segments {
            var attributed = parsedInlineMarkdown(segment.content)
            if segment.isUnderlined, !attributed.characters.isEmpty {
                attributed[attributed.startIndex..<attributed.endIndex].underlineStyle = .single
            }
            result.append(attributed)
        }

        return result
    }

    static func plainText(from markdown: String) -> String {
        blocks(in: markdown)
            .map { block in
                switch block {
                case .text(let markdown):
                    String(attributedString(from: markdown).characters)
                case .code(_, let content):
                    content
                }
            }
            .joined(separator: "\n")
    }

    private static func appendTextBlock(
        _ lines: [String],
        to blocks: inout [ChatbotMarkdownBlock]
    ) {
        let content = lines
            .drop(while: { $0.trimmingCharacters(in: .whitespaces).isEmpty })
            .reversed()
            .drop(while: { $0.trimmingCharacters(in: .whitespaces).isEmpty })
            .reversed()
            .joined(separator: "\n")

        guard !content.isEmpty else { return }
        blocks.append(.text(content))
    }

    private static func parsedInlineMarkdown(_ markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )

        let attributed = (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)
        return applyingAutomaticLinks(to: attributed)
    }

    private static func applyingAutomaticLinks(to attributed: AttributedString) -> AttributedString {
        guard let contactDetector else { return attributed }

        var result = attributed
        let text = String(result.characters)
        let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)

        for match in contactDetector.matches(in: text, range: fullRange) {
            guard
                let textRange = Range(match.range, in: text),
                let lowerBound = AttributedString.Index(textRange.lowerBound, within: result),
                let upperBound = AttributedString.Index(textRange.upperBound, within: result)
            else { continue }

            let attributedRange = lowerBound..<upperBound
            guard canApplyAutomaticLink(to: attributedRange, in: result) else { continue }

            if let destination = linkDestination(for: match) {
                result[attributedRange].link = destination
            }
        }

        return result
    }

    private static func canApplyAutomaticLink(
        to range: Range<AttributedString.Index>,
        in attributed: AttributedString
    ) -> Bool {
        attributed[range].runs.allSatisfy { run in
            run.link == nil && run.inlinePresentationIntent?.contains(.code) != true
        }
    }

    private static func linkDestination(for match: NSTextCheckingResult) -> URL? {
        if let url = match.url {
            switch url.scheme?.lowercased() {
            case "http", "https", "mailto":
                return url
            default:
                return nil
            }
        }

        guard let phoneNumber = match.phoneNumber else { return nil }
        var components = URLComponents()
        components.scheme = "tel"
        components.path = phoneNumber
        return components.url
    }

    private static func underlineSegments(in markdown: String) -> [UnderlineSegment] {
        var segments: [UnderlineSegment] = []
        var remaining = markdown[...]

        while let openingRange = remaining.range(of: "<u>", options: .caseInsensitive) {
            let prefix = remaining[..<openingRange.lowerBound]
            if !prefix.isEmpty {
                segments.append(UnderlineSegment(content: String(prefix), isUnderlined: false))
            }

            let afterOpening = remaining[openingRange.upperBound...]
            guard let closingRange = afterOpening.range(of: "</u>", options: .caseInsensitive) else {
                segments.append(UnderlineSegment(content: String(remaining[openingRange.lowerBound...]), isUnderlined: false))
                return segments
            }

            segments.append(
                UnderlineSegment(
                    content: String(afterOpening[..<closingRange.lowerBound]),
                    isUnderlined: true
                )
            )
            remaining = afterOpening[closingRange.upperBound...]
        }

        if !remaining.isEmpty || segments.isEmpty {
            segments.append(UnderlineSegment(content: String(remaining), isUnderlined: false))
        }

        return segments
    }
}

private struct MarkdownFence {
    let character: Character
    let length: Int
    let language: String?

    init?(openingLine: String) {
        let trimmed = openingLine.drop(while: { $0 == " " || $0 == "\t" })
        guard let first = trimmed.first, first == "`" || first == "~" else { return nil }

        let count = trimmed.prefix(while: { $0 == first }).count
        guard count >= 3 else { return nil }

        character = first
        length = count

        let info = trimmed.dropFirst(count).trimmingCharacters(in: .whitespaces)
        language = info.isEmpty ? nil : info
    }

    func isClosing(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= length else { return false }
        return trimmed.allSatisfy { $0 == character }
    }
}

private struct UnderlineSegment {
    let content: String
    let isUnderlined: Bool
}
