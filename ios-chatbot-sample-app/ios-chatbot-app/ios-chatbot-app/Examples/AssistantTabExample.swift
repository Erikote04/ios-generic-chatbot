import SwiftUI

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

#Preview("Assistant tab") {
    AssistantTabExample()
}
