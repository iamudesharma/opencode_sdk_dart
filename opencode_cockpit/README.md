# OpenCode Cockpit (macOS)

A Flutter desktop **workbench for OpenCode V2** — the CodeNomad-style cockpit,
built entirely on [`opencode_sdk_dart`](../README.md). It exercises the SDK's
deeper capabilities: session trees, worktrees, session diffs, the filesystem
API, VCS endpoints, git worktrees, plugin-event streaming, and **real PTY
terminals over the SDK's WebSocket helpers**.

![Sessions](test/previews/cockpit_sessions.png)
![Terminal](test/previews/cockpit_terminal.png)
![Git](test/previews/cockpit_git.png)

## Features

**Workspace**

- **Project tabs** from `project.list()` — every project is a tab; sessions,
  files, git, and new sessions are scoped to the active project's location.
- **Session tree** — roots via `parentID: null`, lazily expanded sub-sessions,
  search by title/id, rename, fork (`session.fork`), delete, and per-session
  cost.
- **Activity rail** — Sessions / Files / Git / Statistics, plus toggles for the
  terminal and the changes inspector.
- **Command palette** (⌘K), light/dark themes (⌘⇧I), connection status bar.

**Conversation**

- Streaming transcript from the live event stream: text, reasoning, tool cards
  (status, streamed input, result preview), notices, errors, per-turn tokens
  and cost.
- **Large transcripts**: the server cursor paginates history with a
  "Load earlier messages" affordance; messages dedupe on append.
- **Inbox strip**: queued and steering prompts are visible while a turn runs,
  with cancel and steer/queue delivery switching (`session.inbox.*`).
- **Agent forms**: when the agent asks a structured question
  (`form.created`), a badge opens a rendered form — dropdowns, numbers,
  toggles, multiselect chips, conditional fields, and external approval
  links — submitted via `session.form.reply`.
- **Export / import**: write a session transcript as pretty JSON
  (`session.exportSession`) or import one from disk (`session.importSession`).
- Agent and model switching from the header (`session.switchAgent` /
  `switchModel`).
- Composer with Enter-to-send, Shift+Enter newline, interrupt, queue-while-busy,
  and **`@` file references** backed by `filesystem.find`.
- Permission prompts inline (`permission.asked` → Reject / Allow once /
  Always allow via `permission.reply`).

**Files**

- Directory browser via `filesystem.list` with breadcrumbs.
- Inspector with a line-numbered text viewer, image preview, binary detection,
  and "insert `@reference`" into the prompt.

**Git**

- Branch header (`vcs.get`), uncommitted changes (`vcs.status`) with +/-
  counts, branch list (`vcs.branchList`), and **worktree management**
  (`worktree.list/create/remove`).
- Unified **diff viewer** with colored hunks for working-copy diffs
  (`vcs.diff`) and for the session's own changes (`session.diff`).

**Terminal**

- Real PTY sessions: `pty.create` → ticket handshake →
  `PtySocket.frames` stream (`PtyOutput` / `PtyCursor`) → xterm emulation.
- ANSI colors, interactive input, debounced resize through `pty.update`,
  resume cursors, restart/start-fresh controls, and clean shutdown on exit.
- **Persistent terminals** (`persistentPty.*`): session-scoped shells that
  survive app restarts. The cockpit lists, creates, attaches, snapshots, and
  kills them, and speaks the server's `input_protocol=1` framing
  (`PtyInputFrames`: 5-byte header with type + cols/rows per frame) so
  keystrokes and resizes travel together.

**Connections and settings**

- MCP tab: list servers with status chips, connect/disconnect/remove, and add
  local or remote servers (`mcp.*`).
- Plugins tab: inventory with update checks and bulk updates (`plugin.*`).
- Config tab: effective configuration entries, shell selection
  (`config.update`), and configuration reload (`location.reload`).

**Statistics**

- `session.stats` dashboard: sessions, prompts, steps, tokens, cost, streak,
  tool reliability bars, and a 21-day activity chart.

## Run it

```sh
cd opencode_cockpit
flutter pub get
flutter run -d macos
```

Or build and open the bundle:

```sh
flutter build macos --release
open build/macos/Build/Products/Release/opencode_cockpit.app
```

## Tests

```sh
flutter test                            # reducer, tree, references, previews
flutter test tool/live_cockpit_check.dart  # live end-to-end (needs a server)
```

- `test/cockpit_controller_test.dart` — event reducer, session tree filtering,
  permissions, busy tracking, `@` reference insertion, theme toggle.
- `test/ui_preview_test.dart` — renders eight screens with real macOS fonts and
  writes them to `test/previews/`.
- `test/cockpit_integration_test.dart` — drives the controller against a
  mocked server: connect, inbox cancel/delivery, form reply payloads, older
  message pagination with dedupe, and export/import round trips.
- `tool/live_cockpit_check.dart` — connects to the real service and verifies
  projects, session tree, file listing/reading, file search, git state,
  session diff/inbox/forms, statistics, a live terminal echo
  (`COCKPIT_PTY_OK`), transcript export, and a full persistent-terminal
  lifecycle including framed input and cleanup.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| ⌘K | Command palette |
| ⌘N | New session |
| ⌘J | Toggle terminal |
| ⌘⇧I | Toggle light/dark theme |
| Enter | Send |
| Shift+Enter | Newline |
| Esc | Close the mention popup / palette |

The palette also reaches Persistent terminals, Connections and settings,
Load older messages, Export/Import session, and Pending forms.

## Architecture

```text
lib/
  main.dart                       app entry, controller lifecycle
  src/
    app.dart                      MaterialApp + themes
    shell.dart                    top bar, activity rail, layout, status bar
    cockpit_controller.dart       connection, projects, sessions, panels,
                                  live event reducer, palette commands
    models.dart                   transcript view models + API decoding
    terminal_session.dart         PTY lifecycle + xterm binding
    services/persistent_terminal.dart
                                  persistent PTY lifecycle + framed input
    markdown_lite.dart            code-aware markdown renderer
    theme.dart                    dark/light palettes
    widgets/                      transcript, composer, explorers, panels,
                                  diff view, terminal, palette, inspector
```

The controller mirrors the reference client's event semantics (the same
reducer as `chat_app`, extended with project/session-tree/panel state), while
panels call the generated resources directly for pull-based data (files, git,
stats, diffs).

## Notes

- The App Sandbox is disabled (same rationale as `chat_app`): the app reads the
  service registration file and may start `opencode serve`.
- PTY sessions are scoped to a location; the cockpit always passes the active
  project's directory to `pty.create`, `pty.update`, `pty.remove`, and the
  WebSocket handshake, and disposes them on exit.
- `xterm` (MIT) provides the terminal emulation and rendering.
