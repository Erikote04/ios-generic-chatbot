//
//  ContentView.swift
//  ios-chatbot-app
//
//  Created by Erik Sebastian de Erice Jerez on 19/08/2026.
//

import GenericChatbot
import SwiftUI

struct ContentView: View {
    private let configuration = ChatbotConfiguration(
        title: "GenericChatbot Guide",
        instructions: "Answer clearly using only the supplied GenericChatbot documentation.",
        answerPolicy: .groundedOnly,
        retrievalLimit: 1,
        strings: ChatbotStrings(
            emptyTitle: "Ask about GenericChatbot",
            emptyMessage: "Learn how to integrate and customize the library in an iOS app.",
            composerPlaceholder: "Ask about the library"
        )
    )

    private let provider = FoundationModelsChatProvider()
    private let knowledgeSource = SampleKnowledgeSource()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                features
                suggestedQuestions
                launcher
            }
            .frame(maxWidth: 560)
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
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

    private var launcher: some View {
        VStack(spacing: 10) {
            ChatbotLauncher(
                accessibilityLabel: "Open the GenericChatbot guide",
                tint: .indigo
            ) { close in
                ChatbotView(
                    configuration: configuration,
                    provider: provider,
                    knowledgeSource: knowledgeSource,
                    theme: ChatbotTheme(
                        accentColor: .indigo,
                        userBubbleColor: .indigo
                    ),
                    close: close
                )
            }

            Text("Open assistant")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
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

private struct SampleKnowledgeSource: ChatKnowledgeSource {
    func knowledge(for _: String, limit: Int) async throws -> [ChatKnowledgeItem] {
        guard limit > 0 else { return [] }

        return [
            ChatKnowledgeItem(
                id: "generic-chatbot-overview",
                title: "GenericChatbot Documentation",
                content: """
                GenericChatbot is a reusable SwiftUI chatbot for iOS 26 and later. It uses a configurable ChatModelProvider, and FoundationModelsChatProvider connects it to Apple's on-device model. Apps provide their own relevant content through ChatKnowledgeSource; that context grounds answers but does not retrain the model. Developers can customize instructions, answer policy, conversation lifecycle, localized strings, theme, persistence, and sanitized error reporting. The library handles model availability, generation, retrieval, persistence, cancellation, and connectivity failures through normalized user-facing errors.
                """,
                url: URL(
                    string: "https://erikote04.github.io/ios-generic-chatbot/documentation/genericchatbot/"
                )
            )
        ]
    }
}

#Preview {
    ContentView()
}
