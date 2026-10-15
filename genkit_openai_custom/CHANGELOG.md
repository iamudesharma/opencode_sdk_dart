# Changelog

## 0.1.0

- Initial release.
- `openAI()` plugin for OpenAI and OpenAI-compatible Chat Completions
  endpoints:
  - offline-first registration, lazy API key resolution
    (`apiKeyProvider` → `apiKey` → environment variable)
  - public `OpenAICompatDialect` with `openAI`, `deepSeek`, `xAI`,
    `openRouter` and `ollama` presets
  - text generation, streaming, multi-turn conversations, tool calling, and
    structured outputs (with `strictSchema` support)
  - best-effort `GET /models` discovery plus custom model definitions
  - pre-flight capability checks with actionable errors
  - `OpenAIChatOptions` configuration surface
- `openCode()` bridge that serves OpenCode V2 server models through
  `opencode_sdk_dart`:
  - local service discovery (`OpenCodeClient.connectLocal`) or a remote
    `baseUrl`
  - real model catalog with capabilities for the Dev UI
  - streaming via ephemeral sessions plus the shared event stream, with
    `session.wait` polling and server-side reconciliation so a dropped event
    stream delays a turn instead of hanging it
  - cancellation bridged to the SDK's `CancellationToken`
- Tests covering converters, capability checks, streaming assembly, plugin
  registration, error mapping, and the OpenCode bridge against fake hosts.
