// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GenericChatbot",
    platforms: [
        .iOS(.v26),
    ],
    products: [
        .library(
            name: "GenericChatbot",
            targets: ["GenericChatbot"]
        ),
    ],
    targets: [
        .target(
            name: "GenericChatbot"
        ),
        .testTarget(
            name: "GenericChatbotTests",
            dependencies: ["GenericChatbot"]
        ),
    ]
)
