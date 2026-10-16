import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:opencode_chat/src/app.dart';
import 'package:opencode_chat/src/chat_controller.dart';
import 'package:opencode_chat/src/chat_models.dart';
import 'package:opencode_chat/src/composer.dart';

/// The family previews load real macOS fonts into (widget tests otherwise
/// draw text with the built-in box font).
const String previewFontFamily = 'FlutterTest';

/// Loads real macOS fonts so preview screenshots are readable.
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

  // The default family in widget tests is the built-in box font; loading a
  // real face into the same family makes previews render like the app.
  await load(previewFontFamily, [
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
    '/System/Library/Fonts/Supplemental/Arial Italic.ttf',
    '/System/Library/Fonts/Supplemental/Arial Bold Italic.ttf',
  ]);
  // The app's monospace stack starts at Menlo.
  await load('Menlo', [
    '/System/Library/Fonts/Menlo.ttc',
    '/System/Library/Fonts/Supplemental/Courier New.ttf',
    '/System/Library/Fonts/Supplemental/Courier New Bold.ttf',
  ]);
  // Material icons normally come from the Flutter engine; load them here so
  // previews render real glyphs.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      _flutterRootFromPath();
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

Future<void> capture(WidgetTester tester, String name) async {
  final boundary =
      tester.renderObject<RenderRepaintBoundary>(find.byKey(previewKey));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('test/previews');
    directory.createSync(recursive: true);
    File('${directory.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> pumpApp(
  WidgetTester tester,
  ChatController controller, {
  Size size = const Size(1280, 840),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: previewKey,
      child: OpenCodeChatApp(
        controller: controller,
        fontFamily: previewFontFamily,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadSystemFonts);

  testWidgets('connect screen preview', (tester) async {
    final controller = ChatController()
      ..connection = ChatConnection.failed
      ..connectionError =
          'No local service found. Start OpenCode or connect manually.';
    await pumpApp(tester, controller);
    await capture(tester, 'connect_screen');
    controller.dispose();
  });

  testWidgets('chat screen preview', (tester) async {
    final controller = _seededController();
    await pumpApp(tester, controller);
    await capture(tester, 'chat_screen');
    controller.dispose();
  });

  testWidgets('light chat screen preview', (tester) async {
    final controller = _seededController()..themeMode.value = ThemeMode.light;
    await pumpApp(tester, controller);
    await capture(tester, 'chat_screen_light');
    controller.dispose();
  });

  testWidgets('narrow chat screen preview', (tester) async {
    final controller = _seededController();
    await pumpApp(tester, controller, size: const Size(600, 840));
    await capture(tester, 'chat_screen_narrow');
    controller.dispose();
  });

  testWidgets('permission banner preview', (tester) async {
    final controller = _seededController();
    controller.pendingPermissions = [
      PermissionRequest.fromJson({
        'id': 'per_1',
        'sessionID': 'ses_preview',
        'action': 'bash',
        'resources': ['git push origin main'],
      }),
    ];
    await pumpApp(tester, controller);
    await capture(tester, 'permission_banner');
    controller.dispose();
  });

  testWidgets('model picker preview', (tester) async {
    final controller = _seededController();
    await pumpApp(tester, controller);
    await tester.tap(find.byKey(const ValueKey('model-picker-button')));
    // Not pumpAndSettle: the seeded running tool card ticks every second.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, 'model_picker');
    controller.dispose();
  });

  testWidgets('composer sends on Enter and inserts newline on Shift+Enter',
      (tester) async {
    final submitted = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Composer(
            enabled: true,
            busy: false,
            onSubmit: (text, files) => submitted.add(text),
            onInterrupt: () {},
          ),
        ),
      ),
    );
    final field = find.byType(TextField);
    await tester.tap(field);
    await tester.enterText(field, 'hello world');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(submitted, ['hello world']);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);

    // Shift+Enter does not submit; the platform text input inserts the
    // newline (widget tests have no IME, so only submission is asserted).
    await tester.enterText(field, 'line one');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(submitted, ['hello world']);
    expect(tester.widget<TextField>(field).controller!.text, 'line one');

    // The composer still submits afterwards.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(submitted, ['hello world', 'line one']);
  });
}

ChatController _seededController() {
  final controller = ChatController()
    ..connection = ChatConnection.connected
    ..serverVersion = '2.0.28'
    ..baseUrl = Uri.parse('http://127.0.0.1:49374')
    ..agents = [
      AgentInfo.fromJson({
        'id': 'build',
        'name': 'Build',
        'request': {
          'settings': <String, Object?>{},
          'headers': <String, Object?>{},
          'body': <String, Object?>{},
        },
        'description': 'The default agent.',
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
        'package': '@opencode/ai/providers/google',
        'settings': <String, Object?>{},
        'headers': {'x-opencode-org-id': 'org_demo'},
        'capabilities': {
          'tools': true,
          'input': ['text', 'image'],
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
      ModelInfo.fromJson({
        'id': 'gpt-5',
        'modelID': 'gpt-5',
        'providerID': 'openai',
        'family': 'gpt',
        'name': 'GPT-5',
        'package': '@opencode/ai/providers/openai',
        'settings': <String, Object?>{},
        'headers': <String, Object?>{},
        'capabilities': {
          'tools': true,
          'input': ['text', 'image'],
          'output': ['text'],
        },
        'variants': <Object?>[],
        'time': {'released': 1791849600000.0},
        'cost': [
          {
            'input': 1.25,
            'output': 10.0,
            'cache': {'read': 0.125, 'write': 0.0},
          },
        ],
        'status': 'active',
        'enabled': true,
        'limit': {'context': 400000, 'output': 128000},
      }),
      ModelInfo.fromJson({
        'id': 'claude-4.5-sonnet',
        'modelID': 'claude-4.5-sonnet',
        'providerID': 'anthropic',
        'family': 'claude',
        'name': 'Claude 4.5 Sonnet',
        'package': '@opencode/ai/providers/anthropic',
        'settings': <String, Object?>{},
        'headers': <String, Object?>{},
        'capabilities': {
          'tools': true,
          'input': ['text', 'image'],
          'output': ['text'],
        },
        'variants': <Object?>[],
        'time': {'released': 1791849600000.0},
        'cost': [
          {
            'input': 3.0,
            'output': 15.0,
            'cache': {'read': 0.3, 'write': 0.0},
          },
        ],
        'status': 'active',
        'enabled': true,
        'limit': {'context': 200000, 'output': 64000},
      }),
    ];

  final session = SessionInfo.fromJson({
    'id': 'ses_preview',
    'projectID': 'prj_1',
    'agent': 'build',
    'model': {'id': 'gpt-5', 'providerID': 'openai'},
    'cost': 0.0421,
    'tokens': {
      'input': 12400,
      'output': 830,
      'reasoning': 120,
      'cache': {'read': 0, 'write': 0},
    },
    'time': {
      'created': DateTime.now().millisecondsSinceEpoch.toDouble() - 3600000,
      'updated': DateTime.now().millisecondsSinceEpoch.toDouble(),
    },
    'location': {'directory': '/workspace'},
    'title': 'Refactor the session store',
  });
  controller
    ..sessions = [
      session,
      SessionInfo.fromJson({
        'id': 'ses_older',
        'projectID': 'prj_1',
        'cost': 0.2,
        'tokens': {
          'input': 900,
          'output': 100,
          'reasoning': 0,
          'cache': {'read': 0, 'write': 0},
        },
        'time': {
          'created': 1,
          'updated': DateTime.now().millisecondsSinceEpoch.toDouble() -
              86400000,
        },
        'location': {'directory': '/workspace'},
        'title': 'Add retry handling to the queue',
      }),
    ]
    ..activeSession = session
    ..usage['ses_preview'] = (
      cost: MoneyUSD(0.0421),
      tokens: TokenUsageInfo.fromJson({
        'input': 12400,
        'output': 830,
        'reasoning': 120,
        'cache': {'read': 0, 'write': 0},
      }),
    )
    ..messages = [
      ChatMessage(
        id: 'msg_user',
        role: ChatRole.user,
        time: DateTime.now().subtract(const Duration(minutes: 3)),
        text: 'Refactor the session store so it streams updates. '
            'Keep the public API stable.',
      ),
      ChatMessage(
        id: 'msg_assistant',
        role: ChatRole.assistant,
        time: DateTime.now().subtract(const Duration(minutes: 2)),
        agent: 'build',
        model: ModelRef(id: 'gpt-5', providerID: ProviderID('openai')),
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
            text: 'The session store currently loads everything eagerly. '
                'I should stream batches and keep the cursor semantics.',
            done: true,
          ),
          ChatTextPart(
            text: 'I moved the transcript loading into a streaming reducer '
                'and kept the public API stable.',
            done: true,
          ),
          ChatToolPart(
            id: 'tool_1',
            name: 'bash',
            status: ChatToolStatus.completed,
            inputJson: {'command': 'dart test test/session_store_test.dart'},
            output: 'All tests passed! (42 tests)',
          ),
          ChatToolPart(
            id: 'tool_2',
            name: 'read',
            status: ChatToolStatus.running,
            inputJson: {'path': 'lib/src/session_store.dart'},
          ),
          ChatTextPart(
            text: 'Here is the core change:\n\n'
                '```dart\n'
                'final stream = store.watch(sessionID);\n'
                'await for (final batch in stream) {\n'
                '  apply(batch);\n'
                '}\n'
                '```\n\n'
                '### Notes\n\n'
                '- `watch` reuses the existing cursor.\n'
                '- Batches are applied in order.\n\n'
                'The `watch` helper reuses the existing cursor.',
            done: true,
          ),
        ],
      ),
      ChatMessage(
        id: 'msg_notice',
        role: ChatRole.notice,
        time: DateTime.now().subtract(const Duration(minutes: 1)),
        text: 'Turn finished',
        notice: 'Turn finished',
      ),
      ChatMessage(
        id: 'msg_user_2',
        role: ChatRole.user,
        time: DateTime.now().subtract(const Duration(seconds: 40)),
        text: 'Great. Now add a regression test for cursor resumption.',
      ),
      ChatMessage(
        id: 'msg_streaming',
        role: ChatRole.assistant,
        time: DateTime.now().subtract(const Duration(seconds: 5)),
        agent: 'build',
        model: ModelRef(id: 'gpt-5', providerID: ProviderID('openai')),
        streaming: true,
        parts: [
          ChatTextPart(
            text: 'Adding a test that resumes from a stored cursor and '
                'verifies the second batch continues',
            done: false,
          ),
        ],
      ),
    ];
  return controller;
}
