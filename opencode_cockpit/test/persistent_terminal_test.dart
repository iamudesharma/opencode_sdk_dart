import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/services/persistent_terminal.dart';
import 'package:opencode_cockpit/src/widgets/persistent_terminals_panel.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

PersistentPtyInfo terminalInfo({
  String id = 'pty_1',
  String title = 'dart test',
  String command = 'dart test test/app_test.dart',
  String cwd = '/Users/dev/projects/acme',
  int pid = 4321,
  PersistentPtyInfoStatus status = PersistentPtyInfoStatus.running,
  int? exitCode,
}) => PersistentPtyInfo.fromJson({
  'id': id,
  'title': title,
  'command': command,
  'args': <String>[],
  'cwd': cwd,
  'status': status.wire,
  'pid': pid,
  'exitCode': ?exitCode,
  'sessionID': 'ses_1',
  'size': {'cols': 80, 'rows': 24},
  'output': {'head': 0, 'tail': 0},
});

Future<void> pumpPanel(WidgetTester tester, Widget panel) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(body: SizedBox(width: 360, height: 480, child: panel)),
  ),
);

Widget panel({
  required List<PersistentPtyInfo> terminals,
  PtyID? selectedID,
  ValueChanged<PersistentPtyInfo>? onSelect,
  VoidCallback? onCreate,
  VoidCallback? onRefresh,
  ValueChanged<PersistentPtyInfo>? onKill,
  bool loading = false,
}) => PersistentTerminalsPanel(
  terminals: terminals,
  selectedID: selectedID,
  onSelect: onSelect ?? (_) {},
  onCreate: onCreate ?? () {},
  onRefresh: onRefresh ?? () {},
  onKill: onKill ?? (_) {},
  loading: loading,
);

void main() {
  group('PersistentTerminalsPanel', () {
    testWidgets('header shows the terminal count', (tester) async {
      await pumpPanel(
        tester,
        panel(
          terminals: [
            terminalInfo(),
            terminalInfo(id: 'pty_2', title: 'logs'),
          ],
        ),
      );

      expect(find.text('Terminals'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(
        find.text('Persistent terminals survive app restarts'),
        findsOneWidget,
      );
    });

    testWidgets('rows render title, cwd, and pid', (tester) async {
      await pumpPanel(
        tester,
        panel(
          terminals: [
            terminalInfo(cwd: '/Users/dev/projects/acme', pid: 4321),
            terminalInfo(
              id: 'pty_2',
              title: 'logs',
              command: 'tail -f build/logs/app.log',
              cwd: '/Users/dev/projects/acme/build',
              pid: 9876,
              status: PersistentPtyInfoStatus.exited,
              exitCode: 0,
            ),
          ],
        ),
      );

      expect(find.text('dart test'), findsOneWidget);
      expect(find.text('logs'), findsOneWidget);
      expect(find.text('/Users/dev/projects/acme'), findsOneWidget);
      expect(find.text('/Users/dev/projects/acme/build'), findsOneWidget);
      expect(find.text('pid 4321'), findsOneWidget);
      expect(find.text('pid 9876'), findsOneWidget);
      expect(find.byTooltip('Kill terminal'), findsNWidgets(2));
    });

    testWidgets('tapping a row calls onSelect', (tester) async {
      PersistentPtyInfo? selected;
      final logs = terminalInfo(id: 'pty_2', title: 'logs');
      await pumpPanel(
        tester,
        panel(
          terminals: [terminalInfo(), logs],
          selectedID: PtyID('pty_1'),
          onSelect: (terminal) => selected = terminal,
        ),
      );

      await tester.tap(find.text('logs'));
      expect('${selected?.id}', 'pty_2');
    });

    testWidgets('new and refresh buttons fire callbacks', (tester) async {
      var created = 0;
      var refreshed = 0;
      await pumpPanel(
        tester,
        panel(
          terminals: const [],
          onCreate: () => created++,
          onRefresh: () => refreshed++,
        ),
      );

      await tester.tap(find.byTooltip('New terminal'));
      await tester.tap(find.byTooltip('Refresh terminals'));
      expect(created, 1);
      expect(refreshed, 1);
    });

    testWidgets('loading swaps the refresh button for a spinner', (
      tester,
    ) async {
      await pumpPanel(tester, panel(terminals: const [], loading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byTooltip('Refresh terminals'), findsNothing);
      expect(find.byTooltip('New terminal'), findsOneWidget);
    });

    testWidgets('kill asks for confirmation before calling onKill', (
      tester,
    ) async {
      final killed = <PersistentPtyInfo>[];
      await pumpPanel(
        tester,
        panel(terminals: [terminalInfo()], onKill: killed.add),
      );

      await tester.tap(find.byTooltip('Kill terminal'));
      await tester.pumpAndSettle();
      expect(
        find.text('The terminal is terminated on the server'),
        findsOneWidget,
      );
      expect(killed, isEmpty);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(killed, isEmpty);

      await tester.tap(find.byTooltip('Kill terminal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kill'));
      await tester.pumpAndSettle();
      expect(killed.length, 1);
      expect('${killed.single.id}', 'pty_1');
    });

    testWidgets('empty state explains there are no terminals', (tester) async {
      await pumpPanel(tester, panel(terminals: const []));

      expect(
        find.text('No persistent terminals for this session'),
        findsOneWidget,
      );
    });
  });

  group('PersistentTerminalSession.applyFrame', () {
    test('cursor frames update the resume cursor and notify', () {
      final session = PersistentTerminalSession();
      var changes = 0;
      session.onChanged = () => changes++;

      session.applyFrame(PtyFrame.parse(utf8.encode('{"cursor":42}')));

      expect(session.cursor, 42);
      expect(changes, 1);
    });

    test('output frames land in the terminal buffer', () {
      final session = PersistentTerminalSession();
      var changes = 0;
      session.onChanged = () => changes++;

      session.applyFrame(PtyFrame.parse('output data'));

      expect(session.terminal.buffer.getText(), contains('output data'));
      expect(session.cursor, 0);
      expect(changes, 0);
      expect(session.status, PersistentTerminalStatus.detached);
    });

    test('snapshot text renders verbatim into the terminal', () {
      final session = PersistentTerminalSession();

      session.applySnapshotText('line one\r\nline two\r\n');

      final text = session.terminal.buffer.getText();
      expect(text, contains('line one'));
      expect(text, contains('line two'));
    });
  });
}
