# opencode_sdk_dart

A cross-platform Dart 3 SDK for the **OpenCode V2 HTTP API**.

The SDK is generated from the official OpenAPI 3.1 contract served at
<https://opencode.ai/v2/openapi.json> and mirrors the semantics of the
reference TypeScript client (`@opencode/client`): identical resource layout,
envelope unwrapping, error decoding, shared event connection, plugin RPC
behavior, PTY WebSocket handshake, and background service discovery.

A ready-made macOS client built on this SDK lives in
[`chat_app/`](chat_app/README.md): streaming transcripts, tool cards, session
management, agent/model switching, and permission prompts. The larger
[`opencode_cockpit/`](opencode_cockpit/README.md) workbench adds project tabs,
a session tree, files and git panels, session diffs, worktree management, a
statistics dashboard, and real PTY terminals.

## Highlights

- **Typed resources** for all 29 API groups — `client.session`,
  `client.pty`, `client.mcp`, `client.permission`, `client.vcs`, and more.
- **438 generated declarations**: sealed unions with exhaustive `switch`
  support, branded scalar types (`extension type SessionID(String)`), real
  Dart enums with wire mapping, and data classes with `fromJson`/`toJson`.
- **Structured errors**: every `_tag`-encoded error becomes a typed exception
  (`SessionNotFoundError`, `RpcError`, ...) carrying the HTTP status code.
- **One lazy event connection** shared by native events and plugin RPC, with
  `server.connected` replay for late subscribers and per-subscriber overflow
  protection, exactly like the reference client.
- **Plugin RPC** with typed method calls and event streams
  (`client.rpc('acme').call(...)`, `.subscribe(...)`, `.on(...)`).
- **PTY support**: ticket handshake plus WebSocket connect helpers for both
  regular and persistent PTYs.
- **Local service management**: `OpenCodeService.discover()`, `ensure()`,
  `stop()`, and Basic-auth headers, including persistent-terminal handoff.
- **Cross-platform**: pure Dart on `dart:io` platforms and the web
  (`package:http` + `web_socket_channel`); cancellation via
  `CancellationToken` aborts in-flight requests and streams.

## Getting started

```yaml
dependencies:
  opencode_sdk_dart:
    path: ../opencode_sdk_dart
```

```dart
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

Future<void> main() async {
  // Discover (or start) the local background service and authenticate.
  final client = await OpenCodeClient.connectLocal();
  // For a remote server:
  //   final client = OpenCodeClient.make(baseUrl: Uri.parse('http://host:4096'));

  final info = await client.server.info();
  print('OpenCode ${info.version} at ${info.urls}');

  final session = await client.session.create(title: 'Hello');
  await client.session.prompt(sessionID: session.id, text: 'Hi there!');

  await for (final event in client.event.subscribe()) {
    print(event.type);
    if (event.type == 'session.idle') break;
  }

  client.close();
}
```

`OpenCode.connectLocal()` is the same entry point exported as a static on the
`OpenCode` helper class, matching the reference naming.

## Working with resources

Method arguments are named and flattened, so request bodies read as plain
arguments:

```dart
final session = await client.session.create(
  title: 'Review',
  agent: AgentID('build'),
  location: const LocationRef.directory('/workspace'),
);

await client.session.prompt(
  sessionID: session.id,
  text: 'Review the current changes',
);

final messages = await client.session.message.list(sessionID: session.id);
final diff = await client.session.diff(sessionID: session.id);
```

Grouped endpoints keep the reference client's nesting:

```dart
client.session.form.reply(formID: ..., sessionID: ..., answers: ...)
client.session.revert.stage(sessionID: ...)
client.permission.saved.list()
client.mcp.resourceCatalog()
client.vcs.branchList()
```

Envelope handling matches the reference behavior: `{data: ...}` responses are
unwrapped (`session.create()` returns `SessionInfo`), while
`{location, data}` responses return a `LocatedResponse<T>` exposing both
fields.

## Request options

Every call accepts `RequestOptions`:

```dart
final token = CancellationToken();
final agents = await client.agent.list(
  options: RequestOptions(
    location: const LocationRef.directory('/workspace'),
    headers: {'x-my-header': 'value'},
    cancelToken: token,
  ),
);
token.cancel(); // aborts the request and closes its stream
```

## Events

`client.event.subscribe()` and `client.events.subscribe()` are aliases backed
by one lazily opened connection:

- no connection opens until the first listener subscribes;
- late subscribers immediately receive the `server.connected` marker;
- cancelling one subscription leaves the others running; the last one closes
  the connection;
- slow consumers buffer up to 4096 events and then fail their stream;
- subscriptions are live-only: a source failure ends current subscriptions and
  a new subscription opens a fresh connection.

```dart
final subscription = client.event.subscribe().listen((event) {
  switch (event.type) {
    case 'server.connected':
      print('connected');
    case 'session.updated':
      print(event.data);
  }
});
```

## Plugin RPC

```dart
final acme = client.rpc('acme');

// Typed call; `input` is serialized as-is, `decode` receives the raw output.
final result = await acme.call(
  'search',
  input: {'query': 'hello'},
  decode: (output) => asJsonMap(output)['text'] as String,
);

// Streaming subscription (filtered from the shared event connection).
final stream = acme.subscribe<String>(
  'updated',
  decode: (data) => asJsonMap(data)['text'] as String,
);

// Callback subscription with sequential async handling; returns unsubscribe.
final unsubscribe = acme.on<String>(
  'updated',
  (event) async => print(event.data),
  decode: (data) => asJsonMap(data)['text'] as String,
);
```

Declared RPC errors surface as `RpcError` (with `type`, `data`, and
`statusCode`); framework failures surface as `RpcInternalError`.

## PTY WebSockets

```dart
final socket = await client.pty.connectSocket(ptyID: PtyID('pty_1'));
socket.text.listen(stdout.write);
socket.send('ls\n');
await socket.close();
```

`client.persistentPty.connectSocket(...)` mirrors the persistent PTY handshake
(with `cursor`, `role`, `attachmentID`, and `takeover`).

## Errors

```dart
try {
  await client.session.get(sessionID: SessionID('ses_missing'));
} on SessionNotFoundError catch (error) {
  print(error.statusCode); // 404
  print(error.sessionID);
} on OpenCodeApiException catch (error) {
  print(error.tag); // wire discriminator
}
```

Transport failures throw `OpenCodeTransportException`; invalid payloads throw
`OpenCodeDecodeException` with a dotted `path`; cancelled calls throw
`OpenCodeCancelledException`; non-declared statuses throw
`OpenCodeStatusException`.

## Models

Unions are sealed classes with exhaustive pattern matching:

```dart
final kind = switch (message) {
  SessionMessageUser() => 'user',
  SessionMessageAssistant() => 'assistant',
  SessionMessageCompaction() => 'compaction',
  _ => message.type,
};
```

Union parents expose members shared by every variant (`message.id`,
`message.type`). Scalar schemas are zero-cost `extension type`s:

```dart
final id = SessionID('ses_123');   // implements String
final cost = MoneyUSD(0.25);       // implements double
```

Enums carry their wire value: `PtyStatus.running.wire == 'running'`.

## Local service management

```dart
final endpoint = await OpenCodeService.discover();      // no process start
final ensured = await OpenCodeService.ensure();         // discovers or starts
final headers = OpenCodeService.headers(ensured);       // Basic auth headers
await OpenCodeService.stop();                           // stop exact instance

// Version constraints and lifecycle callbacks:
await OpenCodeService.ensure(
  options: EnsureOptions(
    version: ServiceVersionConstraint.matches((v) => v.startsWith('2.')),
    onStart: (reason, previous) => print('$reason $previous'),
  ),
);
```

On the web, discovery throws `UnsupportedError`; connect to a reachable server
directly instead.

## Regenerating the SDK

The entire `lib/src/generated` tree is produced from `openapi/openapi.json`:

```sh
curl -o openapi/openapi.json https://opencode.ai/v2/openapi.json
dart run tool/generate.dart
dart format lib tool --line-length 80
dart analyze --fatal-infos
```

The generator (`tool/generate.dart`) handles the contract's OpenAPI 3.1
constructs: dotted schema names, `anyOf` nullability, `_tag`/`type`/`status`
discriminators, nested unions, `deepObject` location parameters, wildcard
paths, binary bodies, SSE endpoints, and envelope shapes.

## Testing

```sh
dart test                    # unit suite with mocked HTTP
dart run tool/live_smoke.dart  # read-only checks against a running server
```

The unit suite covers models, unions, error decoding, query/URL encoding,
cancellation, SSE framing, multiplexer semantics, RPC calls and events,
resource envelopes, and service discovery. `tool/live_smoke.dart` validates
discovery, typed resources, and SSE against a live service.

## Layout

```text
lib/
  opencode_sdk_dart.dart          # public API
  src/core/                       # transport, SSE, events, errors, options
  src/rpc/                        # plugin RPC subclient
  src/pty/                        # WebSocket helpers + resource extensions
  src/service/                    # local background service management
  src/generated/                  # models + 28 resources + client (generated)
chat_app/                         # minimal macOS chat client
opencode_cockpit/                 # full macOS workbench (projects, git, PTY)
genkit_opencode_custom/           # Genkit Dart plugin: OpenCode server bridge
                                  #   (openCode()) through this SDK, plus an
                                  #   OpenAI-compatible handle (openAI())
gym_coach/                        # macOS app: streams workout + food plans from
                                  #   an OpenCode model through the plugin above
tool/
  generate.dart                   # OpenAPI 3.1 -> Dart 3 code generator
  live_smoke.dart                 # live read-only smoke test
openapi/openapi.json              # pinned contract snapshot
```

The two packages at the end depend on this SDK through `path:` dependencies and
have their own READMEs with setup and usage details.

## Notes on divergence from `@opencode/client`

- Errors expose a `statusCode` captured from the HTTP response.
- `{location, data}` envelopes decode to `LocatedResponse<T>` instead of
  stripping the location.
- JSON bodies are encoded as UTF-8 bytes with an explicit
  `application/json; charset=utf-8` content type.
- Web-only builds cannot manage a local service; everything else is
  platform-independent.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE).
