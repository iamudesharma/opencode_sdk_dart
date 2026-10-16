import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:opencode_chat/src/chat_controller.dart';
import 'package:opencode_chat/src/chat_models.dart';

OpenCodeEvent event(String type, Map<String, Object?> data) =>
    OpenCodeEvent.fromJson({'type': type, 'created': 1000, 'data': data});

void main() {
  late ChatController controller;

  setUp(() {
    controller = ChatController();
    controller.connection = ChatConnection.connected;
    controller.activeSession = _session('ses_1');
    controller.sessions = [controller.activeSession!];
  });

  tearDown(() => controller.dispose());

  test('step and text events compose a streaming assistant message', () {
    controller.handleEvent(event('session.step.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'agent': 'build',
      'model': {'id': 'gpt-5', 'providerID': 'openai'},
    }));
    controller.handleEvent(event('session.text.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
    }));
    controller.handleEvent(event('session.text.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'delta': 'Hel',
    }));
    controller.handleEvent(event('session.text.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'delta': 'lo',
    }));

    expect(controller.messages, hasLength(1));
    final message = controller.messages.single;
    expect(message.role, ChatRole.assistant);
    expect(message.streaming, isTrue);
    expect(message.agent, 'build');
    expect(message.model?.id, 'gpt-5');
    final text = message.parts.whereType<ChatTextPart>().single;
    expect(text.text, 'Hello');
    expect(text.done, isFalse);

    controller.handleEvent(event('session.text.ended', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'text': 'Hello!',
    }));
    expect(text.text, 'Hello!');
    expect(text.done, isTrue);

    controller.handleEvent(event('session.step.ended', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'finish': 'stop',
      'cost': 0.0123,
      'tokens': {
        'input': 10,
        'output': 5,
        'reasoning': 0,
        'cache': {'read': 0, 'write': 0},
      },
    }));
    expect(message.streaming, isFalse);
    expect(message.finish, 'stop');
    expect(message.cost, 0.0123);
    expect(message.tokens?.output, 5);
  });

  test('tool events drive the tool card lifecycle', () {
    controller.handleEvent(event('session.step.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
    }));
    controller.handleEvent(event('session.tool.input.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'name': 'bash',
    }));
    controller.handleEvent(event('session.tool.input.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'delta': '{"command":',
    }));
    controller.handleEvent(event('session.tool.input.ended', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'text': '{"command":"ls"}',
    }));
    var tool = controller.messages.single.parts.whereType<ChatToolPart>().single;
    expect(tool.status, ChatToolStatus.streaming);
    expect(tool.input, '{"command":"ls"}');

    controller.handleEvent(event('session.tool.called', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'input': {'command': 'ls'},
      'executed': true,
    }));
    tool = controller.messages.single.parts.whereType<ChatToolPart>().single;
    expect(tool.status, ChatToolStatus.running);
    expect(tool.inputJson, {'command': 'ls'});

    controller.handleEvent(event('session.tool.success', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'metadata': {'exitCode': 0},
      'content': [
        {'type': 'text', 'text': 'file_a\nfile_b'},
      ],
    }));
    tool = controller.messages.single.parts.whereType<ChatToolPart>().single;
    expect(tool.status, ChatToolStatus.completed);
    expect(tool.output, 'file_a\nfile_b');
  });

  test('failed tools keep the error message', () {
    controller.handleEvent(event('session.step.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
    }));
    controller.handleEvent(event('session.tool.input.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'name': 'bash',
    }));
    controller.handleEvent(event('session.tool.failed', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'id': 'tool_1',
      'error': {'type': 'tool.failed', 'message': 'exit code 1'},
      'content': <Object?>[],
    }));
    final tool =
        controller.messages.single.parts.whereType<ChatToolPart>().single;
    expect(tool.status, ChatToolStatus.failed);
    expect(tool.error, 'exit code 1');
  });

  test('reasoning events stream separately from text', () {
    controller.handleEvent(event('session.step.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
    }));
    controller.handleEvent(event('session.reasoning.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
    }));
    controller.handleEvent(event('session.reasoning.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'delta': 'thinking\u2026',
    }));
    controller.handleEvent(event('session.text.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
    }));
    controller.handleEvent(event('session.text.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'delta': 'answer',
    }));
    final parts = controller.messages.single.parts;
    expect(parts.whereType<ChatReasoningPart>().single.text, 'thinking\u2026');
    expect(parts.whereType<ChatTextPart>().single.text, 'answer');
  });

  test('execution events toggle the busy indicator', () {
    controller.handleEvent(event('session.execution.started', {
      'sessionID': 'ses_1',
    }));
    expect(controller.activeBusy, isTrue);
    controller.handleEvent(event('session.execution.succeeded', {
      'sessionID': 'ses_1',
    }));
    expect(controller.activeBusy, isFalse);
  });

  test('events from other sessions do not touch the transcript', () {
    controller.handleEvent(event('session.step.started', {
      'sessionID': 'ses_other',
      'assistantMessageID': 'msg_9',
    }));
    expect(controller.messages, isEmpty);
    expect(controller.busySessionIDs, isEmpty);

    controller.handleEvent(event('session.execution.started', {
      'sessionID': 'ses_other',
    }));
    expect(controller.busySessionIDs, contains('ses_other'));
  });

  test('permission events add and remove requests', () {
    controller.handleEvent(event('permission.asked', {
      'id': 'per_1',
      'sessionID': 'ses_1',
      'action': 'bash',
      'resources': ['rm -rf build'],
    }));
    expect(controller.pendingPermissions, hasLength(1));
    expect(controller.pendingPermissions.single.action, 'bash');

    controller.handleEvent(event('permission.replied', {
      'sessionID': 'ses_1',
      'requestID': 'per_1',
    }));
    expect(controller.pendingPermissions, isEmpty);
  });

  test('usage events update per-session totals', () {
    controller.handleEvent(event('session.usage.updated', {
      'sessionID': 'ses_1',
      'cost': 0.5,
      'tokens': {
        'input': 100,
        'output': 20,
        'reasoning': 0,
        'cache': {'read': 0, 'write': 0},
      },
    }));
    expect(controller.usage['ses_1']?.cost, 0.5);
    expect(controller.usage['ses_1']?.tokens.input, 100);
  });

  test('notifications are coalesced into at most one per frame', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    for (var index = 0; index < 3; index++) {
      controller.handleEvent(event('session.text.delta', {
        'sessionID': 'ses_1',
        'assistantMessageID': 'msg_1',
        'ordinal': 0,
        'delta': 'chunk$index',
      }));
    }
    expect(controller.messages.single.parts.whereType<ChatTextPart>().single.text,
        'chunk0chunk1chunk2');
    expect(notifications, 0, reason: 'notification is deferred to the frame');
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(notifications, 1);
  });

  test('theme mode toggles between dark and light', () {
    expect(controller.themeMode.value, ThemeMode.dark);
    controller.toggleThemeMode();
    expect(controller.themeMode.value, ThemeMode.light);
    controller.toggleThemeMode();
    expect(controller.themeMode.value, ThemeMode.dark);
  });
}

SessionInfo _session(String id) => SessionInfo.fromJson({
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
      'title': 'Test session',
    });
