# iOS GenericChatbot Integration Skill

Use this skill to add and configure [GenericChatbot](https://github.com/Erikote04/ios-generic-chatbot) in an existing iOS application without replacing its architecture.

The workflow supports SwiftUI, UIKit, mixed UI, MVVM, MVC, coordinators, Clean Architecture, VIPER, reducer-based architectures, generated projects, and modular applications. It always checks and installs the library dependency before implementing the feature.

## Codex

Install or link `ios-chatbot-skill` into your Codex skills directory, then invoke it with a task such as:

```text
Use $ios-chatbot-skill to add the GenericChatbot assistant to this app and ground it in the existing help repository.
```

## Claude Code

Load the plugin directly while developing:

```shell
claude --plugin-dir ./ios-chatbot-skill
```

Or clone the repository, add the skill directory as a local marketplace, and install the plugin:

```text
/plugin marketplace add /absolute/path/to/ios-generic-chatbot/ios-chatbot-skill
/plugin install ios-chatbot-skill@erikote04-ios-skills
```

## Contents

- `SKILL.md`: Architecture-adaptive integration workflow.
- `agents/openai.yaml`: Codex interface metadata.
- `.claude-plugin/plugin.json`: Claude Code plugin metadata.
- `.claude-plugin/marketplace.json`: Claude Code marketplace entry.
- `reference/`: Dependency, architecture, API, privacy, error, and verification guidance.
