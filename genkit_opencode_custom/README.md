# genkit_opencode_custom

A Genkit Dart plugin for **OpenCode**: it serves models from a local or remote
**OpenCode server** through `opencode_sdk_dart`, with an
**OpenAI-compatible Chat Completions** client as a companion handle.

```dart
import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';

Future<void> main() async {
  final ai = Genkit(plugins: [openCode()]);

  // Models from your local OpenCode server (discovered automatically).
  final local = await ai.generate<String, OpenCodeModelOptions>(
    model: openCode.model('kimi-k2.6'),
    prompt: 'Summarize what OpenCode is.',
  );
  print(local.text);

  // OpenAI and OpenAI-compatible hosts use the companion handle.
  final response = await ai.generate<String, OpenAIChatOptions>(
    model: openAI.model('gpt-4o'),
    prompt: 'Explain Dart extension types in two sentences.',
  );
  print(response.text);
}
```

## The two handles

| Handle | Backed by | Use it for |
| --- | --- | --- |
| `openCode()` | `opencode_sdk_dart`'s `OpenCodeClient` (local service discovery, model catalog, sessions, events), run through the `opencode_effect` bridge | models served by a local or remote OpenCode V2 server |
| `openAI(...)` | a direct HTTP + SSE client that reuses `opencode_sdk_dart`'s SSE decoder and cancellation primitives | OpenAI and any OpenAI-compatible host: chat, embeddings, speech, and transcription, with Genkit-owned tool calling and structured outputs |

Both handles are offline-first: constructing the plugin neither requires an API
key nor performs network I/O, so `Genkit(plugins: [...])` always starts — even
without `OPENAI_API_KEY` and without a running OpenCode server.

## The OpenCode bridge (`openCode`)

```dart
final ai = Genkit(
  plugins: [
    // Local: discovers (or starts) the background service, no config needed.
    openCode(),

    // Remote: connect to a specific server.
    openCode(
      name: 'remote',
      baseUrl: 'https://my-server:4096',
      headers: {'Authorization': 'Basic ...'},
    ),
  ],
);

final models = await ai.listActions(); // real server catalog + capabilities
final result = await ai.generate<String, OpenCodeModelOptions>(
  model: openCode.model('kimi-k2.6'),
  prompt: 'Hello!',
  config: OpenCodeModelOptions(variant: 'high', agent: 'build'),
);
```

How the bridge maps Genkit onto the server:

| Genkit | OpenCode server |
| --- | --- |
| model discovery (`list()`) | `GET /api/model` (real capabilities, enabled flag) |
| unary generate | `POST /api/experimental/generate` with a resolved `ModelRef` (text-only requests) |
| streaming | session + `POST /api/session/{id}/prompt` + the shared event stream (`session.text.delta`, `session.reasoning.delta`, `session.text.ended`/`reasoning.ended` reconciliation, `session.step.ended` usage, `session.execution.*` completion) |
| structured output | the output schema is appended to the prompt as JSON instructions; Genkit parses the response, so `outputSchema` works on any server model |
| media inputs | media parts become prompt file attachments (`files`), so the request runs through a session |
| persistent sessions | `OpenCodeModelOptions(sessionID: ...)` reuses a server session (model and agent are switched, the session is kept) instead of an ephemeral one that is deleted afterwards |
| cancellation | Genkit's `CancellationToken` interrupts the running effect (a fiber on the plugin's runtime), which cancels the SDK's per-run token and tears the request down; cancelling a streamed turn stops waiting and still removes an ephemeral session |
| sampling parameters | the server's own model configuration |

Every server call runs as an effect on one long-lived `Runtime` owned by the
plugin (`opencode_effect`): reads such as model discovery retry transient
failures, while prompts, session writes, and the websearch tool are never
retried. The runtime lives exactly as long as the plugin object — Genkit has no
plugin-close hook — and `OpenCodePlugin.close()` is available for deterministic
teardown (it also closes a client the plugin built; a caller-provided client
stays the caller's to close).

Bridge features in code:

```dart
// Structured output: typed results from any server model.
final review = await ai.generate<Review, OpenCodeModelOptions>(
  model: openCode.model('kimi-k2.6'),
  prompt: 'Review this training plan...',
  outputSchema: Review.$schema,
);
print(review.output?.score);

// Media: images and files ride along as prompt attachments.
await ai.generate<String, OpenCodeModelOptions>(
  model: openCode.model('kimi-k2.6'),
  messages: [
    Message(
      role: Role.user,
      content: [
        TextPart(text: 'What is in this image?'),
        MediaPart(media: Media(url: 'https://...', contentType: 'image/png')),
      ],
    ),
  ],
);

// Persistent session: the server keeps the conversation between calls.
final first = await ai.generate<String, OpenCodeModelOptions>(
  model: openCode.model('kimi-k2.6'),
  prompt: 'Remember the number 41.',
  config: OpenCodeModelOptions(sessionID: session.id.value),
);
final second = await ai.generate<String, OpenCodeModelOptions>(
  model: openCode.model('kimi-k2.6'),
  prompt: 'Which number did I ask you to remember?',
  config: OpenCodeModelOptions(sessionID: session.id.value),
);
// second.text == '41'
```

### The web search tool

`openCode(webSearchTool: true)` registers `<name>/websearch`, a Genkit tool
backed by the server's web search providers. Use it with tool-capable models
from any plugin — the bridge's own models still reject Genkit tools:

```dart
final ai = Genkit(plugins: [openCode(webSearchTool: true), openAI()]);

final result = await ai.generate<String, OpenAIChatOptions>(
  model: openAI.model('gpt-4o'),
  prompt: 'Search the web for the latest Genkit Dart release.',
  toolNames: ['opencode/websearch'],
);
```

Documented limitations of the bridge:

- **Genkit tools are not routed through the bridge's own models.** The
  server's agent executes its own tools, so requests to an `openCode.model(...)`
  carrying `toolNames` fail fast with `UNIMPLEMENTED` and a pointer to
  `openAI()`. The `websearch` tool above is the exception: it is a Genkit tool
  *provided by* the plugin for other models.
- Conversations are rendered into the server's prompt format
  (`User:`/`Assistant:`/`Tool result:`); there is no message-array API.
- Sampling options (`temperature`, ...) are not forwarded; use
  `OpenCodeModelOptions` to select a `variant` or `agent` instead.
- Structured output is instruction-based, not native constrained generation:
  a model that ignores the instructions returns unparseable JSON and
  `response.output` is null.

The event stream is treated as best-effort. The shared SSE connection is
live-only and can end mid-turn (reconnects, slow-consumer overflow, server
restarts), so each streaming turn races the events against
`POST /session/{id}/wait` plus an assistant-message check, and reconciles the
final text with the server's own record of the message. A dropped event stream
therefore delays the answer but never loses it.

## Registering the OpenAI-compatible plugin (`openAI`)

```dart
final ai = Genkit(
  plugins: [
    // Standard OpenAI: reads OPENAI_API_KEY at request time.
    openAI(),

    // OpenAI-compatible host under its own namespace, with a custom catalog.
    openAI(
      name: 'groq',
      baseUrl: 'https://api.groq.com/openai/v1',
      apiKey: Platform.environment['GROQ_API_KEY'],
      dialect: OpenAICompatDialect.openRouter, // start from a preset, tweak fields
      models: [
        CustomModelDefinition(
          name: 'llama-3.3-70b-versatile',
          label: 'Llama 3.3 70B',
          capabilities: ModelCapabilities(media: false),
        ),
      ],
    ),

    // Local Ollama: no key required.
    openAI(name: 'ollama', dialect: OpenAICompatDialect.ollama),
  ],
);
```

Options and key resolution:

- `name` — the namespace models are registered under (`<name>/<model>`).
  Defaults to the dialect's `defaultNamespace` (`openai`).
- `apiKey` / `apiKeyProvider` / `<dialect.apiKeyEnvVar>` — resolved in that
  order at request time, never at construction time. `apiKeyRequired: false`
  (for example in the `ollama` preset) skips the check entirely.
- `baseUrl` — defaults to the dialect's `defaultBaseUrl`. A trailing
  `/chat/completions` is tolerated and normalized away.
- `models` — `CustomModelDefinition`s reported by `list()` and used as the
  authoritative capability source for pre-flight checks.
- `listModels` — when true (default), `GET /models` discovery feeds the Genkit
  Dev UI; failures are logged and ignored.

### Dialects

`OpenAICompatDialect` describes how a host deviates from OpenAI's API. Presets:
`openAI`, `deepSeek`, `xAI`, `openRouter`, `ollama`, `groq`, `together`,
`mistral`, `lmStudio`. Fields:

| Field | Meaning |
| --- | --- |
| `defaultNamespace`, `defaultBaseUrl`, `apiKeyEnvVar`, `apiKeyRequired` | connection defaults |
| `useLegacyMaxTokens` | send `max_tokens` instead of `max_completion_tokens` |
| `supportsJsonSchema` | accept `response_format: {"type":"json_schema"}` |
| `includeUsageInStream` | send `stream_options: {"include_usage": true}` |
| `supportsReasoningEffort` | send `reasoning_effort` / `verbosity` |
| `extraBody` | fields merged into every request body |

### Chat options (`OpenAIChatOptions`)

`temperature`, `topP`, `maxTokens`, `stop`, `presencePenalty`,
`frequencyPenalty`, `seed`, `user`, `version` (model snapshot override),
`jsonMode`, `strictSchema`, `includeUsageInStream`, `reasoningEffort`,
`verbosity`, `visualDetailLevel`, and `extraBody` (per-request fields).

## Chat models: features

Text generation, streaming, multi-turn conversations, tool calling (Genkit owns
the loop), and structured outputs all run through the standard Genkit APIs:

```dart
// Streaming (reasoning deltas arrive as ReasoningParts).
final stream = ai.generateStream<String, OpenAIChatOptions>(
  model: openAI.model('gpt-5.2'),
  prompt: 'Write a haiku about Dart.',
  config: OpenAIChatOptions(reasoningEffort: 'low'),
);
await for (final chunk in stream) {
  for (final part in chunk.content) {
    if (part.isReasoning) print('[thinking] ${part.reasoning}');
    if (part.isText) print(part.text);
  }
}

// Tool calling: define tools with Genkit and pass toolNames.
ai.defineTool(
  name: 'lookupPackage',
  description: 'Looks up a package version on pub.dev.',
  inputSchema: LookupInput.$schema,
  outputSchema: SchemanticType.string(),
  fn: (input, ctx) async => .response('1.0.0'),
);
final result = await ai.generate<String, OpenAIChatOptions>(
  model: openAI.model('gpt-4o'),
  prompt: 'What version is genkit?',
  toolNames: ['lookupPackage'],
);

// Structured output.
final review = await ai.generate<Review, OpenAIChatOptions>(
  model: openAI.model('gpt-4o'),
  prompt: 'Review this function...',
  outputSchema: Review.$schema,
);
print(review.output?.score);
```

## Capability checks

Requests are validated against `ModelCapabilities` **before** any network I/O,
turning provider 400s into actionable errors:

- images to a text-only model (`gpt-3.5`, `deepseek-chat`),
- tools to a model without tool support (`o1-preview`),
- `toolChoice` where it is unsupported,
- structured output from a model without JSON output,
- `reasoningEffort` to a model that is known not to reason.

Checks run only for names the catalog knows (`curatedCapabilities`); unknown
names pass through untouched so a new model is never blocked by stale metadata.
`checkCapabilities: false` disables the checks, and a
`CustomModelDefinition`'s capabilities are authoritative for its name.

Reasoning models that reject `system` messages (o-series, gpt-5) get `developer`
messages automatically.

## Structured output details

- `outputSchema` maps to `response_format: {"type":"json_schema"}` with the
  schema inlined (`$defs`/`$ref` flattened) for hosts that accept it.
- `strictSchema: true` additionally rewrites the schema for OpenAI strict mode
  (`additionalProperties: false`, every property required). The default is
  `false` because strict mode rejects optional fields.
- Hosts without `json_schema` support (`supportsJsonSchema: false`) fall back
  to `json_object` plus a schema instruction appended to the conversation.
- `jsonMode: true` sends `json_object` when Genkit asked for no output config.

## Embeddings

```dart
final embeddings = await ai.embed<OpenAIEmbedderOptions>(
  embedder: openAI.embedder('text-embedding-3-small'),
  documents: [
    DocumentData(content: [TextPart(text: 'Genkit is an AI framework.')]),
  ],
  options: OpenAIEmbedderOptions(dimensions: 256),
);
print(embeddings.first.embedding.length); // 256
```

- Any name resolves: `openAI.embedder('text-embedding-3-small')`, or
  `openAI.embedder('nomic-embed-text', namespace: 'ollama')` for a local host.
- Documents are flattened to text (parts joined with newlines); a document
  without text is rejected before any request.
- More than 2048 inputs are split across requests automatically.
- `dimensions` is validated against the curated catalog
  (`text-embedding-3-small/large`, `text-embedding-ada-002`) when the plugin
  dials the dialect's own host; other hosts are left to their own limits.

## Speech (text-to-speech)

```dart
final result = await ai.generate<String, OpenAISpeechOptions>(
  model: openAI.speechModel('tts-1'),
  prompt: 'Welcome to the gym.',
  config: OpenAISpeechOptions(voice: 'coral', responseFormat: 'mp3'),
);
final audio = result.media!; // MediaPart: data:audio/mpeg;base64,...
```

`voice` is free-form (hosts add voices without warning), `instructions` is
honored by `gpt-4o-mini-tts`, `speed` is bounded to 0.25-4.0, and
`responseFormat` picks the container (`mp3`, `opus`, `aac`, `flac`, `wav`,
`pcm`).

## Transcription (speech-to-text)

```dart
final result = await ai.generate<String, OpenAITranscriptionOptions>(
  model: openAI.transcriptionModel('whisper-1'),
  messages: [
    Message(
      role: Role.user,
      content: [
        MediaPart(
          media: Media(
            contentType: 'audio/mpeg',
            url: 'data:audio/mpeg;base64,${base64Encode(bytes)}',
          ),
        ),
      ],
    ),
  ],
  config: OpenAITranscriptionOptions(language: 'en'),
);
print(result.text); // the transcript
```

- Audio must be a base64 `data:` URL; the MIME type picks the upload filename.
- `responseFormat` supports `json`, `text`, `srt`, `verbose_json`, `vtt`;
  `verbose_json` payloads are also available on `result.raw`.
- `translate: true` (whisper only) routes to `/audio/translations`.

## OpenAI-compatible endpoints: compatibility notes

1. **Model discovery** — not every host implements `GET /models`, and those
   that do rarely return capabilities. Discovery is best-effort; explicit
   `openAI.model('any-id', namespace: ...)` references always resolve.
2. **Token limit field** — OpenAI requires `max_completion_tokens` for
   o-series/gpt-5; several compatible hosts only understand `max_tokens`
   (`useLegacyMaxTokens`).
3. **Structured output** — `json_schema` is not universal; when unsupported the
   plugin degrades to `json_object` plus a schema instruction.
4. **Streaming usage** — OpenAI reports usage on a final SSE frame via
   `stream_options.include_usage`; minimal proxies reject the field
   (`includeUsageInStream: false`).
5. **Tool schemas** — tool inputs must be object schemas with resolvable
   references. `$defs`/`$ref` are inlined; recursive schemas are sent as-is and
   rejected by hosts (like xAI) that do not resolve references.
6. **Reasoning replay** — `ReasoningPart`s are never sent back in conversation
   history; most hosts reject or ignore them (DeepSeek rejects
   `reasoning_content` outright).
7. **Media** — images must be `http(s)` or `data:` URLs; local file paths are
   rejected with an actionable error. Non-image media must be `data:` URLs.

## Relationship to `genkit_openai`

This package was built after reviewing the first-party `genkit_openai`
(Apache-2.0). It is not a fork: the wire format is implemented here directly,
and the OpenCode bridge does not exist upstream. Feature differences worth
knowing:

| Area | `genkit_openai` | this package |
| --- | --- | --- |
| OpenCode server models | not supported | `openCode()` bridge with discovery, sessions, events |
| Host quirks | internal `OpenAIProvider`, not extensible | public `OpenAICompatDialect` + presets |
| Client stack | `openai_dart` + body-rewrite interceptor | direct JSON/SSE via `opencode_sdk_dart`'s `decodeSseFrames` and cancellation pattern |
| Capability checks | `reasoningEffort` only | tools, toolChoice, media, JSON output, reasoningEffort |
| Structured output | `strict: false` only | `strictSchema` with strict-mode schema rewriting |
| Streaming usage | always `include_usage` | configurable per dialect and per request |
| Constrained-generation simulation middleware | supported | not in scope; the `json_object` fallback appends a schema instruction instead |
| Speech / transcription / embeddings | supported | supported via `speechModel`, `transcriptionModel`, and `embedder` |
| Model catalog | large curated catalog | deliberately small pattern catalog; unknown names pass through |

Both packages coexist: `genkit_openai` ships a large curated catalog and the
constrained-generation middleware; this package adds public dialects,
pre-flight capability checks, the OpenCode bridge, and speaks the same
endpoints for chat, embeddings, speech, and transcription.

## Development

```bash
dart pub get
dart run build_runner build   # regenerates lib/src/options.g.dart
dart analyze
dart test
dart run tool/live_check.dart # live smoke test against the local OpenCode server
```
