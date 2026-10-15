import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/theme.dart';
import 'package:opencode_cockpit/src/widgets/inbox_strip.dart';
import 'package:opencode_cockpit/src/widgets/session_transfer_dialogs.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

SessionInboxInfo inboxItem({
  required String id,
  required String type,
  Object? payload,
  SessionInboxDelivery delivery = SessionInboxDelivery.queue,
}) => SessionInboxInfo.fromJson({
  'id': id,
  'sessionID': 'ses_1',
  'time': {'created': 1},
  'type': type,
  'payload': payload,
  'delivery': delivery.wire,
});

Future<void> pumpStrip(
  WidgetTester tester, {
  required List<SessionInboxInfo> items,
  void Function(SessionInboxInfo item)? onCancel,
  void Function(SessionInboxInfo item, SessionInboxDelivery delivery)?
  onDeliveryChanged,
  bool busy = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildCockpitTheme(Brightness.dark),
      home: Scaffold(
        body: InboxStrip(
          items: items,
          onCancel: onCancel ?? (_) {},
          onDeliveryChanged: onDeliveryChanged ?? (_, _) {},
          busy: busy,
        ),
      ),
    ),
  );
}

void main() {
  group('describeInboxItem', () {
    test('summarizes every inbox kind', () {
      final user = inboxItem(
        id: 'msg_user',
        type: 'user',
        payload: <String, Object?>{'text': 'Fix the parser'},
      );
      final synthetic = inboxItem(
        id: 'msg_synthetic',
        type: 'synthetic',
        payload: <String, Object?>{'text': 'Auto-raised prompt'},
      );
      final compaction = inboxItem(
        id: 'msg_compaction',
        type: 'compaction',
        payload: <String, Object?>{},
      );
      final move = inboxItem(
        id: 'msg_move',
        type: 'move',
        payload: <String, Object?>{
          'projectID': 'prj_1',
          'subpath': 'lib/src',
          'location': <String, Object?>{'directory': '/workspace/next'},
        },
      );
      final relativeMove = inboxItem(
        id: 'msg_move_relative',
        type: 'move',
        payload: <String, Object?>{
          'projectID': 'prj_1',
          'subpath': 'lib/src',
          'location': <String, Object?>{},
        },
      );

      expect(describeInboxItem(user), 'Fix the parser');
      expect(describeInboxItem(synthetic), 'Auto-raised prompt');
      expect(describeInboxItem(compaction), 'Compaction');
      expect(describeInboxItem(move), 'Move to /workspace/next');
      expect(describeInboxItem(relativeMove), 'Move to lib/src');
      expect(inboxItemIcon(user), Icons.person_outline_rounded);
      expect(inboxItemIcon(synthetic), Icons.auto_awesome_outlined);
      expect(inboxItemIcon(compaction), Icons.compress_rounded);
      expect(inboxItemIcon(move), Icons.drive_file_move_outlined);
    });
  });

  group('InboxStrip', () {
    testWidgets('renders nothing when there are no pending items', (
      tester,
    ) async {
      await pumpStrip(tester, items: const []);

      expect(find.byType(InboxStrip), findsOneWidget);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(RichText), findsNothing);
    });

    testWidgets('renders descriptions and reports cancel and delivery '
        'changes', (tester) async {
      final user = inboxItem(
        id: 'msg_user',
        type: 'user',
        payload: <String, Object?>{'text': 'Fix the parser'},
      );
      final compaction = inboxItem(
        id: 'msg_compaction',
        type: 'compaction',
        payload: <String, Object?>{'reason': 'context window exceeded'},
        delivery: SessionInboxDelivery.steer,
      );
      final cancelled = <SessionInboxInfo>[];
      final changes = <(SessionInboxInfo, SessionInboxDelivery)>[];

      await pumpStrip(
        tester,
        items: [user, compaction],
        onCancel: cancelled.add,
        onDeliveryChanged: (item, delivery) => changes.add((item, delivery)),
      );

      expect(find.text('Fix the parser'), findsOneWidget);
      expect(find.text('Compaction: context window exceeded'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pump();
      expect(cancelled.single, same(user));

      await tester.tap(find.text('queue'));
      await tester.pump();
      expect(changes.single.$1, same(user));
      expect(changes.single.$2, SessionInboxDelivery.steer);

      await tester.tap(find.text('steer'));
      await tester.pump();
      expect(changes.last.$1, same(compaction));
      expect(changes.last.$2, SessionInboxDelivery.queue);
    });

    testWidgets('ignores interactions while busy', (tester) async {
      final user = inboxItem(
        id: 'msg_user',
        type: 'user',
        payload: <String, Object?>{'text': 'Fix the parser'},
      );
      var cancels = 0;
      var changes = 0;

      await pumpStrip(
        tester,
        items: [user],
        busy: true,
        onCancel: (_) => cancels++,
        onDeliveryChanged: (_, _) => changes++,
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.tap(find.text('queue'));
      await tester.pump();

      expect(cancels, 0);
      expect(changes, 0);
    });
  });

  group('session transfer dialogs', () {
    testWidgets('export dialog pre-fills, validates, and pops the trimmed '
        'path', (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCockpitTheme(Brightness.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showSessionExportDialog(
                    context,
                    sessionID: 'ses_1',
                    suggestedPath: '/tmp/ses_1.json',
                  );
                },
                child: const Text('open export'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open export'));
      await tester.pumpAndSettle();

      expect(find.text('Export session'), findsOneWidget);
      expect(
        find.text('Writes the projected session transcript as JSON.'),
        findsOneWidget,
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.autofocus, isTrue);
      expect(field.controller?.text, '/tmp/ses_1.json');

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      FilledButton confirm() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Export'),
      );
      expect(confirm().onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  /tmp/exported.json  ');
      await tester.pump();
      expect(confirm().onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Export'));
      await tester.pumpAndSettle();

      expect(result, '/tmp/exported.json');
      expect(find.text('Export session'), findsNothing);
    });

    testWidgets('import dialog resolves null when cancelled', (tester) async {
      String? result = 'pending';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCockpitTheme(Brightness.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showSessionImportDialog(
                    context,
                    suggestedPath: '/tmp/exported.json',
                  );
                },
                child: const Text('open import'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open import'));
      await tester.pumpAndSettle();

      expect(find.text('Import session'), findsOneWidget);
      expect(
        find.text('Reads a previously exported transcript file.'),
        findsOneWidget,
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, '/tmp/exported.json');

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('Import session'), findsNothing);
    });

    testWidgets('barrier dismiss resolves null', (tester) async {
      String? result = 'pending';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCockpitTheme(Brightness.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showSessionExportDialog(
                    context,
                    sessionID: 'ses_1',
                    suggestedPath: '/tmp/ses_1.json',
                  );
                },
                child: const Text('open export'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open export'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('Export session'), findsNothing);
    });
  });
}
