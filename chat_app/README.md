# OpenCode Chat

A Flutter chat client for your OpenCode server — native on macOS, and in any
browser when served by a LAN host — built with
[`opencode_sdk_dart`](../README.md).

![Chat screen](test/previews/chat_screen.png)

## Features

- **Zero-config startup**: discovers the local OpenCode background service
  (`~/.local/state/opencode/service.json`) and starts it when needed, or
  connects to any `http(s)://` server manually.
- **Web + LAN host**: the web build connects to `Uri.base.origin` with
  discovery disabled, so a host that serves the app same-origin and proxies
  the API with auth injection works out of the box. Any platform can be pinned
  to a server with `--dart-define=OPENCODE_BASE_URL=...`.
- **Streaming transcripts**: assistant text, reasoning, tool calls, and turn
  status stream live from the server's event connection — no polling.
- **Markdown rendering**: `#`/`##`/`###` headings, `-`/`*` and `1.` lists,
  `>` blockquotes, `---` rules, fenced code blocks with a language badge and a
  one-click copy button, inline `code`, **bold**, and *italic* — with a
  streaming caret.
- **Tool cards**: live status chip (Preparing / Running / Done / Failed) with
  elapsed seconds while running and the run duration once settled, plus
  monospace input/output blocks with copy buttons.
- **Attachments**: attach a file from the composer. On desktop the absolute
  path is sent; on the web the bytes are posted to the LAN host's same-origin
  `/_upload` endpoint and the returned path is sent.
- **Searchable model picker**: a dialog that filters `provider/model` across
  every enabled model and marks the current one.
- **Light & dark themes**: dark by default, toggle from the header.
- **Responsive layout**: below ~760 px the session sidebar becomes a drawer
  opened from the header; wider windows keep a collapsible sidebar.
- **Session sidebar**: newest-first session list with per-session cost, busy
  spinners, rename/delete, and one-click new chat.
- **Agent & model switching**: pick the agent and model for a session from
  the header.
- **Permission prompts**: `permission.asked` events surface an inline banner
  with Reject / Allow once / Always allow, wired to `permission.reply`.
- **Interrupt & queue**: stop a running turn, or send another message while
  the agent is working (the server steers/queues it).
- **Desktop ergonomics**: Enter to send, Shift+Enter for newlines, ⌘N for a
  new chat, selectable text, auto-scroll that yields when you scroll up and
  snaps (instead of animating) while the last message streams.

## Run it

```sh
cd chat_app
flutter pub get
flutter run -d macos
```

Or build a bundle and launch it:

```sh
flutter build macos --release
open build/macos/Build/Products/Release/opencode_chat.app
```

## Web + LAN host

```sh
flutter run -d chrome --web-port 8090
# Build for a host that serves the app under /chat/:
flutter build web --release --base-href /chat/
```

On the web the connect screen offers **Use this server**, which connects to
the origin that served the app (discovery is not available in browsers). The
LAN host is expected to proxy the OpenCode API on the same origin and expose
`POST /_upload` — raw bytes with an `x-filename` header, returning
`{"path": "..."}` — so composer attachments work.

To pin any build to a specific server, pass the base URL at compile time:

```sh
flutter run -d chrome --dart-define=OPENCODE_BASE_URL=http://192.168.1.20:4096
```

## Tests

```sh
flutter test                          # unit + UI preview tests
flutter test tool/live_chat_check.dart  # live end-to-end against a running server
```

- `test/event_reducer_test.dart` — the event → transcript reducer, driven by
  recorded server event payloads; also covers notification coalescing and the
  theme toggle.
- `test/controller_effect_test.dart` — the controller over the effect bridge
  with a scripted server: typed error surfacing, read retry / write parity,
  event reconnect, and event-fiber cancellation.
- `test/markdown_lite_test.dart` — the markdown-lite parser (headings, lists,
  quotes, rules, code blocks) and rendering (badges, copy button, caret).
- `test/model_picker_test.dart` — the searchable model dialog: filtering
  across providers/models, the empty state, checkmark, and selection.
- `test/ui_preview_test.dart` — renders the app with real macOS fonts and
  writes screenshots to `test/previews/` (chat dark/light/narrow, connect,
  permission banner, model picker); also covers Enter/Shift+Enter composer
  behavior.
- `tool/live_chat_check.dart` — creates a session, prompts it, verifies the
  streamed answer lands in the transcript, then deletes the session.

## Architecture

```text
lib/
  main.dart                     app entry; owns the controller lifecycle
  src/
    app.dart                    MaterialApp shell; light/dark themes, themeMode
    app_theme.dart              theme builder + monospace font stack helpers
    chat_controller.dart        connection, sessions, prompts, event reducer
    chat_models.dart            transcript view models + API decoding
    home_screen.dart            responsive shell, header, model picker dialog
    session_sidebar.dart        session list, rename/delete, connection state
    chat_transcript.dart        message bubbles, reasoning blocks, tool cards
    composer.dart               input box, Enter-to-send, attachments
    attachment_picker.dart      file picking; web upload to /_upload
    copy_button.dart            one-click clipboard copy button
    permission_banner.dart      permission request replies
    connect_screen.dart         discovery / manual connection flow
    markdown_lite.dart          markdown-lite parser and renderer
```

The controller owns one `EffectOpenCodeClient` (from `opencode_effect`) over
a single SDK client, and one effect `Runtime` for its lifetime:

1. `connectLocal` connects to the `OPENCODE_BASE_URL` define when set, the
   serving origin on the web, or the discovered local service
   (`discoverOpenCodeService`/`ensureOpenCodeService`); then reads
   `server.info`, loads sessions/agents/models, and subscribes to the shared
   event stream through `client.events<Unit>().toNative(runtime)`.
2. Calls are effect-bound (`client.call(...)`) and reads compose
   `withReadRetry()` (transient statuses, 3 attempts); writes — prompt
   admission, create/delete/rename, interrupt, permission replies — are never
   retried.
3. Every event is reduced into transcript state: `session.step.started`
   creates the assistant message, `session.text.delta` appends streamed text,
   `session.tool.*` drives tool cards, `session.execution.*` toggles the busy
   indicator and settles the transcript from the API.
4. UI notifications are coalesced to at most one `notifyListeners()` per
   frame (~16 ms) so event bursts do not rebuild the transcript per event.
5. Sending a prompt echoes the user message immediately, then refreshes from
   the API once the server admits it.
6. `dispose` closes the client and shuts the runtime down, stopping every
   forked fiber.

## macOS notes

- The App Sandbox is **disabled** (`macos/Runner/*.entitlements`). A sandboxed
  app cannot read the service registration file or spawn `opencode serve`,
  which the auto-discovery flow needs. If you only ever connect to remote
  servers, you can re-enable the sandbox and add
  `com.apple.security.network.client`.
- The window defaults to 1180×780 (min 420×540); below a ~760 px width the
  sessions sidebar collapses into a drawer.
- The UI uses the platform default font and a Menlo / SF Mono / monospace
  fallback stack for code, so glyphs like ⌘ render everywhere.
