# Changelog

## 0.1.0

- Initial release of `genkit_opencode_custom` (renamed from
  `genkit_openai_custom`, now that the OpenCode bridge is the primary surface).
- `openCode()` bridge that serves OpenCode V2 server models through
  `opencode_sdk_dart`:
  - local service discovery (`OpenCodeClient.connectLocal`) or a remote
    `baseUrl`
  - real model catalog with capabilities for the Dev UI
  - streaming via ephemeral sessions plus the shared event stream, with
    `session.wait` polling and server-side reconciliation so a dropped event
    stream delays a turn instead of hanging it
  - structured outputs: the output schema is appended to the prompt as JSON
    instructions and Genkit parses the response
  - media parts forwarded as session prompt attachments
  - persistent sessions via `OpenCodeModelOptions(sessionID: ...)` (model and
    agent switched, session kept)
  - opt-in `websearch` tool (`webSearchTool: true`) backed by the server's web
    search providers
  - cancellation bridged to the SDK's `CancellationToken`
- `openAI()` companion handle for OpenAI and OpenAI-compatible Chat Completions
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
- Tests covering converters, capability checks, streaming assembly, plugin
  registration, error mapping, and the OpenCode bridge against fake hosts.
