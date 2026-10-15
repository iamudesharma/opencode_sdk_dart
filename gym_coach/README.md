# Gym Coach

A macOS app that dynamically generates gym plans (and an optional food plan)
with the free **LongCat 2.5 Preview Free** model running on your local
**OpenCode** server — through the `genkit_openai_custom` Genkit plugin built in
this repo.

```
gym_coach/
├── lib/
│   ├── main.dart                 # MaterialApp + dark theme
│   └── src/
│       ├── coach_service.dart    # Genkit + openCode() plugin, streaming API
│       ├── plan_request.dart     # form inputs → prompt
│       ├── plan_body.dart        # plan-aware text renderer
│       └── home_screen.dart      # the two-pane UI
├── tool/plan_check.dart          # headless smoke test (no Flutter UI)
└── macos/                        # window title/size, sandbox off (local service)
```

## What it does

- **Left pane** — goal, experience, days per week, session length, equipment,
  injuries/preferences, and an *Include food plan* switch that adds calories,
  a protein target and a sample day to the output.
- **Right pane** — the plan streams in token by token and is styled as it
  arrives (section headings, bullets, bold). The status line shows the model,
  elapsed time and token usage; there is a copy button and a stop button.
- **Model picker** — search across every model the OpenCode server reports
  (100+), with the free LongCat preview pre-selected.

Preset cards on the empty state (first workout / fat loss + food / hotel room
week) fill the form and start generating immediately.

## How it plugs in

The app contains no HTTP code and no OpenCode protocol code. Everything flows
through the Genkit plugin:

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

Headless check of the same pipeline (no UI), useful for prompt tuning:

```bash
dart run tool/plan_check.dart                       # free LongCat preview
dart run tool/plan_check.dart some-other-model-id
```

## Notes on the model

`longcat-2.5-preview-free` costs nothing on the OpenCode server but is a
preview model on free capacity: a full plan takes roughly 20-60 seconds and
streams in ~150-250 chunks, which is exactly what makes it a good demo for
streaming UI. The prompt asks for a fixed set of ALL-CAPS section headers so
the renderer can style sections without a markdown dependency.

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
