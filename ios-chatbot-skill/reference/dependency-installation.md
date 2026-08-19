# Dependency Installation

Use this reference during the mandatory first step of every integration.

## Detect the dependency

Search both dependency declarations and target linkage for either identifier:

- Product: `GenericChatbot`
- Repository: `https://github.com/Erikote04/ios-generic-chatbot.git`

Also search source imports, but do not treat an import as proof that the intended target links the product. Identify the target that will own the chatbot before deciding the dependency is present.

Check the app's deployment target before adding the package. GenericChatbot requires iOS 26, Xcode 26, and Swift 6.2.

## Preserve the project's source of truth

Use the dependency mechanism already used by the project:

- **SwiftPM manifest:** Update `Package.swift` dependencies and the owning target's dependencies.
- **Plain Xcode project:** Add the remote Swift package reference and `GenericChatbot` product dependency to the owning target, following existing `project.pbxproj` package entries. Make a focused edit and validate the project afterward.
- **Tuist:** Update `Package.swift`, `Project.swift`, or the repository's dependency manifest, then regenerate with the documented Tuist workflow. Do not hand-edit generated `.xcodeproj` files.
- **XcodeGen:** Update `project.yml` or the repository's included specification, then regenerate. Do not hand-edit generated projects.
- **Workspace with multiple projects:** Link the product only to the project and target that compile the integration source.
- **Modular package graph:** Add the product to the feature or composition target that imports it, not every module.

Follow an existing package version convention. For a new SwiftPM declaration when no convention exists, use:

```swift
.package(
    url: "https://github.com/Erikote04/ios-generic-chatbot.git",
    from: "1.0.0"
)
```

Then add the product to the target:

```swift
.product(name: "GenericChatbot", package: "ios-generic-chatbot")
```

## Resolve and verify

Use the repository's normal resolve or generation command. Confirm:

1. Resolution succeeds without changing unrelated package pins.
2. The intended target contains the `GenericChatbot` product dependency.
3. A source file in that target can `import GenericChatbot`.
4. No generated file was edited instead of its generator input.

If adding the package would require raising a deployment target below iOS 26, stop and request explicit approval rather than changing platform support implicitly.
