# Migrating an app to `opencode_effect`

This guide is the contract for migrating the four consumer projects
(`chat_app`, `opencode_cockpit`, `gym_coach`, `genkit_opencode_custom`) onto
the effect bridge. Read
[`opencode_effect.dart`](lib/opencode_effect.dart),
[`client.dart`](lib/src/client.dart), [`call.dart`](lib/src/call.dart) and
[`layer.dart`](lib/src/layer.dart) before starting.

## Scope — non-negotiables

1. **Service/controller boundary only.** Replace direct SDK usage in the
   data/service/controller layer with effect-based equivalents. Widgets,
   screens, themes and pure UI helpers stay exactly as they are; their public
   APIs must not change.
2. **Behavior parity.** Same user-visible behavior, same error surfacing,
   same cancellation semantics. Reads are retried as before (transient
   statuses, ~3 attempts); writes are never retried.
3. **Do not edit** `opencode_effect/` or `opencode_sdk_dart/`. Gaps are
   covered with `client.call(...)` at the call site and reported at the end.
4. **Keep the app's own public API stable** (controllers' methods, callbacks,
   streams that widgets depend on). Internal representation may change.

## Dependencies

Add to the project's `pubspec.yaml`:

```yaml
dependencies:
  effect_core: ^0.0.2
  opencode_effect:
    path: ../opencode_effect   # adjust for the project's location
```

`opencode_effect` already depends on `opencode_sdk_dart`; keep the existing
SDK path dependency as-is. If the project's `environment.sdk` is below
`^3.13.0`, raise it (`effect_core` requires Dart 3.13).

## Client + runtime lifetime

A controller/service that owns a client keeps a runtime and an
`EffectOpenCodeClient`:

```dart
import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

final Runtime<Unit> _runtime = Runtime<Unit>(Unit.value);
EffectOpenCodeClient? _client;

Future<void> connect(Uri baseUrl, Map<String, String> headers) async {
  final sdk = OpenCodeClient(baseUrl: baseUrl, headers: headers);
  sdk.transport.retry = null; // retries live in effects now
  _client = EffectOpenCodeClient(sdk);
}

// In dispose:
void dispose() {
  _client?.close();
  unawaited(_runtime.shutdown()); // stops forked fibers before release
}
```

Calling `sdk.close()` before `runtime.shutdown()` is also acceptable in a
synchronous `dispose`; the runtime then stops fibers that will observe the
closed transport as transport errors.

When an operation should manage its own client (for example a one-shot
discovery), use the layer instead:

```dart
final client = openCodeClientService.effect<OpenCodeError>();
final effect = client.flatMap((c) => c.call((o) => c.sdk.server.info(options: o)));
final info = await _runtime.runFuture(withOpenCodeClient(effect));
```

## Running calls

Errors: `runOpenCode` throws the typed `OpenCodeError` for expected failures
and `EffectException` for interruption/defects. Controllers that used to
`catch` SDK exceptions now catch `OpenCodeError` (or `OpenCodeApiError` for
status-specific handling):

```dart
try {
  final sessions = await _runtime.runOpenCode(
    _client!.call((o) => _client!.sdk.session.list(options: o)),
  );
} on OpenCodeApiError catch (error) {
  // error.statusCode / error.cause (original SessionNotFoundError, ...)
} on OpenCodeError catch (error) {
  // transport, stream, decode, service, execution...
}
```

Reads that need retrying use `read()`, which composes the retry policy
internally (transient transport errors and 408/429/5xx; never on writes):

```dart
final agents = _client!.read((o) => _client!.sdk.agent.list(options: o));
```

If you compose `.withReadRetry()` on a `call(...)` inline instead, pin the
type arguments (`client.call<AgentsResponse, Unit>(...)`): chaining loses `R`
inference in argument position.

Existing `OpenCodeService.discover()/ensure()/stop()` calls become:

```dart
final endpoint = await _runtime.runOpenCode(
  discoverOpenCodeService(), // or ensureOpenCodeService / stopOpenCodeService
);
```

## Streams

Native consumers (widgets) keep receiving Dart streams by converting once:

```dart
// Old:  _client.event.subscribe().listen(...)
// New:
_events = _client!
    .events<Unit>(filter: (event) => event.type.startsWith('session.'))
    .toNative(_runtime)
    .listen(_onEvent, onError: _onError);

// The subscription cancel path is unchanged: await _events?.cancel();
```

`EffectStream.toNative` is single-subscription per listen; each listen runs a
fresh consumption of the pull stream.

Turns:

```dart
// Option A — final result with incremental callbacks:
final result = await _runtime.runOpenCode(
  _client!.runTurn(
    sessionID: sessionId,
    text: text,
    onEvent: _onTurnEvent, // SessionTurnEvent deltas, step usage, completed
  ),
);

// Option B — event stream for incremental UI:
final stream = _client!
    .turnStream<Unit>(sessionID: sessionId, text: text)
    .toNative(_runtime);
```

Both options send exactly one prompt per run. To stop generation, run
`_client!.sdk.session.interrupt(...)`. Interrupting a `runTurn` fiber also
cancels that run's SDK-side token (in-flight prompt request, `session.wait`
polling and reconciliation abort); cancelling a `turnStream` consumption only
stops observing.

## Plugin RPC

```dart
final value = await _runtime.runOpenCode(
  _client!.rpcCall<String, Unit>(
    'acme',
    'search',
    input: {'query': text},
    decode: (output) => asJsonMap(output)['text']! as String,
  ),
);

final events = _client!
    .rpcEvents<String, Unit>('acme', 'updated', decode: (data) => ...)
    .toNative(_runtime);
```

## PTY

```dart
final effect = Effect.acquireUseRelease(
  _client!.ptyConnect(ptyID: ptyID),
  (socket) => _client!.ptyFrames<Unit>(socket).runForEach(_applyFrame),
  (socket, _) => _client!.ptyClose<Unit>(socket),
).scoped();
```

`ptyFrames` yields `PtyOutput`/`PtyCursor` (including binary resume
markers); `ptyText` is the text-only variant. `PtySocket.send`/`sendInput`
and `PtyInputFrames` stay on the raw socket: they are synchronous protocol
calls on a resource the effect already owns.

For long-lived sockets held by a service (cockpit's persistent terminal), keep
the `PtySocket` and convert `ptyFrames` per session, or fork the consuming
effect and interrupt the fiber on close.

## Cancellation

Every bridged call carries a per-run SDK token so interrupting a fiber aborts
the in-flight HTTP request. The SDK implements that abort with a dedicated
HTTP client per token-carrying request, so abortable calls set up a fresh
connection instead of reusing the pooled one (≈0.2–0.3 ms per call on
localhost; see `benchmark/overhead.dart`). For the interactive calls in these
apps that cost is invisible; if a hot loop ever needs pooled connections more
than abortability, bind that call without passing the options
(`client.call((_) => client.sdk.<resource>.<method>(...))`) and note why.

Replace ad-hoc token/subscription bookkeeping with fibers:

```dart
Fiber<SessionTurnResult, OpenCodeError>? _turnFiber;

void send(...) {
  _turnFiber = _runtime.fork(effect);
}

Future<void> stopWaiting() => _turnFiber?.interruptAndAwait();
```

## Gotchas

- `CancellationToken` exists in both `effect_core` and
  `opencode_sdk_dart`. Do not reference the name unqualified in files that
  import both; the bridge never requires it.
- `EffectException` wraps non-expected causes; unwrap `cause` for diagnostics.
- Never compose `.retry(...)` on prompts, turns, RPC writes, PTY sends or
  service starts. `withReadRetry` is for reads only.
- `runOpenCode`/`runFuture` after `runtime.shutdown()` throws; create one
  runtime per controller/application lifetime, not per call.
- The bridge exposes the raw client as `client.sdk`; anything not wrapped
  binds through `client.call((options) => client.sdk.<resource>.<method>(...,
  options: options))`.

## Verification

1. `flutter analyze` / `dart analyze` — zero issues.
2. `flutter test` / `dart test` — existing suite green; adapt tests that
   exercised the old controller internals, but do not delete coverage of
   behavior (error surfacing, cancellation, streaming order).
3. If the project has a live smoke path, confirm it still compiles.
4. Report: files changed, patterns used, test/analyze results, gaps found in
   the bridge, and anything intentionally left on the plain SDK with reasons.
