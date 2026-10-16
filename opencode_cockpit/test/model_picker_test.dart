import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/theme.dart';
import 'package:opencode_cockpit/src/widgets/model_picker.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

ModelInfo model(String provider, String id) => ModelInfo.fromJson({
  'id': id,
  'modelID': id,
  'providerID': provider,
  'family': 'test',
  'name': '$provider $id',
  'settings': <String, Object?>{},
  'capabilities': {
    'tools': true,
    'input': ['text'],
    'output': ['text'],
  },
  'variants': <Object?>[],
  'time': {'released': 1},
  'cost': <Object?>[],
  'status': 'active',
  'enabled': true,
  'limit': {'context': 4096, 'output': 1024},
});

SessionInfo session({ModelRef? current}) => SessionInfo.fromJson({
  'id': 'ses_1',
  'projectID': 'prj_1',
  'cost': 0,
  'tokens': {
    'input': 0,
    'output': 0,
    'reasoning': 0,
    'cache': {'read': 0, 'write': 0},
  },
  'time': {'created': 1, 'updated': 2},
  'location': {'directory': '/workspace'},
  'model': ?current?.toJson(),
});

void main() {
  testWidgets('model picker searches all models and marks the current one', (
    tester,
  ) async {
    final controller = CockpitController()
      ..models = [
        model('openai', 'gpt-5'),
        model('anthropic', 'claude-4'),
        model('opencode-go', 'gemini-4'),
      ]
      ..activeSession = session(
        current: ModelRef(providerID: ProviderID('openai'), id: 'gpt-5'),
      );
    ModelRef? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCockpitTheme(Brightness.dark),
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                selected = await showModelPicker(context, controller);
              },
              child: const Text('open models'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open models'));
    await tester.pumpAndSettle();

    // Every provider/model pair is listed, not a truncated slice.
    expect(find.text('openai/gpt-5'), findsOneWidget);
    expect(find.text('anthropic/claude-4'), findsOneWidget);
    expect(find.text('opencode-go/gemini-4'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'gemini');
    await tester.pump();
    expect(find.text('openai/gpt-5'), findsNothing);
    expect(find.text('opencode-go/gemini-4'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'no-such-model');
    await tester.pump();
    expect(find.text('No models match "no-such-model".'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'claude');
    await tester.pump();
    await tester.tap(find.text('anthropic/claude-4'));
    await tester.pumpAndSettle();

    expect('${selected?.providerID}/${selected?.id}', 'anthropic/claude-4');
    expect(find.text('Switch model'), findsNothing);
    controller.dispose();
  });
}
