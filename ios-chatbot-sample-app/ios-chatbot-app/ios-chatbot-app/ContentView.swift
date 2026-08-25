//
//  ContentView.swift
//  ios-chatbot-app
//
//  Created by Erik Sebastian de Erice Jerez on 19/08/2026.
//

import Foundation
import GenericChatbot
import SwiftUI

// MARK: main content

struct ContentView: View {
    var body: some View {
        FloatingAssistantExample()
    }
}

// MARK: FAB assistant

struct FloatingAssistantExample: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            landingContent

            SampleChatbotLauncher()
                .padding(.trailing, 24)
        }
    }

    private var landingContent: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                features
                suggestedQuestions
            }
            .frame(maxWidth: 560)
            .padding(24)
            .padding(.bottom, 88)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 40))
                .foregroundStyle(.indigo)
                .accessibilityHidden(true)

            Text("GenericChatbot")
                .font(.largeTitle.bold())

            Text("A reusable, app-aware assistant powered by Apple Foundation Models.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var features: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 18) {
                feature(
                    "On-device intelligence",
                    description: "Uses Apple Foundation Models when available.",
                    symbol: "apple.intelligence"
                )
                feature(
                    "App-owned knowledge",
                    description: "Grounds answers in context supplied by your app.",
                    symbol: "books.vertical.fill"
                )
                feature(
                    "Reusable UI",
                    description: "Configure behavior, content, strings, and appearance.",
                    symbol: "slider.horizontal.3"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var suggestedQuestions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try asking")
                .font(.headline)

            Text("“What is GenericChatbot?”")
            Text("“How does app knowledge work?”")
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func feature(
        _ title: String,
        description: String,
        symbol: String
    ) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(.indigo)
                .frame(width: 28)
        }
    }
}

// MARK: TAB assistant

struct AssistantTabExample: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                SampleTabContent(
                    title: "Home",
                    message: "Your app's primary content can live here.",
                    systemImage: "house.fill"
                )
            }

            Tab("Search", systemImage: "magnifyingglass") {
                SampleTabContent(
                    title: "Search",
                    message: "Help people find content across the app.",
                    systemImage: "magnifyingglass"
                )
            }

            Tab("AI Assistant", systemImage: "sparkles") {
                SampleChatbotView()
            }

            Tab("Notifications", systemImage: "bell.fill") {
                SampleTabContent(
                    title: "Notifications",
                    message: "Important updates appear here.",
                    systemImage: "bell.fill"
                )
            }

            Tab("Profile", systemImage: "person.crop.circle.fill") {
                SampleTabContent(
                    title: "Profile",
                    message: "Account details and preferences live here.",
                    systemImage: "person.crop.circle.fill"
                )
            }
        }
        .tint(.indigo)
    }
}

// MARK: TAB + FAB assistant

struct TabsWithFloatingAssistantExample: View {
    @State private var selection = Destination.home

    var body: some View {
        ZStack(alignment: .bottom) {
            SampleTabContent(
                title: selection.title,
                message: "Sample content for the \(selection.title.lowercased()) tab.",
                systemImage: selection.systemImage
            )

            bottomBar
                .padding(.bottom)
        }
        .ignoresSafeArea()
    }

    private var bottomBar: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(Destination.allCases) { destination in
                        Button {
                            selection = destination
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: destination.systemImage)
                                    .font(.title3)

                                Text(destination.title)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .foregroundStyle(selection == destination ? .indigo : .primary)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                selection == destination
                                    ? Color.indigo.opacity(0.14)
                                    : Color.clear,
                                in: .capsule
                            )
                            .contentShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selection == destination ? .isSelected : [])
                    }
                }
                .padding(5)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular, in: .capsule)

                SampleChatbotLauncher()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private enum Destination: String, CaseIterable, Identifiable {
        case home
        case discovery
        case activity
        case profile

        var id: Self { self }

        var title: String {
            switch self {
            case .home: "Home"
            case .discovery: "Discovery"
            case .activity: "Activity"
            case .profile: "Profile"
            }
        }

        var systemImage: String {
            switch self {
            case .home: "house.fill"
            case .discovery: "safari.fill"
            case .activity: "chart.bar.fill"
            case .profile: "person.crop.circle.fill"
            }
        }
    }
}

// MARK: chatbot launcher

private struct SampleChatbotLauncher: View {
    var body: some View {
        ChatbotLauncher(
            accessibilityLabel: "Open the GenericChatbot guide",
            tint: .indigo
        ) { close in
            SampleChatbotView(close: close)
        }
    }
}

// MARK: chatbot view

private struct SampleChatbotView: View {
    var close: (() -> Void)?

    init(close: (() -> Void)? = nil) {
        self.close = close
    }

    var body: some View {
        ChatbotView(
            configuration: SampleChatbot.configuration,
            provider: FoundationModelsChatProvider(),
            knowledgeSource: SampleKnowledgeSource(),
            theme: SampleChatbot.theme,
            close: close
        )
    }
}

// MARK: tabs sample content

private struct SampleTabContent: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: Text(message)
            )
            .navigationTitle(title)
        }
    }
}

// MARK: chatbot configuration

@MainActor
private enum SampleChatbot {
    static let configuration = ChatbotConfiguration(
        title: "GenericChatbot Guide",
        instructions: "Answer questions about GenericChatbot clearly from the supplied documentation. Do not invent APIs or behavior. When the documentation does not contain an answer, say so briefly and mention the closest documented capability when useful.",
        answerPolicy: .groundedOnly,
        retrievalLimit: 3,
        strings: ChatbotStrings(
            emptyTitle: "Ask about GenericChatbot",
            emptyMessage: "Learn how to integrate and customize the library in an iOS app.",
            composerPlaceholder: "Ask about the library"
        )
    )

    static let theme = ChatbotTheme(
        accentColor: .indigo,
        userBubbleColor: .indigo
    )
}

// MARK: chatbot knowledge

private struct SampleKnowledgeSource: ChatKnowledgeSource {
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

private nonisolated enum SampleKnowledgeCatalog {
    private static let maximumChunkLength = 2_400

    static func sections() throws -> [Section] {
        try articles.enumerated().flatMap { articleIndex, article in
            let markdown = try load(article)
            let chunks = chunk(markdown)
            return chunks.enumerated().map { index, chunk in
                return Section(
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

// MARK: previews

#Preview("Floating assistant") {
    FloatingAssistantExample()
}

#Preview("Assistant tab") {
    AssistantTabExample()
}

#Preview("Tabs with floating assistant") {
    TabsWithFloatingAssistantExample()
}
