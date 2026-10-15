// ignore_for_file: avoid_print
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// A small end-to-end example: connect to the local OpenCode service, list
/// agents, create a session, stream a prompt, and clean up.
Future<void> main() async {
  // `connectLocal` discovers (or starts) the background service and applies
  // its authentication headers. For a remote server use:
  //
  //   final client = OpenCodeClient.make(baseUrl: Uri.parse('http://host:4096'));
  final client = await OpenCodeClient.connectLocal();

  try {
    final info = await client.server.info();
    print('Connected to OpenCode ${info.version} (pid ${info.pid})');
    print('URLs: ${info.urls.join(', ')}');

    final agents = await client.agent.list();
    print('Agents: ${agents.data.map((agent) => agent.name).join(', ')}');

    // Native events and plugin RPC share one lazily opened connection.
    final subscription = client.event.subscribe().listen((event) {
      if (event.type.startsWith('message.') ||
          event.type.startsWith('session.')) {
        print('event: ${event.type}');
      }
    });

    final session = await client.session.create(title: 'dart-sdk example');
    print('Created session $session');

    final inbox = await client.session.prompt(
      sessionID: session.id,
      text: 'Say hello in exactly five words.',
    );
    print('Queued message ${inbox.id} (${inbox.type})');

    // Give the assistant a moment to stream its answer.
    await Future<void>.delayed(const Duration(seconds: 5));

    final messages = await client.session.message.list(sessionID: session.id);
    print('Session has ${messages.data.length} messages');

    await subscription.cancel();
  } finally {
    client.close();
  }
}
