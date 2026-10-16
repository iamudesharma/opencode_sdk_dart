import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/src/app.dart';
import 'package:opencode_chat/src/chat_controller.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Records [switchModel] calls without touching a client.
class _RecordingController extends ChatController {
  final switched = <ModelRef>[];

  @override
  Future<void> switchModel(ModelRef model) async {
    switched.add(model);
  }
}

ModelInfo _model(String provider, String id, String name) => ModelInfo.fromJson({
      'id': id,
      'modelID': id,
      'providerID': provider,
      'family': provider,
      'name': name,
      'package': '@opencode/ai/providers/$provider',
      'settings': <String, Object?>{},
      'headers': <String, Object?>{},
      'capabilities': {
        'tools': true,
        'input': ['text'],
        'output': ['text'],
      },
      'variants': <Object?>[],
      'time': {'released': 1791849600000.0},
      'cost': [
        {
          'input': 1.0,
          'output': 2.0,
          'cache': {'read': 0.1, 'write': 0.0},
        },
      ],
      'status': 'active',
      'enabled': true,
      'limit': {'context': 200000, 'output': 32000},
    });

SessionInfo _session() => SessionInfo.fromJson({
      'id': 'ses_picker',
      'projectID': 'prj_1',
      'agent': 'build',
      'model': {'id': 'gpt-5', 'providerID': 'openai'},
      'cost': 0,
      'tokens': {
        'input': 0,
        'output': 0,
        'reasoning': 0,
        'cache': {'read': 0, 'write': 0},
      },
      'time': {'created': 1, 'updated': 2},
      'location': {'directory': '/workspace'},
      'title': 'Pick a model',
    });

void main() {
  testWidgets('model picker searches across all models and selects one',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = _RecordingController()
      ..connection = ChatConnection.connected
      ..serverVersion = '2.0.28'
      ..baseUrl = Uri.parse('http://127.0.0.1:49374')
      ..models = [
        _model('opencode-go', 'gemini-4-argon', 'Gemini 4 Argon'),
        _model('openai', 'gpt-5', 'GPT-5'),
        _model('anthropic', 'claude-4.5-sonnet', 'Claude 4.5 Sonnet'),
      ];
    final session = _session();
    controller
      ..activeSession = session
      ..sessions = [session];

    await tester.pumpWidget(OpenCodeChatApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 60));

    // The header chip shows the current model; tapping it opens the picker.
    expect(find.text('openai/gpt-5'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('model-picker-button')));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    // Every model is listed (no truncation).
    expect(
      find.byKey(const ValueKey('model-option-opencode-go/gemini-4-argon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('model-option-anthropic/claude-4.5-sonnet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('model-option-openai/gpt-5')),
      findsOneWidget,
    );

    // Search matches the provider/model string.
    await tester.enterText(
      find.byKey(const ValueKey('model-picker-search')),
      'anthropic',
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('model-option-anthropic/claude-4.5-sonnet')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('model-option-openai/gpt-5')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('model-option-opencode-go/gemini-4-argon')),
      findsNothing,
    );

    // Search also matches just the model id.
    await tester.enterText(
      find.byKey(const ValueKey('model-picker-search')),
      'argon',
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('model-option-opencode-go/gemini-4-argon')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('model-option-anthropic/claude-4.5-sonnet')),
      findsNothing,
    );

    // A search with no hits shows the empty state.
    await tester.enterText(
      find.byKey(const ValueKey('model-picker-search')),
      'zzz',
    );
    await tester.pump();
    expect(find.text('No models match.'), findsOneWidget);

    // Selecting an option reports the new model and closes the dialog.
    await tester.enterText(
      find.byKey(const ValueKey('model-picker-search')),
      'argon',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('model-option-opencode-go/gemini-4-argon')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(controller.switched, hasLength(1));
    expect(controller.switched.single.providerID, 'opencode-go');
    expect(controller.switched.single.id, 'gemini-4-argon');

    controller.dispose();
  });

  testWidgets('model picker marks the current model with a checkmark',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 840);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = _RecordingController()
      ..connection = ChatConnection.connected
      ..serverVersion = '2.0.28'
      ..baseUrl = Uri.parse('http://127.0.0.1:49374')
      ..models = [
        _model('openai', 'gpt-5', 'GPT-5'),
        _model('anthropic', 'claude-4.5-sonnet', 'Claude 4.5 Sonnet'),
      ];
    final session = _session();
    controller
      ..activeSession = session
      ..sessions = [session];

    await tester.pumpWidget(OpenCodeChatApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.byKey(const ValueKey('model-picker-button')));
    await tester.pumpAndSettle();

    final currentTile = find.byKey(const ValueKey('model-option-openai/gpt-5'));
    expect(currentTile, findsOneWidget);
    expect(
      find.descendant(of: currentTile, matching: find.byIcon(Icons.check_rounded)),
      findsOneWidget,
    );
    final otherTile =
        find.byKey(const ValueKey('model-option-anthropic/claude-4.5-sonnet'));
    expect(
      find.descendant(of: otherTile, matching: find.byIcon(Icons.check_rounded)),
      findsNothing,
    );

    controller.dispose();
  });
}
