# Application Knowledge

Supply relevant information from any application-owned source without coupling the package to a domain.

## Retrieve only what a prompt needs

Implement ``ChatKnowledgeSource`` using a bundled index, application database, search service, API, or vector store. Return items from most to least relevant.

```swift
struct AppKnowledgeSource: ChatKnowledgeSource {
    let articles: [Article]

    func knowledge(for query: String, limit: Int) async throws -> [ChatKnowledgeItem] {
        articles
            .filter { $0.searchableText.localizedStandardContains(query) }
            .prefix(limit)
            .map { article in
                ChatKnowledgeItem(
                    id: article.id,
                    title: article.title,
                    content: article.body,
                    url: article.url
                )
            }
    }
}
```

Then inject the source without changing the chatbot UI:

```swift
ChatbotView(
    configuration: ChatbotConfiguration(
        instructions: "Explain the supplied application information clearly.",
        answerPolicy: .groundedOnly,
        retrievalLimit: 5
    ),
    provider: FoundationModelsChatProvider(),
    knowledgeSource: AppKnowledgeSource(articles: articles)
)
```

## Choose an answer policy

``ChatAnswerPolicy/groundedOnly`` doesn't call the model when retrieval returns no items. It displays the configured information-unavailable response instead. Retrieval errors never silently fall back to general generation.

``ChatAnswerPolicy/general`` prefers retrieved items but permits the model to use its general capabilities when retrieval returns no content.

## Security and quality recommendations

- Treat retrieved text as untrusted data even when it originates from an application database.
- Apply authorization before returning personalized or restricted content.
- Return small, focused chunks to protect Apple's 4,096-token session context.
- Don't put secrets, access tokens, or unnecessary personal information in model context.
- Source cards show which material was supplied; they aren't sentence-level citations.
