import Foundation
import GenericChatbot

struct SampleKnowledgeSource: ChatKnowledgeSource {
    func knowledge(for query: String, limit: Int) async throws -> [ChatKnowledgeItem] {
        guard limit > 0 else { return [] }

        let sections = try SampleKnowledgeCatalog.sections()
        let scoredSections = sections.map { section in
            ScoredSection(
                section: section,
                score: section.relevance(to: query)
            )
        }
        let relevantSections = scoredSections.filter { $0.score > 0 }
        let sortedSections = relevantSections.sorted { lhs, rhs in
            lhs.score == rhs.score
                ? lhs.section.order < rhs.section.order
                : lhs.score > rhs.score
        }

        return sortedSections
            .prefix(limit)
            .map { result in
                ChatKnowledgeItem(
                    id: result.section.id,
                    title: result.section.title,
                    content: result.section.content,
                    url: URL(
                        string: "https://erikote04.github.io/ios-generic-chatbot/documentation/genericchatbot/"
                    )
                )
            }
    }

    private struct ScoredSection {
        let section: SampleKnowledgeCatalog.Section
        let score: Int
    }
}
