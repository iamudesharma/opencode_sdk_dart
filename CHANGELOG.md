## 0.2.0

Refreshed from the latest OpenCode V2 OpenAPI 3.1 contract: 813 declarations,
170 operations, 32 resource groups, and 501 schemas.

New API surface:

- Experimental artifacts (`client.experimental.artifacts`), schedules
  (`client.experimental.schedule`), background jobs
  (`client.experimental.jobList`), media blobs
  (`client.experimental.mediaGet`), and usage limits
  (`client.usage.limits`).
- Voice models and server-brokered voice sessions (`client.voice`).
- Text, image, and decision generation
  (`client.generate.text`, `image`, and `decisions`); the legacy
  `/api/experimental/generate` endpoint remains available as
  `client.generate.textLegacy`.
- Client MCP endpoints (`client.mcp.client`), a client-hosted MCP WebSocket
  helper (`client.mcp.connectClientSocket(...)`), filesystem watch/unwatch,
  plugin GUI bundles (`client.plugin.gui`), heap dumps
  (`client.debug.heapDump`), and saved-permission updates
  (`client.permission.saved.update`).
- Event type filtering:
  `client.event.subscribe(types: ['session.*', 'rpc.*'])`. Filtering happens
  locally over the shared connection, and the `server.connected` marker is
  always delivered.
- Durable event log plus new event schemas for session status, idle,
  inbox, execution, step, tool, compaction, revert, usage, TUI, filesystem,
  artifact, installation, VCS, and MCP updates.
- Model types (`chat`, `decision`, `image`), freeform tool formats, provider
  cache/TLS settings, media-input and streaming-usage capabilities, session
  archive filters, typed `parentID`, PTY titles/user titles, and
  `LocationRef.workspaceID`.

Breaking changes:

- Assistant message parts now expose `native` instead of provider-state fields;
  compaction messages no longer carry `recent`.
- `Credential.Key.configuration` was removed by the contract.
- `Location.PublicRef` became `Location.Ref`; the SDK keeps the hand-written
  `LocationRef` and adds `workspaceID`.
- Experimental generate and persistent-PTY operation IDs were renamed.
- Removed `Event.SeqEncoded`, `PersistentPty.ReadLinesEncoded`,
  `Form.Fields_2/3`, and the `Session.ProviderContext*` schemas.
- `session.list(parentID:)` is now `String?` because the wire type accepts a
  session ID or the literal `"null"` root-session sentinel.
- `model.list(types:)` is now `List<String>?` and repeats the query key.

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
- One-call session turns: `client.streamPrompt(...)` streams text and reasoning
  deltas, falls back to `session.wait` polling when the live-only event stream
  drops, and reconciles the final answer with the server's record.
- Cursor pagination helpers: `session.listAll(...)` and
  `session.message.listAll(...)` follow `cursor.next` until it runs out.
- Opt-in `RetryPolicy` for transient transport failures, configurable on the
  transport or per request, with `Retry-After` support and idempotent-only
  defaults.
- Unit test suite (87 tests) plus a live read-only smoke test.
