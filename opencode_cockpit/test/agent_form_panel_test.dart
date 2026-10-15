import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/widgets/agent_form_panel.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Builds one raw field payload; keys unused by the matching variant are
/// ignored by the generated decoder.
Map<String, Object?> fieldJson(
  String type,
  String key, {
  String? title,
  String? description,
  bool? required,
  bool? hidden,
  List<Map<String, Object?>>? when,
  Object? defaultValue,
  String? placeholder,
  String? format,
  int? minLength,
  int? maxLength,
  List<Map<String, Object?>>? options,
  bool? custom,
  Object? minimum,
  Object? maximum,
  int? minItems,
  int? maxItems,
  String? url,
}) => {
  'key': key,
  'type': type,
  'title': ?title,
  'description': ?description,
  'required': ?required,
  'hidden': ?hidden,
  'when': ?when,
  'default': ?defaultValue,
  'placeholder': ?placeholder,
  'format': ?format,
  'minLength': ?minLength,
  'maxLength': ?maxLength,
  'options': ?options,
  'custom': ?custom,
  'minimum': ?minimum,
  'maximum': ?maximum,
  'minItems': ?minItems,
  'maxItems': ?maxItems,
  'url': ?url,
};

FormDetail formDetail({
  String id = 'frm_1',
  String title = 'Deploy plan',
  List<Map<String, Object?>> fields = const [],
  Map<String, Object?> state = const {'status': 'pending'},
}) => FormDetail.fromJson({
  'id': id,
  'sessionID': 'ses_1',
  'title': title,
  'fields': fields,
  'state': state,
});

/// The same form used by the render and submit tests: every field type plus
/// a hidden field and a conditional field.
FormDetail deployForm() => formDetail(
  fields: [
    fieldJson(
      'string',
      'goal',
      title: 'Goal',
      description: 'What should the agent do?',
      placeholder: 'Describe the goal',
      required: true,
    ),
    fieldJson(
      'string',
      'mode',
      title: 'Mode',
      options: [
        {'value': 'fast', 'label': 'Fast'},
        {'value': 'safe', 'label': 'Safe'},
      ],
    ),
    fieldJson(
      'number',
      'budget',
      title: 'Budget',
      required: true,
      minimum: 0,
      maximum: 1000,
    ),
    fieldJson('integer', 'retries', title: 'Retries', defaultValue: 2),
    fieldJson('boolean', 'confirm', title: 'Confirm', defaultValue: false),
    fieldJson(
      'multiselect',
      'tags',
      title: 'Tags',
      required: true,
      custom: true,
      options: [
        {'value': 'a', 'label': 'Alpha'},
        {'value': 'b', 'label': 'Beta'},
      ],
    ),
    fieldJson('string', 'secret', title: 'Secret', hidden: true),
    fieldJson(
      'external',
      'docs',
      title: 'Docs',
      description: 'Finish setup in the browser',
      url: 'https://example.com/setup',
    ),
  ],
);

Future<void> pumpPanel(
  WidgetTester tester, {
  required FormDetail detail,
  void Function(Map<String, Object?> answer)? onReply,
  VoidCallback? onCancel,
  bool busy = false,
}) async {
  tester.view.physicalSize = const Size(1000, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: AgentFormPanel(
            detail: detail,
            onReply: onReply ?? (_) {},
            onCancel: onCancel ?? () {},
            busy: busy,
          ),
        ),
      ),
    ),
  );
}

FilledButton submitButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const ValueKey('form-submit')));

void main() {
  test('initialAnswers collects typed defaults and skips empty strings', () {
    final detail = formDetail(
      fields: [
        fieldJson('string', 'name', defaultValue: 'ada'),
        fieldJson('string', 'nickname', defaultValue: ''),
        fieldJson('number', 'ratio', defaultValue: 0.5),
        fieldJson('integer', 'retries', defaultValue: 3),
        fieldJson('boolean', 'confirm', defaultValue: false),
        fieldJson(
          'multiselect',
          'tags',
          defaultValue: ['a'],
          options: [
            {'value': 'a', 'label': 'Alpha'},
          ],
        ),
        fieldJson('external', 'docs', url: 'https://example.com/setup'),
      ],
    );
    expect(AgentFormPanel.initialAnswers(detail), {
      'name': 'ada',
      'ratio': 0.5,
      'retries': 3,
      'confirm': false,
      'tags': ['a'],
    });
  });

  testWidgets('renders the title, state chip, and every field type', (
    tester,
  ) async {
    await pumpPanel(tester, detail: deployForm());

    expect(find.text('Deploy plan'), findsOneWidget);
    expect(find.text('pending'), findsOneWidget);
    expect(find.text('Goal'), findsOneWidget);
    expect(find.text('What should the agent do?'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Retries'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('https://example.com/setup'), findsOneWidget);
    expect(find.textContaining('outside the app'), findsOneWidget);
    expect(find.text('Secret'), findsNothing);

    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(2));
    expect(find.byKey(const ValueKey('form-field-secret')), findsNothing);
    expect(find.byKey(const ValueKey('form-field-docs')), findsNothing);
    expect(find.byKey(const ValueKey('form-custom-tags')), findsOneWidget);
    expect(find.byKey(const ValueKey('form-custom-add-tags')), findsOneWidget);
  });

  testWidgets('submit stays disabled until required fields are filled', (
    tester,
  ) async {
    await pumpPanel(tester, detail: deployForm());
    expect(submitButton(tester).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('form-field-goal')),
      'Ship it',
    );
    await tester.pump();
    expect(submitButton(tester).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('form-field-budget')),
      '12.5',
    );
    await tester.pump();
    expect(submitButton(tester).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('form-chip-tags-a')));
    await tester.pump();
    expect(submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('submits an answer map with every field type', (tester) async {
    Map<String, Object?>? reply;
    await pumpPanel(
      tester,
      detail: deployForm(),
      onReply: (answer) => reply = answer,
    );

    await tester.enterText(
      find.byKey(const ValueKey('form-field-goal')),
      'Ship it',
    );
    await tester.enterText(
      find.byKey(const ValueKey('form-field-budget')),
      '12.5',
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('form-field-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fast').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('form-field-confirm')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('form-chip-tags-a')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('form-custom-tags')),
      'gamma',
    );
    await tester.tap(find.byKey(const ValueKey('form-custom-add-tags')));
    await tester.pump();
    expect(find.text('gamma'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('form-submit')));
    await tester.pump();

    expect(reply, {
      'goal': 'Ship it',
      'mode': 'fast',
      'budget': 12.5,
      'retries': 2,
      'confirm': true,
      'tags': ['a', 'gamma'],
    });
  });

  testWidgets('inline errors block submit for unparseable numbers', (
    tester,
  ) async {
    Map<String, Object?>? reply;
    await pumpPanel(
      tester,
      detail: deployForm(),
      onReply: (answer) => reply = answer,
    );

    await tester.enterText(
      find.byKey(const ValueKey('form-field-goal')),
      'Ship it',
    );
    await tester.enterText(
      find.byKey(const ValueKey('form-field-budget')),
      'lots',
    );
    await tester.tap(find.byKey(const ValueKey('form-chip-tags-a')));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('form-submit')));
    await tester.pump();

    expect(find.text('Enter a number'), findsOneWidget);
    expect(reply, isNull);
  });

  testWidgets('when conditions hide and reveal a field', (tester) async {
    await pumpPanel(
      tester,
      detail: formDetail(
        fields: [
          fieldJson('string', 'answer', title: 'Answer'),
          fieldJson(
            'string',
            'revealed',
            title: 'Extra detail',
            when: [
              {'key': 'answer', 'op': 'neq', 'value': 'hide-me'},
            ],
          ),
        ],
      ),
    );

    expect(find.text('Extra detail'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('form-field-answer')),
      'hide-me',
    );
    await tester.pump();
    expect(find.text('Extra detail'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('form-field-answer')),
      'show-me',
    );
    await tester.pump();
    expect(find.text('Extra detail'), findsOneWidget);
  });

  testWidgets('cancel invokes the callback', (tester) async {
    var cancelled = 0;
    await pumpPanel(tester, detail: deployForm(), onCancel: () => cancelled++);

    await tester.tap(find.byKey(const ValueKey('form-cancel')));
    await tester.pump();
    expect(cancelled, 1);
  });

  testWidgets('answered forms render read-only with the server answer', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      detail: formDetail(
        fields: [fieldJson('string', 'goal', title: 'Goal', required: true)],
        state: {
          'status': 'answered',
          'answer': {'goal': 'Ship it'},
        },
      ),
    );

    expect(find.text('answered'), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);
    final formField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('form-field-goal')),
    );
    expect(formField.controller?.text, 'Ship it');
    final textField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('form-field-goal')),
        matching: find.byType(TextField),
      ),
    );
    expect(textField.enabled, isFalse);
  });

  testWidgets('busy shows a spinner and disables both actions', (tester) async {
    await pumpPanel(tester, detail: deployForm(), busy: true);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(submitButton(tester).onPressed, isNull);
    final cancel = tester.widget<TextButton>(
      find.byKey(const ValueKey('form-cancel')),
    );
    expect(cancel.onPressed, isNull);
  });
}
