# Gym Coach

A macOS app that dynamically generates gym plans (and an optional food plan)
with the free **LongCat 2.5 Preview Free** model running on your local
**OpenCode** server — through the `genkit_opencode_custom` Genkit plugin built in
this repo.

```
gym_coach/
├── lib/
│   ├── main.dart                 # MaterialApp + dark theme
│   └── src/
│       ├── coach_service.dart    # Genkit + openCode() plugin, streaming and typed APIs
│       ├── plan.dart             # the typed plan schema (schemantic) + Markdown
│       ├── plan_request.dart     # form inputs → prompt (text and structured)
│       ├── plan_body.dart        # plan-aware text renderer (live text mode)
│       ├── plan_view.dart        # typed plan renderer: day tabs, meals, macros
│       ├── plan_store.dart       # saved-plan history (JSON files on disk)
│       ├── macros.dart           # Mifflin-St Jeor macro calculator
│       └── home_screen.dart      # the two-pane UI
├── tool/plan_check.dart          # headless smoke test (text and --typed)
└── macos/                        # window title/size, sandbox off (local service)
```

## What it does

- **Left pane** — goal, experience, days per week, session length, equipment,
  injuries/preferences, an *Include food plan* switch, a **macro calculator**
  (Mifflin-St Jeor → TDEE, goal-adjusted calories and protein/fat/carb targets,
  with a *Use in plan* button that hands the numbers to the model), and a
  searchable model picker with the free LongCat preview pre-selected.
- **Right pane** — two modes:
  - **Typed plan** (default) — structured output: the plan comes back as a
    typed object and is rendered with day tabs, exercise rows, meal cards with
    calorie/protein chips, progression and safety notes.
  - **Live text** — the original experience: the plan streams in token by
    token and is styled as it arrives (section headings, bullets, bold).
- **History** — every completed plan is saved automatically under
  `~/Library/Application Support/gym_coach/plans/`; the history dialog lists,
  loads and deletes them.
- **Copy / Export** — the copy button puts the plan (Markdown) on the
  clipboard; the export button writes a `.md` file to `~/Downloads`.
- The status line shows the model, elapsed time and token usage; the Stop
  button aborts an in-flight generation in either mode.

Preset cards on the empty state (first workout / fat loss + food / hotel room
week) fill the form and start generating immediately.

## How it plugs in

The app contains no HTTP code and no OpenCode protocol code. Everything flows
through the Genkit plugin. Live text mode streams:

```dart
final ai = Genkit(plugins: [openCode()]);            // local service discovery
final stream = ai.generateStream<String, OpenCodeModelOptions>(
  model: openCode.model('longcat-2.5-preview-free'),
  messages: [
    Message(role: Role.system, content: [TextPart(text: systemPrompt)]),
    Message(role: Role.user, content: [TextPart(text: request.toPrompt())]),
  ],
  cancel: cancellationController.token,              // drives the Stop button
);
```

Typed mode asks the same model for structured output; the bridge appends the
plan schema to the prompt and Genkit parses the JSON answer into `WorkoutPlan`:

```dart
final result = await ai.generate<WorkoutPlan, OpenCodeModelOptions>(
  model: openCode.model('longcat-2.5-preview-free'),
  messages: [ ... ],
  outputSchema: WorkoutPlan.$schema,
  cancel: cancellationController.token,
);
print(result.output!.days.length);   // typed, not parsed by hand
```

`openCode()` discovers (or starts) the background service, lists models with
their real capabilities, streams through an ephemeral session and cleans it up
afterwards. The Stop button aborts the in-flight request.

The app disables the macOS App Sandbox for the same reason `chat_app` does:
reading `~/.local/state/opencode/service.json` and spawning
`opencode serve --service` are both blocked inside the sandbox.

## Running

```bash
cd gym_coach
flutter pub get
flutter run -d macos            # or: open build/macos/.../gym_coach.app
```

Headless check of the same pipelines (no UI), useful for prompt tuning:

```bash
dart run tool/plan_check.dart                       # streamed text, free LongCat preview
dart run tool/plan_check.dart --typed               # structured output, parsed and summarized
dart run tool/plan_check.dart some-other-model-id --typed
```

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
