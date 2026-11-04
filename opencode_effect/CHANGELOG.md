## 0.1.0

Initial release.

- One sealed `OpenCodeError` family for expected failures, while foreign
  exceptions stay defects.
- `openCodeCall`, `openCodeTask`, `read`, and `call` bind any SDK resource
  method as a lazy, typed `Effect`.
- Interruption cancels the SDK `CancellationToken` and aborts the in-flight
  request.
- `openCodeClientLayer()` and `openCodeClientService` own the client lifetime
  per scope.
- Pull streams for events, turns, and PTY output with bounded buffering and
  scope-bound cleanup.
- `withReadRetry()` composes the SDK read policy as an effect `Schedule`;
  writes are never retried implicitly.
- Local service discovery, start, and stop as effects.
- Optional per-call abortability and pooled requests via `abortable: false`.
