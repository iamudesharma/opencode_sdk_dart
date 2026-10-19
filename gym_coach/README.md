# OpenFit

**OpenFit — your AI strength & nutrition coach.** A responsive Flutter app
(desktop + phone web) that generates typed training plans and food plans with
the free **LongCat 2.5 Preview Free** model running on your local **OpenCode**
server — through the `genkit_opencode_custom` Genkit plugin built in this repo.

```
gym_coach/
├── lib/
│   ├── main.dart                 # OpenFitApp + openFitTheme() (carbon/emerald)
│   └── src/
│       ├── coach_service.dart    # one OpenCode client: plans + persistent Ask Coach session
│       ├── plan.dart             # the typed plan schema (schemantic) + Markdown
│       ├── plan_request.dart     # form inputs → prompt (text and structured)
│       ├── plan_body.dart        # plan-aware text renderer (live text mode)
│       ├── plan_view.dart        # interactive typed plan: completion, rest timer, macro bars
│       ├── coach_chat.dart       # Ask Coach bubbles, streaming, rebuild-with-note
│       ├── history_view.dart     # saved-plan list (desktop dialog + phone tab)
│       ├── attachments.dart      # file picking (file:// on desktop, /_upload on web)
│       ├── plan_store.dart       # history: JSON files on desktop, localStorage on web
│       ├── plan_export.dart      # export to ~/Downloads (desktop) or a download (web)
│       ├── macros.dart           # Mifflin-St Jeor macro calculator
│       ├── style.dart            # spacing/radii scale + shared small widgets
│       └── home_screen.dart      # responsive shell (840 px breakpoint)
├── tool/plan_check.dart          # headless smoke test (text and --typed)
├── web/                          # web target (built for /openfit/)
└── macos/                        # window title/size, sandbox off (local service)
```

## What it does

- **Typed plans** — structured output: the plan comes back as a typed object and
  renders as day chips, an interactive day card, progression, meal cards with
  macro chips, and safety notes.
- **Live text** — the same prompt streamed token by token, styled as it arrives
  (section headings, bullets, bold).
- **Streaming progress** — while a typed plan is drafted the app shows a
  spinner, elapsed time and the characters received, so the wait is visible;
  when it finishes the status line reports tokens and latency.
- **Interactive workout** — tap an exercise (or its checkbox) to mark it done:
  the day header tracks `3/5 done` with a progress bar, and completed rows dim
  with a strikethrough. Every exercise has a **Rest** button that starts a
  countdown chip in the day header (parsed from `rest 90s`, 90 s fallback) with
  a stop action.
- **Macro calculator + bars** — Mifflin-St Jeor → TDEE, goal-adjusted calories
  and protein/fat/carb targets with a *Use in plan* button. When targets are
  applied and the plan has meals, a **Targets vs plan** card compares plan
  totals with the targets as labeled progress bars.
- **Ask Coach** — a persistent chat on the same server session as the plan:
  streamed replies with a caret, collapsible *Thought* reasoning blocks, Send
  and Stop (aborts the turn), attachments, and a **Rebuild plan with this
  note** action that appends the reply to the request notes and re-runs the
  typed plan. Works with or without an existing plan.
- **Attachments** — the paperclip in the notes card and in the Coach composer
  picks a file and shows a removable filename chip; the next plan/chat call
  carries it to the model. On the web the file is uploaded through the LAN
  host's `/_upload` proxy.
- **History** — every completed plan is saved automatically (JSON files under
  `~/Library/Application Support/gym_coach/plans/` on desktop, a JSON array in
  `window.localStorage` on the web). Rows show title/time/model + a typed/text
  badge with Load, Export and Delete.
- **Copy / Export** — copy puts the plan (Markdown) on the clipboard; export
  writes `~/Downloads/gym_coach_plan_<ts>.md` on desktop or downloads the file
  on the web.

## Layouts

The shell switches at **840 px**:

- **Wide (desktop)** — a 360 px config pane (quick-start presets, grouped
  cards, sticky Generate button) next to a workspace with a status line, the
  `Typed plan / Live text` toggle, History/Export/Copy actions, and a
  collapsible **Ask Coach** dock at the bottom.
- **Narrow (phone)** — a slim AppBar (OpenFit, compact status, mode toggle and
  the same actions) with a four-destination `NavigationBar`:
  **Build** (grouped config cards + horizontal preset strip + sticky Generate),
  **Workout** (the plan or live text), **Coach** (chat), and **History**
  (saved plans inline). Touch targets are ≥ 44 px and the layout fits a 390 px
  screen without horizontal overflow.

Streaming never rebuilds the form: elapsed time, streamed text and received
characters live in `ValueNotifier`s rendered by small listeners, and the model
dropdown's entries are memoized per catalog load.

## Running

```bash
cd gym_coach
flutter pub get
flutter run -d macos            # desktop
flutter run -d chrome           # web (dev)
```

Build the web app for the LAN host (served at `/openfit/`):

```bash
flutter build web --release --base-href /openfit/
```

Then start the repo's LAN host from the repository root and open the printed
URL (with a QR code) on your phone — it serves `gym_coach/build/web` under
`/openfit/`, proxies `/api/...` to the local OpenCode service with auth
injected, and accepts attachment uploads on `/_upload`:

```bash
dart run tool/lan_host.dart              # http://<your-ip>:8080/openfit/
dart run tool/lan_host.dart --port 8080 --host 0.0.0.0
```

To point a build at a remote server instead, pass
`--dart-define=OPENCODE_BASE_URL=http://host:4096`. Without it, desktop builds
discover (or start) the local background service and web builds use their own
origin (the LAN host proxies it).

Headless check of the same pipelines (no UI), useful for prompt tuning:

```bash
dart run tool/plan_check.dart                       # streamed text, free LongCat preview
dart run tool/plan_check.dart --typed               # structured output, streamed progress, parsed
dart run tool/plan_check.dart some-other-model-id --typed
```

## Tests

```bash
flutter analyze
flutter test
```

`test/home_screen_test.dart` renders the real theme against a `FakeCoachService`
(no network): typed/live generation, presets, macro calculator + bars, the
narrow `NavigationBar` shell and tab switching, exercise completion, the rest
timer, Ask Coach bubbles/stop/rebuild, and the history dialog/tab.
`test/coach_service_test.dart` drives the real service against a scripted
server: the shared session, turn streaming order and reconciliation,
cancellation through the turn fiber, typed `OpenCodeError` surfacing, and
"writes are never retried". `test/macros_test.dart` and
`test/plan_store_test.dart` cover the calculator math and the file-backed
store.

## How it plugs in

The app contains no HTTP code and no OpenCode protocol code. Everything flows
through the Genkit plugin or — for the chat turn and the shared session — the
effect bridge (`opencode_effect`), which owns the SDK client, gives failures
the typed `OpenCodeError` family, and cancels turns by interrupting a fiber.
Live text mode streams:

```dart
final ai = Genkit(plugins: [openCode(client: sharedClient)]);
final stream = ai.generateStream<String, OpenCodeModelOptions>(
  model: openCode.model('longcat-2.5-preview-free'),
  messages: [
    Message(role: Role.system, content: [TextPart(text: systemPrompt)]),
    Message(role: Role.user, content: [TextPart(text: request.toPrompt())]),
  ],
  cancel: cancellationController.token,              // drives the Stop button
);
```

Typed mode streams the same model with `outputSchema: WorkoutPlan.$schema` on
one persistent server session; the bridge appends the plan schema to the prompt
and Genkit parses the JSON answer, while `onProgress` reports characters as
they arrive:

```dart
final stream = ai.generateStream<WorkoutPlan, OpenCodeModelOptions>(
  model: openCode.model('longcat-2.5-preview-free'),
  messages: [ ... ],
  config: OpenCodeModelOptions(sessionID: coachSessionID),  // shared with chat
  outputSchema: WorkoutPlan.$schema,
  cancel: cancellationController.token,
);
```

Ask Coach reuses the same client and session through the bridge's turn helper,
which sends exactly one prompt per run; the Stop button interrupts the fiber
the turn runs on:

```dart
final exit = await runtime.fork(
  client.runTurn<Unit>(
    sessionID: SessionID(coachSessionID!),
    text: text,
    onEvent: (event) { ... },                          // deltas + reasoning
  ),
).awaitExit();
// Success -> CoachChatDone(result.text, usage: ...)
// Interrupted / cancelled -> CoachChatDone('', cancelled: true)
```

The service closes the shared client, shuts its runtime down and closes the
plugin (`CoachService.dispose`) when the screen that created it goes away.

The app disables the macOS App Sandbox for the same reason `chat_app` does:
reading `~/.local/state/opencode/service.json` and spawning
`opencode serve --service` are both blocked inside the sandbox.

## Notes on the model

`longcat-2.5-preview-free` costs nothing on the OpenCode server but is a
preview model on free capacity: a full plan takes roughly 20-60 seconds in
live text mode (~150-250 chunks) and around 2-3 minutes in typed mode, where
the model writes the whole JSON document before it is parsed. The text prompt
asks for a fixed set of ALL-CAPS section headers so the renderer can style
sections without a markdown dependency; the typed prompt asks for one JSON
object matching the schema.

## Driving the app (debug tooling)

Debug builds initialize `MarionetteBinding` (from `marionette_flutter`) so the
[marionette MCP](https://pub.dev/packages/marionette_mcp) tools can inspect and
drive the running app:

```bash
flutter run -d macos
# copy the VM service URI from the console, e.g.
#   ws://127.0.0.1:51132/8yx5uW5o7WY=/ws
# then connect from an agent and tap "Generate plan", scroll, screenshot, ...
```

Release builds use the plain `WidgetsFlutterBinding`, so none of this ships.
