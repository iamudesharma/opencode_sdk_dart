// ignore_for_file: avoid_print
import 'dart:async';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

Future<void> main() async {
  // 1. Discover the local background service through the SDK.
  final endpoint = await OpenCodeService.discover();
  print('discovered: $endpoint');
  if (endpoint == null) {
    print('no local service found');
    return;
  }

  final client = OpenCodeClient(
    baseUrl: endpoint.url,
    headers: OpenCodeService.headers(endpoint),
  );

  try {
    // 2. Server info.
    final info = await client.server.info();
    print('server: ${info.version} pid=${info.pid} urls=${info.urls}');

    // 3. Agents (located response envelope).
    final agents = await client.agent.list();
    print('agents at ${agents.location.directory}:');
    for (final agent in agents.data) {
      print('  - ${agent.name} (${agent.mode}) built-in=${agent.hidden}');
    }

    // 4. Sessions (query parameters + pagination model).
    final sessions = await client.session.list(
      limit: '2',
      order: SessionListOrder.desc,
    );
    print('sessions returned: ${sessions.data.length}');
    for (final session in sessions.data) {
      print('  - ${session.id} title=${session.title}');
    }

    // 5. Models + config (typed unions and enums on live data).
    final models = await client.model.list();
    print('models for default provider: ${models.data.length}');

    // 6. Short event stream: validates SSE framing on the live server.
    final events = <String>[];
    final subscription = client.event.subscribe().listen((event) {
      events.add(event.type);
    });
    await Future<void>.delayed(const Duration(seconds: 3));
    await subscription.cancel();
    print('events seen in 3s: ${events.length} '
        '(${events.take(5).join(', ')})');

    // 7. Message listing for the newest session, when one exists.
    if (sessions.data.isNotEmpty) {
      final messages = await client.session.message
          .list(sessionID: sessions.data.first.id, limit: '2');
      print('messages in newest session: ${messages.data.length}');
      for (final message in messages.data) {
        final kind = switch (message) {
          SessionMessageUser() => 'user',
          SessionMessageAssistant() => 'assistant',
          SessionMessageCompactionRunning() => 'compaction(running)',
          SessionMessageCompactionCompleted() => 'compaction(completed)',
          SessionMessageCompactionFailed() => 'compaction(failed)',
          _ => message.type,
        };
        print('  - ${message.id} ($kind)');
      }
    }

    print('LIVE SMOKE TEST PASSED');
  } finally {
    client.close();
  }
}
