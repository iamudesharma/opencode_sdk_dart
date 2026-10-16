import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_cockpit/src/app.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/models.dart';
import 'package:opencode_cockpit/src/services/persistent_terminal.dart';
import 'package:opencode_cockpit/src/shell.dart';
import 'package:opencode_cockpit/src/terminal_session.dart';
import 'package:opencode_cockpit/src/theme.dart';
import 'package:opencode_cockpit/src/widgets/connections_dialog.dart';
import 'package:opencode_cockpit/src/widgets/inspector.dart';
import 'package:opencode_cockpit/src/widgets/session_explorer.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Loads real macOS fonts so preview screenshots are readable.
///
/// The cockpit theme uses the platform default family (Roboto in the test
/// engine) plus a Menlo / SF Mono / monospace stack, so the previews register
/// real glyphs under exactly those names (⌘ included).
Future<void> loadSystemFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    var loaded = false;
    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      loaded = true;
    }
    if (loaded) await loader.load();
  }

  Future<void> loadFirst(String family, List<String> candidates) async {
    for (final path in candidates) {
      if (!File(path).existsSync()) continue;
      await load(family, [path]);
      return;
    }
  }

  await loadFirst('Roboto', const [
    '/System/Library/Fonts/SFNS.ttf',
    '/System/Library/Fonts/Supplemental/Arial.ttf',
  ]);
  await loadFirst('Menlo', const [
    '/System/Library/Fonts/SFNSMono.ttf',
    '/System/Library/Fonts/Supplemental/Courier New.ttf',
  ]);
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ?? _flutterRootFromPath();
  if (flutterRoot != null) {
    await load('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  }
}

String? _flutterRootFromPath() {
  final executable = Platform.resolvedExecutable;
  final marker = '/bin/cache/dart-sdk/';
  final index = executable.indexOf(marker);
  if (index == -1) return null;
  return executable.substring(0, index);
}

final previewKey = GlobalKey();

Future<void> pumpCockpit(
  WidgetTester tester,
  CockpitController controller,
) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: previewKey,
      child: CockpitApp(controller: controller),
    ),
  );
  await tester.pump(const Duration(milliseconds: 80));
}

Future<void> capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(previewKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.4);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('test/previews');
    directory.createSync(recursive: true);
    File('${directory.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadSystemFonts);

  testWidgets('cockpit sessions view', (tester) async {
    final controller = seededController();
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_sessions');
    controller.dispose();
  });

  testWidgets('cockpit files and viewer', (tester) async {
    final controller = seededController()
      ..selectExplorerTab(ExplorerTab.files)
      ..referenceCandidates = const []
      ..showInspector(InspectorTab.file);
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_files');
    controller.dispose();
  });

  testWidgets('cockpit git diff view', (tester) async {
    final controller = seededController()
      ..selectExplorerTab(ExplorerTab.git)
      ..referenceCandidates = const [];
    // Seed synchronously for the preview (no server in tests).
    controller
      ..vcsInfo = VcsInfo.fromJson({
        'provider': 'git',
        'branch': {'current': 'feat/streaming', 'default': 'main'},
      })
      ..gitChanges = [
        VcsFileStatus.fromJson({
          'file': 'lib/src/session_store.dart',
          'additions': 18,
          'deletions': 4,
          'status': 'modified',
        }),
        VcsFileStatus.fromJson({
          'file': 'test/session_store_test.dart',
          'additions': 42,
          'deletions': 0,
          'status': 'added',
        }),
      ]
      ..gitDiffFiles = [demoDiff()]
      ..branches = const ['main', 'feat/streaming', 'fix/parser']
      ..worktrees = [
        WorktreeDirectory.fromJson({
          'directory': '/Users/dev/projects/acme',
          'strategy': 'checkout',
        }),
        WorktreeDirectory.fromJson({
          'directory': '/Users/dev/projects/acme-wt-streaming',
          'strategy': 'git',
        }),
      ]
      ..gitChanges = controller.gitChanges
      ..inspectFileDiff('lib/src/session_store.dart');
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_git');
    controller.dispose();
  });

  testWidgets('cockpit session changes inspector', (tester) async {
    final controller = seededController()..referenceCandidates = const [];
    controller
      ..sessionChanges = [
        demoDiff(),
        FileDiffInfo.fromJson({
          'file': 'test/session_store_test.dart',
          'patch':
              'diff --git a/test/session_store_test.dart '
              'b/test/session_store_test.dart\n'
              'new file mode 100644\n'
              '@@ -0,0 +1,6 @@\n'
              '+import \'package:test/test.dart\';\n'
              '+\n'
              '+void main() {\n'
              '+  test(\'resumes\', () {});\n'
              '+}\n',
          'additions': 6,
          'deletions': 0,
          'status': 'added',
        }),
      ]
      ..showInspector(InspectorTab.changes);
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_changes');
    controller.dispose();
  });

  testWidgets('cockpit terminal drawer', (tester) async {
    final controller = seededController()..referenceCandidates = const [];
    controller.terminal = fakeTerminal();
    controller.terminalVisible = true;
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_terminal');
    controller.dispose();
  });

  testWidgets('cockpit command palette', (tester) async {
    final controller = seededController()
      ..referenceCandidates = const []
      ..showPalette();
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_palette');
    controller.dispose();
  });

  testWidgets('cockpit statistics panel', (tester) async {
    final controller = seededController()
      ..referenceCandidates = const []
      ..selectExplorerTab(ExplorerTab.stats)
      ..stats = SessionStatsInfo.fromJson({
        'range': {'from': 1789344000000.0, 'to': 1791936000000.0},
        'sessions': 128,
        'subagents': 42,
        'prompts': 512,
        'steps': 2140,
        'tokens': {
          'input': 4820000,
          'output': 380000,
          'reasoning': 92000,
          'cache': {'read': 1200000, 'write': 45000},
        },
        'cost': 42.5,
        'tools': {
          'mode': 'detail',
          'totals': {
            'calls': 932,
            'succeeded': 884,
            'failed': 31,
            'unfinished': 17,
          },
          'usage': [
            {
              'name': 'bash',
              'calls': 402,
              'succeeded': 388,
              'failed': 10,
              'unfinished': 4,
              'durationP50': 320.0,
            },
            {
              'name': 'read',
              'calls': 271,
              'succeeded': 268,
              'failed': 2,
              'unfinished': 1,
              'durationP50': 12.0,
            },
            {
              'name': 'edit',
              'calls': 168,
              'succeeded': 152,
              'failed': 12,
              'unfinished': 4,
              'durationP50': 45.0,
            },
            {
              'name': 'grep',
              'calls': 91,
              'succeeded': 76,
              'failed': 7,
              'unfinished': 8,
              'durationP50': 88.0,
            },
          ],
        },
        'activeDays': 24,
        'streak': 9,
        'activity': [
          for (var day = 0; day < 21; day++)
            {
              'date': '2026-09-${24 + day}',
              'steps': (day * 7) % 23 + (day % 5) * 4,
            },
        ],
        'models': <Object?>[],
      });
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_stats');
    controller.dispose();
  });

  testWidgets('cockpit persistent terminals', (tester) async {
    final info = persistentInfo();
    final controller = seededController()
      ..referenceCandidates = const []
      ..selectExplorerTab(ExplorerTab.terminals)
      ..persistentTerminals = [info]
      ..selectedPersistentID = info.id
      ..persistentTerminalSession = fakePersistentSession(info)
      ..terminalVisible = true;
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_terminals');
    controller.dispose();
  });

  testWidgets('cockpit inbox strip', (tester) async {
    final controller = seededController()
      ..referenceCandidates = const []
      ..inboxItems = [
        SessionInboxInfo.fromJson({
          'type': 'user',
          'id': 'inbox_1',
          'sessionID': 'ses_preview',
          'time': {'created': 1},
          'payload': {'text': 'Also update the changelog when done.'},
          'delivery': 'queue',
        }),
        SessionInboxInfo.fromJson({
          'type': 'user',
          'id': 'inbox_2',
          'sessionID': 'ses_preview',
          'time': {'created': 2},
          'payload': {'text': 'And run the analyzer afterwards.'},
          'delivery': 'steer',
        }),
      ];
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_inbox');
    controller.dispose();
  });

  testWidgets('cockpit agent form dialog', (tester) async {
    final controller = seededController()
      ..referenceCandidates = const []
      ..sessionForms = [
        FormInfo.fromJson({
          'id': 'form_1',
          'sessionID': 'ses_preview',
          'title': 'Deploy the fix',
          'fields': <Object?>[],
        }),
      ]
      ..activeForm = FormDetail.fromJson({
        'id': 'form_1',
        'sessionID': 'ses_preview',
        'title': 'Deploy the fix',
        'state': {'status': 'pending'},
        'fields': [
          {
            'type': 'string',
            'key': 'environment',
            'title': 'Target environment',
            'description': 'Where should the fix be deployed?',
            'required': true,
            'options': [
              {'value': 'staging', 'label': 'Staging'},
              {'value': 'production', 'label': 'Production'},
            ],
          },
          {
            'type': 'boolean',
            'key': 'runSmokeTests',
            'title': 'Run smoke tests after deploy',
            'default': true,
          },
          {
            'type': 'multiselect',
            'key': 'notify',
            'title': 'Notify',
            'options': [
              {'value': 'slack', 'label': '#eng-releases'},
              {'value': 'email', 'label': 'Release list'},
            ],
          },
          {
            'type': 'external',
            'key': 'approval',
            'title': 'Manager approval',
            'url': 'https://approvals.example.com/req/8123',
          },
        ],
      });
    await pumpCockpit(tester, controller);
    final context = tester.element(find.byType(CockpitShell));
    showFormDialog(context, controller);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await capture(tester, 'cockpit_form');
    controller.dispose();
  });

  testWidgets('cockpit connections dialog', (tester) async {
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://127.0.0.1:49374'),
      httpClient: MockClient((request) async {
        final path = request.url.path;
        Object body = <String, Object?>{};
        if (path == '/api/mcp') {
          body = {
            'location': {'directory': '/workspace'},
            'data': [
              {
                'name': 'playwright',
                'status': {'status': 'connected'},
              },
              {
                'name': 'github',
                'status': {'status': 'needs_auth', 'error': 'token expired'},
              },
              {
                'name': 'sqlite',
                'status': {'status': 'disabled'},
              },
            ],
          };
        } else if (path == '/api/plugin') {
          body = {
            'location': {'directory': '/workspace'},
            'data': [
              {
                'name': 'opencode-acme-plugin',
                'source': {'type': 'builtin'},
                'state': {'status': 'active'},
              },
            ],
          };
        } else if (path == '/api/config') {
          body = [
            {
              'type': 'document',
              'path': '~/.config/opencode/opencode.json',
              'info': {
                'model': 'opencode-go/gemini-4-argon-contributor',
                'agents': <String, Object?>{},
                'permissions': <Object?>[],
                'policies': <Object?>[],
                'update': 'auto',
                'share': 'manual',
                'enterprise': <String, Object?>{},
              },
            },
            {'type': 'directory', 'path': '.opencode'},
          ];
        } else if (path == '/api/config/shell') {
          body = [
            {'path': '/bin/zsh', 'name': 'zsh', 'acceptable': true},
            {'path': '/bin/bash', 'name': 'bash', 'acceptable': true},
          ];
        } else if (path == '/api/location') {
          body = {'directory': '/workspace'};
        }
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      RepaintBoundary(
        key: previewKey,
        child: MaterialApp(
          theme: buildCockpitTheme(Brightness.dark),
          home: Scaffold(
            body: Center(child: ConnectionsDialog(client: client)),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await capture(tester, 'cockpit_connections');
    client.close();
  });

  testWidgets('cockpit light theme', (tester) async {
    final controller = seededController()
      ..referenceCandidates = const []
      ..toggleTheme();
    await pumpCockpit(tester, controller);
    await capture(tester, 'cockpit_light');
    controller.dispose();
  });

  testWidgets('cockpit narrow layout collapses into drawers', (tester) async {
    final controller = seededController()..referenceCandidates = const [];
    tester.view.physicalSize = const Size(880, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      RepaintBoundary(
        key: previewKey,
        child: CockpitApp(controller: controller),
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));

    // Below the breakpoint the rail + explorer live in the drawer.
    expect(find.byType(SessionExplorer), findsNothing);
    expect(find.byTooltip('Menu'), findsOneWidget);
    await capture(tester, 'cockpit_narrow');

    await tester.tap(find.byTooltip('Menu'));
    // The composer keeps a blinking cursor, so settle with bounded pumps.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SessionExplorer), findsOneWidget);

    // Picking a rail destination closes the drawer again.
    await tester.tap(find.byTooltip('Git'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SessionExplorer), findsNothing);

    // The inspector opens as the end drawer on narrow layouts.
    await tester.tap(find.byTooltip('Review changes in this session'));
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(InspectorPanel), findsOneWidget);
    controller.dispose();
  });
}

FileDiffInfo demoDiff() => FileDiffInfo.fromJson({
  'file': 'lib/src/session_store.dart',
  'patch':
      'diff --git a/lib/src/session_store.dart '
      'b/lib/src/session_store.dart\n'
      'index 4af1c2e..9b3d7f1 100644\n'
      '--- a/lib/src/session_store.dart\n'
      '+++ b/lib/src/session_store.dart\n'
      '@@ -18,9 +18,15 @@ class SessionStore {\n'
      '   Future<List<Message>> load(String id) async {\n'
      '-    final snapshot = await _db.read(id);\n'
      '-    return snapshot.messages;\n'
      '+    final stream = watch(id);\n'
      '+    final messages = <Message>[];\n'
      '+    await for (final batch in stream) {\n'
      '+      messages.addAll(batch);\n'
      '+    }\n'
      '+    return messages;\n'
      '   }\n'
      '+\n'
      '+  Stream<List<Message>> watch(String id) =>\n'
      '+      _db.watch(id).map(_decodeBatch);\n'
      ' }\n',
  'additions': 18,
  'deletions': 4,
  'status': 'modified',
});

PersistentPtyInfo persistentInfo() => PersistentPtyInfo.fromJson({
  'id': 'pty_persist_01',
  'title': 'shell 18:42',
  'command': '/bin/zsh',
  'args': <String>[],
  'cwd': '/Users/dev/projects/acme',
  'status': 'running',
  'pid': 40518,
  'sessionID': 'ses_preview',
  'size': {'cols': 120, 'rows': 30},
  'output': {'head': 0, 'tail': 0},
});

PersistentTerminalSession fakePersistentSession(PersistentPtyInfo info) {
  final session = PersistentTerminalSession()
    ..status = PersistentTerminalStatus.attached
    ..info = info
    ..cursor = 8192;
  session.terminal.write(
    '\x1b[38;5;75;1m~/projects/acme\x1b[0m '
    '\x1b[38;5;244mfeat/streaming\x1b[0m \$ dart test\r\n',
  );
  session.terminal.write('\x1b[38;5;82mAll tests passed (12 tests)\x1b[0m\r\n');
  session.terminal.write(
    '\x1b[38;5;75;1m~/projects/acme\x1b[0m '
    '\x1b[38;5;244mfeat/streaming\x1b[0m \$ \x1b[7m \x1b[0m',
  );
  return session;
}

TerminalSession fakeTerminal() {
  final session = TerminalSession()
    ..status = TerminalStatus.running
    ..ptyID = PtyID('pty_demo_01')
    ..cursor = 2048;
  session.terminal.write(
    '\x1b[38;5;245mLast login: today on ttys002\x1b[0m\r\n',
  );
  session.terminal.write(
    '\x1b[38;5;75;1m~/projects/acme\x1b[0m '
    '\x1b[38;5;244mfeat/streaming\x1b[0m \$ dart test test/session_store_test.dart\r\n',
  );
  session.terminal.write('00:01 +0: loading test/session_store_test.dart\r\n');
  session.terminal.write(
    '\x1b[38;5;82m00:02 +4: resumes from a stored cursor\x1b[0m\r\n',
  );
  session.terminal.write('\x1b[38;5;82m00:02 +8: All tests passed!\x1b[0m\r\n');
  session.terminal.write(
    '\x1b[38;5;75;1m~/projects/acme\x1b[0m '
    '\x1b[38;5;244mfeat/streaming\x1b[0m \$ git status --short\r\n',
  );
  session.terminal.write(' M lib/src/session_store.dart\r\n');
  session.terminal.write('?? test/session_store_test.dart\r\n');
  session.terminal.write(
    '\x1b[38;5;75;1m~/projects/acme\x1b[0m '
    '\x1b[38;5;244mfeat/streaming\x1b[0m \$ \x1b[7m \x1b[0m',
  );
  return session;
}

CockpitController seededController() {
  final controller = CockpitController()
    ..connection = CockpitConnection.connected
    ..serverVersion = '2.0.28'
    ..baseUrl = Uri.parse('http://127.0.0.1:49374');

  final acme = Project.fromJson({
    'id': 'prj_acme',
    'canonical': '/Users/dev/projects/acme',
    'name': 'acme',
    'commands': <String, Object?>{},
    'sandboxes': <Object?>[],
    'time': {'created': 1, 'updated': 2, 'active': 3},
  });
  final tooling = Project.fromJson({
    'id': 'prj_tools',
    'canonical': '/Users/dev/projects/internal-tools',
    'name': 'internal-tools',
    'commands': <String, Object?>{},
    'sandboxes': <Object?>[],
    'time': {'created': 1, 'updated': 2, 'active': 3},
  });
  controller
    ..projects = [acme, tooling]
    ..activeProject = acme
    ..agents = [
      AgentInfo.fromJson({
        'id': 'build',
        'name': 'Build',
        'request': {
          'settings': <String, Object?>{},
          'headers': <String, Object?>{},
          'body': <String, Object?>{},
        },
        'mode': 'primary',
        'hidden': false,
        'permissions': [
          {'action': '*', 'resource': '*', 'effect': 'allow'},
        ],
      }),
    ]
    ..models = [
      ModelInfo.fromJson({
        'id': 'gemini-4-argon-contributor',
        'modelID': 'gemini-4-argon-contributor',
        'providerID': 'opencode-go',
        'family': 'gemini',
        'name': 'Gemini 4 Argon Contributor',
        'settings': <String, Object?>{},
        'capabilities': {
          'tools': true,
          'input': ['text'],
          'output': ['text'],
        },
        'variants': [
          {'id': 'low', 'settings': <String, Object?>{}},
        ],
        'time': {'released': 1791849600000.0},
        'cost': [
          {
            'input': 4.0,
            'output': 20.0,
            'cache': {'read': 0.2, 'write': 0.0},
          },
        ],
        'status': 'active',
        'enabled': true,
        'limit': {'context': 1048576, 'output': 65536},
      }),
    ];

  final root = _session(
    'ses_root',
    title: 'Refactor the session store for streaming',
    agent: 'build',
  );
  final child = _session(
    'ses_child',
    title: 'Explore the cursor pagination options',
    parentID: 'ses_root',
  );
  final other = _session('ses_other', title: 'Fix flaky parser test');

  controller
    ..rootSessions = [
      SessionNode(root)
        ..children.addAll([SessionNode(child, depth: 1)])
        ..expanded = true
        ..childrenLoaded = true,
      SessionNode(other),
      SessionNode(_session('ses_docs', title: 'Write release notes')),
    ]
    ..activeSession = root
    ..usage[root.id] = (
      cost: MoneyUSD(0.0421),
      tokens: TokenUsageInfo.fromJson({
        'input': 12400,
        'output': 830,
        'reasoning': 120,
        'cache': {'read': 0, 'write': 0},
      }),
    )
    ..messages = demoTranscript()
    ..fileEntries = [
      FileSystemEntry.fromJson({'path': 'lib/main.dart', 'type': 'file'}),
      FileSystemEntry.fromJson({'path': 'lib/src', 'type': 'directory'}),
      FileSystemEntry.fromJson({'path': 'lib/widgets', 'type': 'directory'}),
      FileSystemEntry.fromJson({'path': 'lib/theme.dart', 'type': 'file'}),
    ]
    ..selectedFilePath = 'lib/src/session_store.dart'
    ..selectedFileText = _demoSource()
    ..fileRoot = 'lib'
    ..referenceCandidates = [
      FileSystemEntry.fromJson({'path': 'lib/main.dart', 'type': 'file'}),
      FileSystemEntry.fromJson({
        'path': 'lib/src/session_store.dart',
        'type': 'file',
      }),
    ]
    ..referenceQuery = 'main';
  controller.composer.text = '@main';
  return controller;
}

SessionInfo _session(
  String id, {
  String? title,
  String? parentID,
  String? agent,
}) => SessionInfo.fromJson({
  'id': id,
  'projectID': 'prj_acme',
  'cost': 0.01,
  'tokens': {
    'input': 200,
    'output': 30,
    'reasoning': 0,
    'cache': {'read': 0, 'write': 0},
  },
  'time': {
    'created': DateTime.now().millisecondsSinceEpoch.toDouble() - 7200000,
    'updated': DateTime.now().millisecondsSinceEpoch.toDouble() - 60000,
  },
  'location': {'directory': '/Users/dev/projects/acme'},
  'title': ?title,
  'parentID': ?parentID,
  'agent': ?agent,
  'model': ?(agent == null
      ? null
      : {'id': 'gemini-4-argon-contributor', 'providerID': 'opencode-go'}),
});

String _demoSource() => '''
import 'dart:async';

/// Loads and streams session transcripts.
class SessionStore {
  SessionStore(this._db);

  final Database _db;

  Future<List<Message>> load(String id) async {
    final stream = watch(id);
    final messages = <Message>[];
    await for (final batch in stream) {
      messages.addAll(batch);
    }
    return messages;
  }

  Stream<List<Message>> watch(String id) =>
      _db.watch(id).map(_decodeBatch);
}
''';

List<ChatMessage> demoTranscript() => [
  ChatMessage(
    id: 'msg_user_1',
    role: ChatRole.user,
    time: DateTime.now().subtract(const Duration(minutes: 6)),
    text:
        'Refactor the session store so it streams updates. '
        'Keep the public API stable and add a regression test for '
        'cursor resumption.',
  ),
  ChatMessage(
    id: 'msg_assistant_1',
    role: ChatRole.assistant,
    time: DateTime.now().subtract(const Duration(minutes: 5)),
    agent: 'build',
    model: ModelRef(
      id: 'gemini-4-argon-contributor',
      providerID: ProviderID('opencode-go'),
    ),
    cost: MoneyUSD(0.0421),
    tokens: TokenUsageInfo.fromJson({
      'input': 12400,
      'output': 830,
      'reasoning': 120,
      'cache': {'read': 0, 'write': 0},
    }),
    finish: 'stop',
    parts: [
      ChatReasoningPart(
        text:
            'The store loads everything eagerly today. I will add a '
            'watch() stream, keep load() as a thin wrapper, and cover '
            'cursor resumption with a test.',
        done: true,
      ),
      ChatTextPart(
        text:
            'I added a streaming `watch` helper and kept `load` as a '
            'compatibility wrapper.',
        done: true,
      ),
      ChatToolPart(
        id: 'tool_read',
        name: 'read',
        status: ChatToolStatus.completed,
        inputJson: {'path': 'lib/src/session_store.dart'},
        output: "import 'dart:async';\n\nclass SessionStore { ...",
      ),
      ChatToolPart(
        id: 'tool_edit',
        name: 'edit',
        status: ChatToolStatus.completed,
        inputJson: {
          'path': 'lib/src/session_store.dart',
          'old': 'return snapshot.messages;',
        },
        output: 'Applied 1 edit (+18 -4)',
      ),
      ChatToolPart(
        id: 'tool_test',
        name: 'bash',
        status: ChatToolStatus.completed,
        inputJson: {'command': 'dart test test/session_store_test.dart'},
        output: 'All tests passed! (12 tests)',
      ),
      ChatTextPart(
        text:
            'The stream reuses the existing cursor:\n\n'
            '```dart\n'
            'final stream = store.watch(sessionID);\n'
            'await for (final batch in stream) {\n'
            '  apply(batch);\n'
            '}\n'
            '```\n\n'
            'Run `dart test` to verify the regression test.',
        done: true,
      ),
    ],
  ),
  ChatMessage(
    id: 'msg_notice',
    role: ChatRole.notice,
    time: DateTime.now().subtract(const Duration(minutes: 4)),
    text: 'Turn finished',
    notice: 'Turn finished',
  ),
  ChatMessage(
    id: 'msg_user_2',
    role: ChatRole.user,
    time: DateTime.now().subtract(const Duration(minutes: 2)),
    text:
        '@lib/main.dart wire the store into the app shell and report '
        'the total cost in the status bar.',
  ),
  ChatMessage(
    id: 'msg_assistant_2',
    role: ChatRole.assistant,
    time: DateTime.now().subtract(const Duration(seconds: 20)),
    agent: 'build',
    model: ModelRef(
      id: 'gemini-4-argon-contributor',
      providerID: ProviderID('opencode-go'),
    ),
    streaming: true,
    parts: [
      ChatTextPart(
        text:
            'Wiring the store into the shell now and reading the '
            'session usage after each turn',
        done: false,
      ),
    ],
  ),
];
