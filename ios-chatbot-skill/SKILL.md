---
name: ios-chatbot-skill
description: Integrate the GenericChatbot Swift package into existing iOS applications without changing their architecture. Use when adding, wiring, customizing, troubleshooting, or testing the reusable chatbot in SwiftUI, UIKit, mixed, MVVM, MVC, coordinator, Clean Architecture, VIPER, reducer-based, or modular iOS projects. Always verify and install the package dependency before implementing the feature.
---

# iOS GenericChatbot Integration

Integrate GenericChatbot at the host application's existing composition, navigation, state-management, and data boundaries. Preserve the app's architecture and conventions.

## Installation guide

GenericChatbot requires iOS 26 or later, Xcode 26 or later, and Swift 6.2 or later. Before changing application code, verify that the app target meets these requirements and does not already link the `GenericChatbot` product.

### Install with Xcode

Use this approach for an app managed by an Xcode project or workspace:

1. Open the project or workspace in Xcode.
2. Select **File > Add Package Dependencies**.
3. Enter `https://github.com/Erikote04/ios-generic-chatbot.git`.
4. Select **Up to Next Major Version** starting at `1.0.0`, unless the project has a different package-version policy.
5. Add the `GenericChatbot` product only to the target that owns the integration.
6. Resolve packages and build that target to verify the dependency.

### Install with Package.swift

Add the package to `dependencies`:

```swift
.package(
    url: "https://github.com/Erikote04/ios-generic-chatbot.git",
    from: "1.0.0"
)
```

Then link the product from the integrating target:

```swift
.product(
    name: "GenericChatbot",
    package: "ios-generic-chatbot"
)
```

Resolve dependencies, build the target, and import the module only where it is used:

```swift
import GenericChatbot
```

For Tuist, XcodeGen, modular workspaces, and existing dependency conventions, update the project's source of truth rather than generated files. Follow the complete decision guide in [dependency-installation.md](reference/dependency-installation.md).

## Required workflow

### 1. Complete the dependency gate first

Perform this step before architecture analysis or implementation.

1. Inspect project and dependency declarations for the `GenericChatbot` product or `https://github.com/Erikote04/ios-generic-chatbot.git`.
2. Inspect relevant source targets for `import GenericChatbot`.
3. Confirm the intended target links the product; an import in an unrelated target is insufficient.
4. If the dependency is missing, add it through the project's existing source of truth before writing feature code. Preserve the current dependency-management style and version policy. See [dependency-installation.md](reference/dependency-installation.md).
5. Resolve dependencies and confirm the product is visible to the intended target.

The library requires iOS 26, Xcode 26, and Swift 6.2. If the target is below iOS 26, do not raise its deployment target without explicit approval. Explain the incompatibility and request direction.

### 2. Discover the integration boundaries

After the dependency gate passes, inspect enough of the app to identify:

- UI technology and entry point: SwiftUI, UIKit, or mixed.
- Composition root and dependency injection mechanism.
- Navigation owner: sheet, navigation stack, coordinator, router, presenter, or hosting controller.
- State and concurrency conventions.
- Feature-module ownership and target membership.
- Existing persistence, networking, localization, analytics, and accessibility conventions.

Read [architecture-adaptation.md](reference/architecture-adaptation.md) for the matching patterns. Do not migrate the app to another architecture.

### 3. Design the smallest architecture-native seam

- Construct model, knowledge, history, and reporter dependencies at the app's existing composition boundary.
- Keep `ChatbotView` responsible for chat interaction state; do not duplicate its orchestration in a host view model, presenter, or reducer.
- Adapt application data behind `ChatKnowledgeSource` instead of coupling the component to repositories or domain entities.
- Use `ChatHistoryStore` and `ChatbotErrorReporter` adapters only when the host needs persistence or diagnostics.
- Keep Apple Foundation Models on-device behavior separate from remote-provider connectivity requirements.

Read [generic-chatbot-api.md](reference/generic-chatbot-api.md) before choosing APIs. Read [knowledge-errors-and-privacy.md](reference/knowledge-errors-and-privacy.md) when adding application content, remote dependencies, persistence, or telemetry.

### 4. Implement within existing conventions

1. Add `import GenericChatbot` only where needed.
2. Add a feature wrapper or factory when that matches the architecture; avoid global singletons.
3. Configure domain-neutral title, instructions, answer policy, lifecycle, strings, and theme.
4. Present `ChatbotLauncher` in SwiftUI, or bridge `ChatbotView`/the launcher through `UIHostingController` in UIKit.
5. Preserve the host's navigation ownership, localization, design tokens, and accessibility behavior.
6. Handle model availability and dependency failures through the library's normalized error model; do not preemptively disable Apple's on-device provider merely because the network is offline.

### 5. Verify the integration

Read and follow [verification.md](reference/verification.md).

- Build the affected scheme and target using the project's existing toolchain.
- Run relevant existing tests and add focused tests for new adapters or composition logic.
- Exercise supported and unavailable model states, cancellation, retries, and remote connectivity failures when applicable.
- Check VoiceOver labels, Dynamic Type, keyboard behavior, and presentation dismissal.
- Review the diff for accidental architecture migrations, duplicate state, leaked prompt content, and unrelated edits.

### 6. Report the outcome

Summarize the dependency change, integration location, configuration choices, adapters, error handling, and verification performed. Mention any required device capability or unresolved deployment-target constraint.

## Reference routing

- Always read [dependency-installation.md](reference/dependency-installation.md) and [generic-chatbot-api.md](reference/generic-chatbot-api.md).
- Read only the applicable sections of [architecture-adaptation.md](reference/architecture-adaptation.md).
- Read [knowledge-errors-and-privacy.md](reference/knowledge-errors-and-privacy.md) when the integration uses app knowledge, networking, storage, diagnostics, or personalized data.
- Always read [verification.md](reference/verification.md) before completing the task.

## Guardrails

- Preserve user changes and generated-project sources of truth.
- Do not claim that instructions or retrieved context train Apple's model.
- Do not invent application content, credentials, remote endpoints, persistence requirements, or analytics events.
- Do not expose prompts, retrieved private content, generated messages, tokens, or credentials in logs.
- Do not edit generated Xcode projects when a Tuist, XcodeGen, or other generator manifest owns them.
- Do not commit, push, raise deployment targets, or change external services unless the user authorizes that action.
