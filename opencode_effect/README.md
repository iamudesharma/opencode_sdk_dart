# opencode_effect

Effect-based adapter for [`opencode_sdk_dart`](../README.md), built on
[`effect_core`](https://pub.dev/packages/effect_core).

The SDK stays a plain, generated, dependency-light client. This package is the
single adapter that turns its operations into lazy, typed, interruptible
effects:

- **one sealed error channel** — every expected failure is an
  [`OpenCodeError`](lib/src/errors.dart) (`OpenCodeApiError`,
  `OpenCodeTransportError`, `OpenCodeStreamError`, `OpenCodeExecutionFailed`,
  `OpenCodeServiceError`, ...), while foreign exceptions stay *defects*;
- **structured cancellation** — interrupting a fiber cancels the SDK
  cancellation token and aborts the in-flight HTTP request;
- **scoped client lifetime** — `openCodeClientLayer()` acquires one client per
  scope and closes it (event connection + HTTP pool) when the scope ends;
- **pull streams** — events, turns and PTY output are `EffectStream`s with
  bounded buffering and scope-bound cleanup;
- **reliability** — `withReadRetry()` composes the SDK-proven read policy
  (3 attempts, transient statuses only) as an effect `Schedule`; writes are
  never retried implicitly;
- **local service management** — discovery, start and stop as effects.

## Install

```yaml
dependencies:
  effect_core: ^0.0.2
  opencode_effect:
    path: ../opencode_effect
  opencode_sdk_dart:
    path: ../
```

## Quick start

```dart
import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

Future<void> main() async {
  final runtime = Runtime<Unit>(Unit.value);

  // The layer discovers (or starts) the local service, and owns the client.
  final effect = openCodeClientService
      .effect<OpenCodeError>()
      .flatMap((client) {
        // Bind ANY generated resource method with `call`; `read` adds the
        // transient-failure retry policy for reads.
        return client.read(
          (options) => client.sdk.server.info(options: options),
        );
      });

  final info = await runtime.runFuture(withOpenCodeClient(effect));
  print('OpenCode ${info.version} at ${info.urls}');

  await runtime.shutdown();
}
```

## Binding SDK calls

Every generated resource method takes `RequestOptions`; forward the options the
run hands you:

```dart
final Effect<List<AgentInfo>, OpenCodeError, Unit> agents = client.call(
  (options) => client.sdk.agent.list(options: options),
);

final sessions = client.call(
  (options) => client.sdk.session.list(
    limit: '10',
    options: options,
  ),
  location: const LocationRef.directory('/workspace'),
);
```

Binding is intentionally thin: the published SDK surface (29 resources, 438
declarations) stays the single source of truth, and this package does not need
regeneration when the contract changes.

## Turns (session prompt to final result)

```dart
final result = await runtime.runOpenCode(
  client.runTurn(
    sessionID: session.id,
    text: 'Review the current changes',
    onEvent: (event) {
      switch (event) {
        case SessionTurnTextDelta(:final delta):
          stdout.write(delta);
        case SessionTurnCompleted():
          break;
      }
    },
  ),
);
print(result.text);
```

One run sends exactly one prompt — a turn is a write, never retry it.
Interrupting the run stops waiting and cancels that run's SDK-side token
(in-flight prompt request, `session.wait` polling, reconciliation requests).
A prompt the server already admitted keeps generating — run
`client.sdk.session.interrupt` to stop it.

For incremental UI, `client.turnStream(...)` is an `EffectStream` you can turn
into a native stream with `.toNative(runtime)`.

## Events

```dart
final subscription = client
    .events<Unit>(filter: (event) => event.type.startsWith('session.'))
    .toNative(runtime)
    .listen((event) => print(event.type));
```

The stream is live-only, matching the SDK: a source failure ends the
consumption with `OpenCodeStreamError`; a later run opens a fresh connection.

## Retry, interruption, resources

```dart
// Retries: reads only, via effect Schedule (never writes).
final agents = client.read((o) => client.sdk.agent.list(options: o));

// Cancellation: fork and interrupt; cleanup is awaited.
final fiber = runtime.fork(longRunningEffect);
fiber.interrupt();
await fiber.interruptAndAwait();

// PTY sockets: acquire/use/release with the effect runtime.
final effect = Effect.acquireUseRelease(
  client.ptyConnect(ptyID: PtyID('pty_1')),
  (socket) => client
      .ptyFrames<Unit>(socket)
      .runForEach((frame) => Effect.sync(() {
        switch (frame) {
          case PtyOutput(:final data):
            stdout.write(data);
          case PtyCursor():
            break; // resume marker
        }
      })),
  (socket, _) => client.ptyClose<Unit>(socket),
).scoped();
```

## Errors

```dart
try {
  await runtime.runOpenCode(effect);
} on OpenCodeApiError catch (error) {
  if (error.isNotFound) { /* ... */ }
  print(error.statusCode); // 404
  print(error.cause);      // original SessionNotFoundError
} on OpenCodeError catch (error) {
  print(error.message);
}
```

## Testing

```sh
dart test         # unit suite with a scripted in-process server
dart analyze      # clean under the repository lint profile
```

Tests cover error mapping, interruption/token wiring, read-only retry
semantics, layer lifetime and memoization, event/SSE consumption, full turns
and plugin RPC over a scripted `MockClient`.

## Benchmarks

```sh
dart run benchmark/overhead.dart             # in-process, no network
dart run benchmark/overhead.dart 300 --live  # GET /api/info, local service
```

The effect interpreter itself adds a couple of microseconds per call. In the
live mode every bridged call carries a per-run cancellation token, so the SDK
opens a dedicated HTTP client (and connection) per request — the price of
aborting in-flight work when the fiber is interrupted. The benchmark's third
row isolates that cost by calling the SDK without the token (shared pooled
client); see `MIGRATION.md` for the trade-off.
