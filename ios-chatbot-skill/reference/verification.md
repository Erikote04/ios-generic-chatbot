# Verification

Validate proportionally to the integration and use the repository's existing commands.

## Dependency checks

- Resolve packages successfully.
- Confirm the intended target links `GenericChatbot`.
- Confirm deployment is iOS 26 or later.
- Confirm generated projects were regenerated from their source manifests.

## Build and tests

- Build the affected scheme for an iOS simulator or generic iOS destination.
- Run existing tests covering the modified feature and composition layer.
- Add focused tests for new knowledge, history, reporter, or remote-provider adapters.
- Use Swift Testing when the repository already uses it; follow the existing test framework otherwise.

Do not require a live Apple model in ordinary unit tests. Test host adapters with deterministic doubles and reserve device validation for availability and end-to-end behavior.

## Behavioral checks

- Available model: open, send, stream, cancel, retry, start a new conversation, and dismiss.
- Unavailable model: device ineligible, Apple Intelligence disabled, and assets not ready.
- Grounded mode: relevant context, empty results, and retrieval failure.
- Remote dependencies: offline, connection loss, timeout, authentication, invalid response, and cancellation.
- Persistence: restore, save, delete, account scoping, and storage failure when configured.

## UI and accessibility

- Verify VoiceOver labels and reading order.
- Verify Dynamic Type, multiline composition, keyboard dismissal, and 44-point controls.
- Verify sheet/full-screen/hosting-controller dismissal through the host navigation owner.
- Verify custom styling does not encode state using color alone.

## Final diff review

- No unrelated changes or architecture migration.
- No duplicate conversation state or request orchestration.
- No credentials, prompts, private content, or raw diagnostics in code or logs.
- No dependency added to unrelated targets.
- No generated project file edited instead of its source manifest.
