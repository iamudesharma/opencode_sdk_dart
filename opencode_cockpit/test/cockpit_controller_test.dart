import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/models.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

OpenCodeEvent event(String type, Map<String, Object?> data) =>
    OpenCodeEvent.fromJson({'type': type, 'created': 1000, 'data': data});

void main() {
  late CockpitController controller;

  setUp(() {
    controller = CockpitController();
    controller.connection = CockpitConnection.connected;
    controller.activeSession = _session('ses_1');
    controller.rootSessions = [SessionNode(controller.activeSession!)];
  });

  tearDown(() => controller.dispose());

  test('assistant streaming composes text, reasoning, and tools', () {
    controller.handleEvent(
      event('session.step.started', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'agent': 'build',
        'model': {'id': 'gpt-5', 'providerID': 'openai'},
      }),
    );
    controller.handleEvent(
      event('session.reasoning.started', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'ordinal': 0,
      }),
    );
    controller.handleEvent(
      event('session.reasoning.delta', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'ordinal': 0,
        'delta': 'plan',
      }),
    );
    controller.handleEvent(
      event('session.tool.input.started', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'id': 'tool_1',
        'name': 'bash',
      }),
    );
    controller.handleEvent(
      event('session.tool.called', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'id': 'tool_1',
        'input': {'command': 'ls'},
      }),
    );
    controller.handleEvent(
      event('session.text.delta', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'ordinal': 0,
        'delta': 'done',
      }),
    );

    final message = controller.messages.single;
    expect(message.agent, 'build');
    expect(message.parts.whereType<ChatReasoningPart>().single.text, 'plan');
    expect(message.parts.whereType<ChatTextPart>().single.text, 'done');
    expect(
      message.parts.whereType<ChatToolPart>().single.status,
      ChatToolStatus.running,
    );
  });

  test('session tree filters by title and id', () {
    controller.rootSessions = [
      SessionNode(_session('ses_aaa', title: 'Refactor store')),
      SessionNode(_session('ses_bbb', title: 'Fix the parser')),
    ];
    controller.sessionFilter = 'parser';
    expect(controller.visibleRoots.single.id, 'ses_bbb');
    controller.sessionFilter = 'aaa';
    expect(controller.visibleRoots.single.id, 'ses_aaa');
    controller.sessionFilter = '';
    expect(controller.visibleRoots.length, 2);
  });

  test('permissions only surface for the active session', () {
    controller.handleEvent(
      event('permission.asked', {
        'id': 'per_1',
        'sessionID': 'ses_other',
        'action': 'bash',
        'resources': ['rm -rf /'],
      }),
    );
    expect(controller.pendingPermissions, isEmpty);

    controller.handleEvent(
      event('permission.asked', {
        'id': 'per_2',
        'sessionID': 'ses_1',
        'action': 'read',
        'resources': ['secrets.env'],
      }),
    );
    expect(controller.pendingPermissions.single.id, 'per_2');

    controller.handleEvent(
      event('permission.replied', {'sessionID': 'ses_1', 'requestID': 'per_2'}),
    );
    expect(controller.pendingPermissions, isEmpty);
  });

  test('busy tracking follows execution events', () {
    controller.handleEvent(
      event('session.execution.started', {'sessionID': 'ses_1'}),
    );
    expect(controller.activeBusy, isTrue);
    controller.handleEvent(
      event('session.execution.succeeded', {'sessionID': 'ses_1'}),
    );
    expect(controller.activeBusy, isFalse);
  });

  test('composer references insert at the caret', () {
    controller.composer.text = 'Fix ';
    controller.composer.selection = const TextSelection.collapsed(offset: 4);
    controller.insertReference('lib/main.dart');
    expect(controller.composer.text, 'Fix @lib/main.dart ');
    expect(controller.composer.selection.baseOffset, 19);
  });

  test('usage events update sidebar totals', () {
    controller.handleEvent(
      event('session.usage.updated', {
        'sessionID': 'ses_1',
        'cost': 0.25,
        'tokens': {
          'input': 100,
          'output': 10,
          'reasoning': 0,
          'cache': {'read': 0, 'write': 0},
        },
      }),
    );
    expect(controller.usage['ses_1']?.cost, 0.25);
  });

  test('theme toggles between dark and light', () {
    expect(controller.themeMode, ThemeMode.dark);
    controller.toggleTheme();
    expect(controller.themeMode, ThemeMode.light);
  });

  test('listener updates coalesce into a single notification', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.handleEvent(
      event('session.execution.started', {'sessionID': 'ses_1'}),
    );
    controller.handleEvent(
      event('session.execution.succeeded', {'sessionID': 'ses_1'}),
    );
    expect(notifications, 0);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(notifications, 1);
  });

  test('dispose flushes a pending notification', () {
    final local = CockpitController()..connection = CockpitConnection.connected;
    var notifications = 0;
    local.addListener(() => notifications++);
    local.handleEvent(
      event('session.execution.started', {'sessionID': 'ses_1'}),
    );
    expect(notifications, 0);
    local.dispose();
    expect(notifications, 1);
  });
}

SessionInfo _session(String id, {String? title}) => SessionInfo.fromJson({
  'id': id,
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
  'title': ?title,
});
