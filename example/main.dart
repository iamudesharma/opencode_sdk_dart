// ignore_for_file: avoid_print
import 'dart:io';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// End-to-end tour of the SDK against the local OpenCode service.
///
/// Run with `dart run example/main.dart` from the repository root; the
/// service is discovered (or started) automatically, so no configuration is
/// needed.
Future<void> main() async {
  // `connectLocal` discovers (or starts) the background service and applies
  // its Basic-auth headers. For a remote server use:
  //
  //   final client = OpenCodeClient.make(
  //     baseUrl: Uri.parse('http://host:4096'),
  //   );
  final client = await OpenCodeClient.connectLocal();

  try {
    final info = await client.server.info();
    print('Connected to OpenCode ${info.version} (pid ${info.pid})');
    print('URLs: ${info.urls.join(', ')}');

    final agents = await client.agent.list();
    print('Agents: ${agents.data.map((agent) => agent.name).join(', ')}');

    // Retry transient GET/HEAD failures (3 attempts, exponential backoff).
    // Writes stay single-shot unless `retryNonIdempotent` is set, so a
    // timed-out prompt is never admitted twice.
    client.transport.retry = const RetryPolicy();

    final session = await client.session.create(title: 'dart-sdk example');
    print('Created session ${session.id}');

    final turn = client.streamPrompt(
      sessionID: session.id,
      text: 'In one short sentence, what is the OpenCode SDK?',
    );

    await for (final event in turn) {
      switch (event) {
        case SessionTurnTextDelta(:final delta):
          stdout.write(delta);
        case SessionTurnReasoningDelta(:final delta):
          stderr.write(delta);
        case SessionTurnStepUsage(:final usage):
          print('\n[step done: ${usage.totalTokens} tokens so far]');
        case SessionTurnCompleted():
          break;
      }
    }

    final result = await turn.result;
    print('\nAnswer: ${result.text}');
    print('Total tokens: ${result.usage.totalTokens}');

    final recent = await client.session.listAll().take(3).toList();
    print('Recent sessions:');
    for (final item in recent) {
      print('  ${item.title ?? '(untitled)'}');
    }
  } finally {
    client.close();
  }
}
