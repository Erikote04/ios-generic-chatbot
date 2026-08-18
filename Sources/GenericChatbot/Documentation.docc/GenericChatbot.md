# ``GenericChatbot``

Build a reusable, configurable chatbot for any SwiftUI application.

## Overview

GenericChatbot separates conversation presentation from model execution, application knowledge, persistence, and diagnostics. Use Apple's on-device Foundation Models implementation or inject any provider that conforms to ``ChatModelProvider``.

The package never assumes what kind of application integrates it. A host controls the assistant's instructions, retrieves its own relevant content through ``ChatKnowledgeSource``, selects grounded or general answers, and replaces every visual slot with ``ChatbotStyle``.

```swift
ChatbotLauncher { close in
    ChatbotView(
        configuration: ChatbotConfiguration(
            title: "Help",
            instructions: "Help people use this application.",
            answerPolicy: .general
        ),
        provider: FoundationModelsChatProvider(),
        close: close
    )
}
```

> Important: Instructions and retrieval customize model behavior but don't retrain Apple's system model. Adapter training and distribution are separate workflows owned by the integrating application.

## Topics

### Essentials

- <doc:GettingStarted>
- ``ChatbotLauncher``
- ``ChatbotView``
- ``ChatbotConfiguration``

### Model execution

- <doc:ModelProviders>
- ``FoundationModelsChatProvider``
- ``ChatModelProvider``
- ``ChatModelSession``
- ``ChatRequest``
- ``ChatResponseEvent``

### Application knowledge

- <doc:ApplicationKnowledge>
- ``ChatKnowledgeSource``
- ``ChatKnowledgeItem``
- ``ChatSource``
- ``ChatAnswerPolicy``

### Errors and recovery

- <doc:ErrorsAndRecovery>
- ``ChatbotError``
- ``ChatbotFailure``
- ``ChatbotRecoveryAction``
- ``ChatModelAvailability``

### Presentation and storage

- <doc:CustomizingPresentation>
- <doc:ConversationPersistence>
- ``ChatbotStyle``
- ``DefaultChatbotStyle``
- ``ChatHistoryStore``
- ``ChatbotErrorReporter``
