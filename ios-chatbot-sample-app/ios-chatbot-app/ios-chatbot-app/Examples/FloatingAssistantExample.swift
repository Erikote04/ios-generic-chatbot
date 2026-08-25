import SwiftUI

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

#Preview("Floating assistant") {
    FloatingAssistantExample()
}
