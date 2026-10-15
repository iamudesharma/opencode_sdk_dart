// A live end-to-end check for the chat controller against a running OpenCode
// service. It is not part of the default test suite (it needs a live server
// and makes a real model call). Run it explicitly:
//
//   flutter test tool/live_chat_check.dart
//
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_chat/src/chat_controller.dart';
import 'package:opencode_chat/src/chat_models.dart';

void main() {
  test(
    'live: a prompt streams into the transcript and cleans up',
    () async {
      // flutter_test blocks real HTTP by default.
      HttpOverrides.global = null;
      final controller = ChatController();
      try {
        await controller.connectLocal();
        expect(controller.connection, ChatConnection.connected,
            reason: 'expected a local service');
        print('connected: v${controller.serverVersion} '
            'sessions=${controller.sessions.length} '
            'agents=${controller.agents.length} '
            'models=${controller.models.length}');

        final session = await controller.newSession();
        expect(session, isNotNull);
        await controller.send('Reply with exactly: pong');

        // Wait for the assistant text to stream in.
        final deadline = DateTime.now().add(const Duration(seconds: 90));
        String assistantText() {
          final buffer = StringBuffer();
          for (final message in controller.messages) {
            if (message.role != ChatRole.assistant) continue;
            for (final part in message.parts) {
              if (part is ChatTextPart) buffer.write(part.text);
            }
          }
          return buffer.toString();
        }

        while (DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (assistantText().toLowerCase().contains('pong')) break;
        }

        final userText = controller.messages
            .where((message) => message.role == ChatRole.user)
            .map((message) => message.text)
            .join('\n');
        final toolCount = controller.messages
            .expand((message) => message.parts)
            .whereType<ChatToolPart>()
            .length;
        print('user prompt: $userText');
        print('assistant text: ${assistantText()}');
        print('tools used: $toolCount');

        expect(userText, contains('Reply with exactly: pong'));
        expect(assistantText().toLowerCase(), contains('pong'));

        await controller.deleteSession(session!.id);
        expect(
          controller.sessions.where((item) => item.id == session.id),
          isEmpty,
        );
        print('LIVE CHAT CHECK PASSED');
      } finally {
        controller.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
