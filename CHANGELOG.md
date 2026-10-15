## 0.1.0

Initial release.

- Generated from the OpenCode V2 OpenAPI 3.1 contract (438 declarations,
  142 operations, 28 resources).
- Sealed unions, branded `extension type` scalars, and wire-mapped enums.
- Structured `_tag` error decoding with HTTP status codes.
- Shared lazy event multiplexer with `server.connected` replay and capacity
  protection.
- Plugin RPC calls, streaming subscriptions, and sequential callback
  subscriptions.
- PTY and persistent PTY WebSocket helpers.
- Local background service discovery, startup, stop, version constraints, and
  persistent-terminal handoff.
- Request cancellation via `CancellationToken`.
- Unit test suite (72 tests) plus a live read-only smoke test.

- The macOS clients grew a full workbench: agent forms, inbox steering,
  transcript pagination, session export/import, MCP/plugin/config management,
  persistent terminals with the `input_protocol=1` framing (`PtyInputFrames`),
  and a mocked-server integration suite.
