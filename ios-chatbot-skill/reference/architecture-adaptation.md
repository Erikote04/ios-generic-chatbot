# Architecture Adaptation

Choose the smallest pattern matching the host app. Preserve naming, ownership, dependency injection, navigation, and testing conventions already present.

## SwiftUI

Add `ChatbotLauncher` at the view that owns presentation. Inject dependencies from the environment, feature factory, or composition root already used by the app. Use `ChatbotView` directly when a navigation destination owns the full screen.

Do not create a second observable object that mirrors conversation messages, loading state, or errors. The library already owns those states.

## UIKit or mixed UI

Keep UIKit navigation ownership. Either:

- Embed `ChatbotLauncher` in a small `UIHostingController`, or
- Present a `UIHostingController` whose root is `ChatbotView` and pass a close action that dismisses through the existing presenter/coordinator.

Use an accessible `UIButton` with an SF Symbol if the host must own a UIKit launcher. Do not introduce a parallel navigation stack.

## MVVM or MVC

Construct chatbot dependencies in the screen factory, dependency container, controller, or parent view. Keep application-specific retrieval in a `ChatKnowledgeSource` adapter. Do not move the library's conversation state into the host view model or controller.

## Coordinator or router

Let the coordinator/router decide where and how the chatbot appears. Build the SwiftUI root in a factory and route dismissal through the supplied close closure. Keep the model provider and application adapters in the composition root.

## Clean Architecture or VIPER

Treat GenericChatbot as a presentation component. Adapt existing use cases or repositories behind `ChatKnowledgeSource`, `ChatHistoryStore`, and `ChatbotErrorReporter`. Keep domain entities out of the package API and keep the interactor/presenter free of duplicated streaming state.

## Reducer-based architectures

Represent only host-owned presentation state, such as whether a destination is shown. Construct non-stateful configuration at the dependency boundary. Do not store model sessions or non-equatable provider objects in reducer state, and do not mirror the library's internal conversation reducer.

## Modular applications

Link the package to the narrowest module that imports it. If a shared feature module exposes the chatbot, define app-specific adapters in an outer module and inject them through its public factory. Avoid making low-level domain modules depend on SwiftUI or GenericChatbot.

## Existing design systems

Start with `ChatbotTheme` when semantic colors and typography are enough. Implement `ChatbotStyle` only when structure must change. Reuse existing tokens, localized strings, button styles, spacing, and accessibility conventions.

## Decision rules

- Prefer a wrapper view or factory over cross-cutting architecture changes.
- Prefer protocol adapters over exposing repositories directly to presentation.
- Let the host own feature presentation; let GenericChatbot own conversation behavior.
- Add only the abstractions the current use case needs.
