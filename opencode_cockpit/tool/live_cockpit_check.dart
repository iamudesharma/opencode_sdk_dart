// Live end-to-end check for the cockpit controller against a running OpenCode
// service. Not part of the default suite (needs a live server):
//
//   flutter test tool/live_cockpit_check.dart
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/services/persistent_terminal.dart';
import 'package:opencode_cockpit/src/terminal_session.dart';

void main() {
  test('live: projects, sessions, files, git, terminal, and stats', () async {
    HttpOverrides.global = null;
    final controller = CockpitController();
    try {
      await controller.connectLocal();
      expect(controller.connection, CockpitConnection.connected);
      print(
        'connected v${controller.serverVersion} '
        'projects=${controller.projects.length} '
        'agents=${controller.agents.length} '
        'models=${controller.models.length}',
      );
      expect(controller.projects, isNotEmpty);

      // Pick the project that contains this repository when present.
      final repoProject = controller.projects.firstWhere(
        (project) => project.canonical.contains('opencode_sdk_dart'),
        orElse: () => controller.projects.first,
      );
      controller.selectProject(repoProject);
      await controller.loadSessions();
      print(
        'project ${repoProject.canonical} '
        'roots=${controller.rootSessions.length}',
      );

      // Expand the first session that has sub-sessions.
      for (final node in controller.rootSessions) {
        await controller.toggleNode(node);
        if (node.children.isNotEmpty) {
          print('session ${node.id} children=${node.children.length}');
          break;
        }
      }

      // Files: list the root, then read a real file.
      await controller.loadDirectory('');
      print('files at root: ${controller.fileEntries.length}');
      expect(controller.fileEntries, isNotEmpty);
      final pubspec = controller.fileEntries
          .where((entry) => '${entry.path}' == 'pubspec.yaml')
          .toList();
      if (pubspec.isNotEmpty) {
        await controller.openFile('pubspec.yaml');
        expect(controller.selectedFileText, isNotNull);
        print(
          'read pubspec.yaml: '
          '${controller.selectedFileText!.length} chars',
        );
      }

      // File search used by @-references.
      controller.updateReferenceQuery('main');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      print('file search hits: ${controller.referenceCandidates.length}');

      // Git: the repo may not be a git checkout; assert only when it is.
      await controller.loadGit();
      if (controller.vcsInfo != null) {
        print(
          'git ${controller.vcsInfo!.provider} '
          'branch=${controller.vcsInfo!.branch.current} '
          'changes=${controller.gitChanges.length} '
          'branches=${controller.branches.length} '
          'worktrees=${controller.worktrees.length}',
        );
      } else {
        print('git: not a repository (skipped)');
      }

      // Session diff, inbox, and forms (may be empty for idle sessions).
      if (controller.rootSessions.isNotEmpty) {
        await controller.openSession(controller.rootSessions.first.info);
        print(
          'session changes: ${controller.sessionChanges.length} '
          'inbox=${controller.inboxItems.length} '
          'forms=${controller.sessionForms.length}',
        );
      }

      // Stats.
      await controller.loadStats();
      expect(controller.stats, isNotNull);
      print(
        'stats: sessions=${controller.stats!.sessions} '
        'steps=${controller.stats!.steps} '
        'cost=\$${controller.stats!.cost.toStringAsFixed(2)}',
      );

      // Terminal: start a shell, run a command, verify the output renders.
      await controller.ensureTerminal();
      final terminal = controller.terminal;
      expect(terminal, isNotNull);
      expect(terminal!.status, TerminalStatus.running);
      terminal.sendInput('echo COCKPIT_PTY_OK\n');
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      var seen = false;
      while (DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (terminal.terminal.buffer.getText().contains('COCKPIT_PTY_OK')) {
          seen = true;
          break;
        }
      }
      final ptyText = terminal.terminal.buffer.getText();
      print(
        'terminal buffer: ${ptyText.length} chars, '
        'echo visible: $seen, pty=${terminal.ptyID}, '
        'cursor=${terminal.cursor}',
      );
      expect(seen, isTrue);

      // Export the active session transcript to disk.
      final exportPath = '/tmp/opencode-cockpit-export.json';
      final written = await controller.exportActiveSession(path: exportPath);
      final exported = jsonDecode(File(written).readAsStringSync());
      expect(exported, isA<Map<String, Object?>>());
      expect((exported as Map<String, Object?>)['info'], isNotNull);
      print(
        'exported transcript to $written '
        '(${File(written).lengthSync()} bytes)',
      );
      File(written).deleteSync();

      // Persistent terminal: create, attach, run a command, snapshot, kill.
      await controller.loadPersistentTerminals();
      final before = controller.persistentTerminals.length;
      await controller.createPersistentTerminal();
      final persistent = controller.persistentTerminalSession;
      expect(persistent, isNotNull);
      expect(persistent!.status, PersistentTerminalStatus.attached);
      persistent.sendInput('echo COCKPIT_PERSISTENT_OK\n');
      final persistentDeadline = DateTime.now().add(
        const Duration(seconds: 15),
      );
      var persistentSeen = false;
      while (DateTime.now().isBefore(persistentDeadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (persistent.terminal.buffer.getText().contains(
          'COCKPIT_PERSISTENT_OK',
        )) {
          persistentSeen = true;
          break;
        }
      }
      expect(persistentSeen, isTrue);
      await controller.snapshotPersistentTerminal();
      final created = controller.persistentTerminals
          .where((terminal) => terminal.id == controller.selectedPersistentID)
          .toList();
      expect(created, isNotEmpty);
      print(
        'persistent terminals: $before -> '
        '${controller.persistentTerminals.length}, echo visible: '
        '$persistentSeen, pty=${created.single.id}',
      );
      await controller.killPersistentTerminal(created.single);
      expect(
        controller.persistentTerminals.where(
          (terminal) => terminal.id == created.single.id,
        ),
        isEmpty,
      );
      print('persistent terminal killed and list refreshed');

      print('LIVE COCKPIT CHECK PASSED');
    } finally {
      controller.dispose();
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
