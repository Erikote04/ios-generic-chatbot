# Knowledge, Errors, and Privacy

Read this reference when the chatbot uses application information, remote services, persistence, diagnostics, or personalized data.

## Application knowledge

Implement `ChatKnowledgeSource` as an adapter over the app's authorized data path: bundled content, repository, database, search service, API, or vector store. Return small, relevant `ChatKnowledgeItem` values ordered by usefulness.

Before implementation, establish which path the developer wants. If it is not already specified, ask whether knowledge will come from:

- A property or value owned by an existing struct, class, actor, view model, service, or repository.
- A bundled project file such as Markdown, JSON, plain text, or PDF.
- A local database or persisted application model.
- A URL, authenticated API, CMS, search service, or vector store.
- A combination of sources, or no custom knowledge when `.general` model knowledge is intentional.

Adapt the chosen path instead of inventing another source. Properties and domain models should be converted into focused text without exposing the domain type to GenericChatbot. Bundled files need an appropriate loader and parser. Remote sources need the app's existing client, authentication, caching, and connectivity conventions.

The model receives `ChatKnowledgeItem.content`. Its `url` is optional source attribution for the interface; GenericChatbot does not fetch that URL. When the developer supplies a URL as the knowledge origin, the `ChatKnowledgeSource` must retrieve and extract the relevant text before returning the item.

Apply authentication and authorization before returning content. Treat retrieved text as untrusted data, even when stored by the app. Do not embed secrets, tokens, or unnecessary personal information.

Instructions and retrieved context customize behavior; they do not retrain Apple's system model. A separately trained Apple adapter remains an application-owned lifecycle.

## Error responsibilities

The library normalizes:

- Device ineligibility, disabled Apple Intelligence, and model assets not ready.
- Context-window, asset, guardrail, guide, locale, decoding, rate-limit, concurrency, refusal, and tool-call failures.
- Offline, connection loss, timeout, DNS, server, authentication, and invalid-response failures.
- Retrieval, persistence, provider, cancellation, and unknown failures.

Let the library present normalized recovery actions. Map errors inside custom remote providers or adapters to `ChatbotError` when classification is known. Do not show raw server or SDK diagnostics to users.

Do not gate `FoundationModelsChatProvider` on network reachability. Check connectivity only for dependencies that actually require it.

## Diagnostics

Use `ChatbotErrorReporter` for sanitized operational metadata. Never log:

- User prompts or generated responses.
- Retrieved private content.
- Credentials, access tokens, cookies, or headers.
- Full persistence payloads.
- Unredacted server bodies.

Follow the host app's consent, retention, redaction, and analytics conventions.

## Persistence

Use the app's existing storage abstraction behind `ChatHistoryStore`. Preserve account scoping and data-protection rules. Delete or invalidate conversations when the owning account, tenant, or authorization context changes.
