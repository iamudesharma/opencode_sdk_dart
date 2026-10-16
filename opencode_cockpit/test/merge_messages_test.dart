import 'package:flutter_test/flutter_test.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/models.dart';

void main() {
  ChatMessage message(
    String id, {
    ChatRole role = ChatRole.assistant,
    bool streaming = false,
    String text = '',
  }) => ChatMessage(
    id: id,
    role: role,
    time: DateTime(2026, 10, 16, 12),
    text: text,
    streaming: streaming,
  );

  group('mergeLoadedMessages', () {
    test('keeps live streaming messages the server has not recorded yet', () {
      final live = message('msg_live', streaming: true, text: 'partial');
      final merged = mergeLoadedMessages(
        [message('msg_user', role: ChatRole.user, text: 'hi')],
        [message('msg_user', role: ChatRole.user, text: 'hi'), live],
      );

      expect(merged.map((m) => m.id), ['msg_user', 'msg_live']);
      expect(identical(merged.last, live), isTrue);
    });

    test('a live streaming message wins over its server version', () {
      final live = message('msg_a', streaming: true, text: 'streamed so far');
      final server = message('msg_a', text: 'server copy');
      final merged = mergeLoadedMessages([server], [live]);

      expect(merged, hasLength(1));
      expect(identical(merged.single, live), isTrue);
      expect(merged.single.text, 'streamed so far');
    });

    test('drops optimistic echoes and settled messages the server replaced',
        () {
      final echo = message('local_1', role: ChatRole.user, text: 'hi');
      final merged = mergeLoadedMessages(
        [message('msg_user', role: ChatRole.user, text: 'hi')],
        [echo],
      );

      expect(merged.map((m) => m.id), ['msg_user']);
    });

    test('keeps server order for settled messages', () {
      final merged = mergeLoadedMessages(
        [message('msg_1'), message('msg_2'), message('msg_3')],
        const [],
      );

      expect(merged.map((m) => m.id), ['msg_1', 'msg_2', 'msg_3']);
    });
  });
}
