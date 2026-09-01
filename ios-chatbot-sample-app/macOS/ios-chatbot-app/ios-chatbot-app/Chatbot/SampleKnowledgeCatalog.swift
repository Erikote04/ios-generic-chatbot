import Foundation
import GenericChatbot

nonisolated enum SampleKnowledgeCatalog {
    private static let maximumChunkLength = 2_400

    static func sections() throws -> [Section] {
        try articles.enumerated().flatMap { articleIndex, article in
            let markdown = try load(article)
            let chunks = chunk(markdown)
            return chunks.enumerated().map { index, chunk in
                Section(
                    id: "generic-chatbot-\(slug(article.title))-\(index)",
                    title: chunks.count == 1
                        ? article.title
                        : "\(article.title) · \(index + 1)",
                    topic: article.title,
                    content: chunk,
                    aliases: article.aliases,
                    order: articleIndex * 100 + index
                )
            }
        }
    }

    private static func load(_ article: Article) throws -> String {
        let url = Bundle.main.url(
            forResource: article.resource,
            withExtension: "md",
            subdirectory: "Knowledge"
        ) ?? Bundle.main.url(forResource: article.resource, withExtension: "md")

        guard let url else {
            throw ChatbotError.retrievalFailed
        }

        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw ChatbotError.retrievalFailed
        }
    }

    private static func chunk(_ text: String) -> [String] {
        let paragraphs = text.components(separatedBy: "\n\n")
        var chunks: [String] = []
        var current = ""

        for paragraph in paragraphs {
            let candidate = current.isEmpty ? paragraph : "\(current)\n\n\(paragraph)"
            if candidate.count <= maximumChunkLength {
                current = candidate
                continue
            }

            if !current.isEmpty {
                chunks.append(current)
                current = ""
            }

            if paragraph.count <= maximumChunkLength {
                current = paragraph
            } else {
                var remainder = paragraph[...]
                while remainder.count > maximumChunkLength {
                    let end = remainder.index(
                        remainder.startIndex,
                        offsetBy: maximumChunkLength
                    )
                    chunks.append(String(remainder[..<end]))
                    remainder = remainder[end...]
                }
                current = String(remainder)
            }
        }

        if !current.isEmpty {
            chunks.append(current)
        }

        return chunks
    }

    private static func slug(_ value: String) -> String {
        normalizedTerms(in: value).joined(separator: "-")
    }

    fileprivate static func normalizedTerms(in value: String) -> [String] {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { term in
                term.count > 1 && !stopWords.contains(term)
            }
    }

    private static let stopWords: Set<String> = [
        "about", "and", "are", "can", "como", "con", "cual", "cuando", "de", "del",
        "does", "el", "en", "es", "esta", "for", "from", "how", "la", "las", "los",
        "para", "por", "que", "the", "this", "una", "use", "using", "what", "when",
        "where", "which", "with", "y"
    ]

    private static let articles: [Article] = [
        Article(
            resource: "GenericChatbot",
            title: "GenericChatbot Overview",
            aliases: ["biblioteca", "genericchatbot", "library", "overview", "paquete", "package"]
        ),
        Article(
            resource: "GettingStarted",
            title: "Getting Started",
            aliases: ["add", "anadir", "comenzar", "dependency", "dependencia", "install", "instalacion", "instalar", "integrar", "integration", "spm"]
        ),
        Article(
            resource: "ApplicationKnowledge",
            title: "Application Knowledge",
            aliases: ["archivo", "archivos", "conocimiento", "contexto", "datos", "entrenar", "feed", "file", "fuente", "knowledge", "rag", "retrieval", "url"]
        ),
        Article(
            resource: "ConversationPersistence",
            title: "Conversation Persistence",
            aliases: ["conversation", "conversacion", "conversaciones", "guardar", "historial", "history", "persistencia", "resume", "storage"]
        ),
        Article(
            resource: "CustomizingPresentation",
            title: "Customizing Presentation",
            aliases: ["boton", "cambiar", "color", "colores", "custom", "estilo", "fab", "glass", "interfaz", "personalizar", "presentacion", "style", "tema", "theme", "ui", "view"]
        ),
        Article(
            resource: "ErrorsAndRecovery",
            title: "Errors and Recovery",
            aliases: ["conexion", "device", "dispositivo", "error", "errores", "fallo", "failure", "offline", "recovery", "retry"]
        ),
        Article(
            resource: "LanguagesAndLocales",
            title: "Languages and Locales",
            aliases: ["english", "espanol", "idioma", "idiomas", "ingles", "language", "locale", "localizacion", "spanish"]
        ),
        Article(
            resource: "ModelProviders",
            title: "Model Providers",
            aliases: ["adapter", "apple", "foundation", "model", "modelo", "modelos", "provider", "proveedor", "proveedores", "remote", "remoto"]
        ),
        Article(
            resource: "CoreKnowledgeAndConversationAPI",
            title: "Core Knowledge and Conversation API",
            aliases: ["answerpolicy", "chatconversation", "chathistorystore", "chatknowledgeitem", "chatknowledgesource", "chatmessage"]
        ),
        Article(
            resource: "ModelExecutionAPI",
            title: "Model Execution API",
            aliases: ["availability", "chatmodelprovider", "chatmodelsession", "chatrequest", "chatresponseevent", "chatsessionconfiguration", "chatsource"]
        ),
        Article(
            resource: "ConfigurationAndErrorsAPI",
            title: "Configuration and Errors API",
            aliases: ["chatbotconfiguration", "chatboterror", "chatbotfailure", "diagnostic", "reporter"]
        ),
        Article(
            resource: "PresentationAndLanguageAPI",
            title: "Presentation and Language API",
            aliases: ["chatbotlauncher", "header", "language", "presentation", "recovery", "responselanguage"]
        ),
        Article(
            resource: "StringsAndStyleAPI",
            title: "Strings, Style, and Theme API",
            aliases: ["chatbotstrings", "chatbotstyle", "chatbottheme", "localization", "style", "theme"]
        ),
        Article(
            resource: "ViewsAPI",
            title: "Views API",
            aliases: ["chatbotview", "defaultchatbotstyle", "launcher", "swiftui", "view"]
        ),
        Article(
            resource: "BuiltInImplementationsAPI",
            title: "Built-in Implementations API",
            aliases: ["emptychatknowledgesource", "foundationmodelschatprovider", "inmemorychathistorystore", "noopchatboterrorreporter"]
        )
    ]

    private struct Article {
        let resource: String
        let title: String
        let aliases: Set<String>
    }

    struct Section {
        let id: String
        let title: String
        let topic: String
        let content: String
        let aliases: Set<String>
        let order: Int

        func relevance(to query: String) -> Int {
            let queryTerms = Set(SampleKnowledgeCatalog.normalizedTerms(in: query))
            guard !queryTerms.isEmpty else { return 0 }

            let titleTerms = Set(SampleKnowledgeCatalog.normalizedTerms(in: topic))
            let contentTerms = Set(SampleKnowledgeCatalog.normalizedTerms(in: content))
            let titleMatches = queryTerms.intersection(titleTerms).count
            let contentMatches = queryTerms.intersection(contentTerms).count
            let aliasMatches = queryTerms.intersection(aliases).count

            return titleMatches * 8 + aliasMatches * 6 + contentMatches
        }
    }
}
