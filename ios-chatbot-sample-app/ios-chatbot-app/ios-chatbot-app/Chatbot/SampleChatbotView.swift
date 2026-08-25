import GenericChatbot
import SwiftUI

struct SampleChatbotLauncher: View {
    var body: some View {
        ChatbotLauncher(
            accessibilityLabel: "Open the GenericChatbot guide",
            tint: .indigo
        ) { close in
            SampleChatbotView(close: close)
        }
    }
}

struct SampleChatbotView: View {
    let close: (() -> Void)?

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
