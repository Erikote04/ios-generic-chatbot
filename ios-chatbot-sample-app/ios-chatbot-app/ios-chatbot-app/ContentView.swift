//
//  ContentView.swift
//  ios-chatbot-app
//
//  Created by Erik Sebastian de Erice Jerez on 19/08/2026.
//

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
        instructions: "Answer clearly using only the supplied GenericChatbot documentation.",
        answerPolicy: .groundedOnly,
        retrievalLimit: 1,
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
