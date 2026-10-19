import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:effect_core/effect_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/services/persistent_terminal.dart';
import 'package:opencode_cockpit/src/terminal_session.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Drives the PTY services (and the shared event stream) against a real
/// loopback server with a real WebSocket, covering the effect-owned socket
/// lifecycle: `ptyConnect`/`persistentPtyConnect` acquire, `ptyFrames` consume,
/// `ptyClose` release, and fiber interruption on close.
/// An HTTP client that records which paths it served and reports when it is
/// closed, so the test can observe the effect-owned SSE teardown.
final class _TrackingClient extends http.BaseClient {
  _TrackingClient(this._inner, this._onClose);

  final http.Client _inner;
  final void Function(bool servedEvents) _onClose;
  bool _servedEvents = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request.url.path == '/api/event') _servedEvents = true;
    return _inner.send(request);
  }

  @override
  void close() {
    _onClose(_servedEvents);
    _inner.close();
  }
}

void main() {
  setUpAll(() {
    // Loopback sockets instead of the test binding's blocked HTTP client.
    HttpOverrides.global = null;
  });

  Future<void> respondJson(
    HttpRequest request,
    Object? body, {
    int status = 200,
  }) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    await request.response.close();
  }

  Map<String, Object?> ptyPayload(String id) => {
    'id': id,
    'title': 'cockpit',
    'command': '/bin/zsh',
    'args': <String>[],
    'cwd': '/workspace',
    'status': 'running',
    'pid': 4242,
  };

  Map<String, Object?> persistentPtyPayload(String id) => {
    'id': id,
    'title': 'shell 10:00',
    'command': '/bin/zsh',
    'args': <String>[],
    'cwd': '/workspace',
    'status': 'running',
    'pid': 4343,
    'sessionID': 'ses_1',
    'size': {'cols': 80, 'rows': 24},
    'output': {'head': 0, 'tail': 0},
  };

  (EffectOpenCodeClient, Runtime<Unit>) makeClient(Uri baseUrl) {
    final sdk = OpenCodeClient(baseUrl: baseUrl)..transport.retry = null;
    return (EffectOpenCodeClient(sdk), Runtime<Unit>(Unit.value));
  }

  /// Waits for [condition], polling until [timeout] elapses.
  Future<void> waitFor(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for the expected state');
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  test('terminal sessions acquire, stream, and release their socket', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final log = <String>[];
    final serverSockets = <WebSocket>[];
    final received = <Object?>[];
    final socketClosed = Completer<void>();
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      log.add('${request.method} ${request.uri.path}');
      switch ((request.method, request.uri.path)) {
        case ('POST', '/api/pty'):
          await respondJson(request, {
            'location': {'directory': '/workspace'},
            'data': ptyPayload('pty_1'),
          });
        case ('POST', '/api/pty/pty_1/connect-token'):
          await respondJson(request, {
            'location': {'directory': '/workspace'},
            'data': {'ticket': 't1', 'expires_in': 60},
          });
        case ('GET', '/api/pty/pty_1/connect'):
          final socket = await WebSocketTransformer.upgrade(request);
          serverSockets.add(socket);
          socket.add('welcome from pty\r\n');
          socket.add(utf8.encode('{"cursor":42}'));
          socket.listen(
            received.add,
            onDone: () {
              if (!socketClosed.isCompleted) socketClosed.complete();
            },
          );
        case ('PUT', '/api/pty/pty_1'):
          await respondJson(request, {
            'location': {'directory': '/workspace'},
            'data': ptyPayload('pty_1'),
          });
        case ('DELETE', '/api/pty/pty_1'):
          request.response.statusCode = 204;
          await request.response.close();
        default:
          await respondJson(request, {'message': 'unhandled'}, status: 404);
      }
    });

    final (client, runtime) = makeClient(
      Uri.parse('http://127.0.0.1:${server.port}'),
    );
    final session = TerminalSession();
    await session.start(
      client,
      runtime,
      location: const LocationRef('/workspace'),
      title: 'cockpit',
    );

    expect(session.status, TerminalStatus.running);
    expect('${session.ptyID}', 'pty_1');
    await waitFor(() => session.terminal.buffer.getText().contains('welcome'));
    // The resume cursor came from the binary frame on the text stream.
    expect(session.cursor, 42);

    session.sendInput('echo hi\r');
    await waitFor(() => received.any((message) => message == 'echo hi\r'));

    // The debounced resize reaches the server as a write.
    await waitFor(() => log.contains('PUT /api/pty/pty_1'));

    await session.dispose();
    expect(session.ptyID, isNull);
    expect(log, contains('DELETE /api/pty/pty_1'));
    // Disposing interrupted the consumer fiber, which released the socket.
    await socketClosed.future.timeout(const Duration(seconds: 5));

    await runtime.shutdown();
    client.close();
  });

  test('terminal start failures surface the typed API message', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      if (request.method == 'POST' && request.uri.path == '/api/pty') {
        await respondJson(request, {
          'message': 'no shells for you',
        }, status: 500);
        return;
      }
      await respondJson(request, {'message': 'unhandled'}, status: 404);
    });

    final (client, runtime) = makeClient(
      Uri.parse('http://127.0.0.1:${server.port}'),
    );
    final session = TerminalSession();
    await session.start(client, runtime, location: const LocationRef());

    // The old `on OpenCodeApiException` message channel, now typed.
    expect(session.status, TerminalStatus.failed);
    expect(session.error, 'no shells for you');
    expect(session.ptyID, isNull);

    await session.dispose();
    await runtime.shutdown();
    client.close();
  });

  test('persistent attachments detach without killing the terminal', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final log = <String>[];
    final received = <Object?>[];
    final socketClosed = Completer<void>();
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      log.add('${request.method} ${request.uri.path}');
      switch ((request.method, request.uri.path)) {
        case ('POST', '/api/experimental/persistent-pty/pty_9/connect-token'):
          await respondJson(request, {
            'data': {'ticket': 't9', 'expires_in': 60},
          });
        case ('GET', '/api/experimental/persistent-pty/pty_9/connect'):
          final socket = await WebSocketTransformer.upgrade(request);
          socket.add('persistent output\r\n');
          socket.listen(
            received.add,
            onDone: () {
              if (!socketClosed.isCompleted) socketClosed.complete();
            },
          );
        default:
          await respondJson(request, {'message': 'unhandled'}, status: 404);
      }
    });

    final (client, runtime) = makeClient(
      Uri.parse('http://127.0.0.1:${server.port}'),
    );
    final session = PersistentTerminalSession();
    final info = PersistentPtyInfo.fromJson(persistentPtyPayload('pty_9'));
    await session.attach(client, runtime, info);

    expect(session.status, PersistentTerminalStatus.attached);
    await waitFor(
      () => session.terminal.buffer.getText().contains('persistent output'),
    );

    // Framed input (`input_protocol=1`) travels as a binary control frame.
    session.sendInput('ls\r');
    await waitFor(() {
      return received.any(
        (message) => message is List<int> && message.first == 1,
      );
    });

    await session.detach();
    expect(session.status, PersistentTerminalStatus.detached);
    await socketClosed.future.timeout(const Duration(seconds: 5));
    // Detaching only closes the socket: the terminal survives server-side.
    expect(log.where((entry) => entry.startsWith('DELETE')), isEmpty);

    await runtime.shutdown();
    client.close();
  });

  test('dispose cancels the shared event subscription and its fiber', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var eventRequested = false;
    var eventClientClosed = false;
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      switch ((request.method, request.uri.path)) {
        case ('GET', '/api/info'):
          await respondJson(request, {
            'version': '2.0.28',
            'pid': 42,
            'urls': <String>[],
            'paths': {'tmp': '/tmp'},
          });
        case ('GET', '/api/project'):
          await respondJson(request, <Object?>[]);
        case ('GET', '/api/session'):
          await respondJson(request, {
            'data': <Object?>[],
            'cursor': <String, Object?>{},
          });
        case ('GET', '/api/agent'):
        case ('GET', '/api/model'):
          await respondJson(request, {
            'location': {'directory': '/workspace'},
            'data': <Object?>[],
          });
        case ('GET', '/api/event'):
          eventRequested = true;
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType(
              'text',
              'event-stream',
              charset: 'utf-8',
            );
          request.response.write(
            'data: ${jsonEncode({'type': 'server.connected', 'data': <String, Object?>{}})}\n\n',
          );
          await request.response.flush();
        default:
          await respondJson(request, {'message': 'unhandled'}, status: 404);
      }
    });

    final controller = CockpitController()
      ..httpClientFactory = () => _TrackingClient(IOClient(), (servedEvents) {
        if (servedEvents) eventClientClosed = true;
      });
    await controller.connectTo(Uri.parse('http://127.0.0.1:${server.port}'));
    expect(controller.connection, CockpitConnection.connected);
    expect(controller.client?.multiplexer.isConnected, isTrue);
    await waitFor(() => eventRequested);

    controller.dispose();
    // Cancelling the native subscription interrupted the toNative fiber,
    // which removed the multiplexer subscriber and cancelled the connection
    // token: `sseFrames` then force-closes its dedicated HTTP client.
    await waitFor(() => eventClientClosed);
  });
}
