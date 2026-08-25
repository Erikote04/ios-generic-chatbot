import SwiftUI

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

#Preview("Tabs with floating assistant") {
    TabsWithFloatingAssistantExample()
}
