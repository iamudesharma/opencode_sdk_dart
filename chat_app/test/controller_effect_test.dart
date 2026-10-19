import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_chat/src/chat_controller.dart';

/// Exercises the controller over the effect bridge with a scripted server:
/// typed error surfacing, read retry / write parity, event reconnect and
/// fiber-based cancellation.
void main() {
  test('connect surfaces the typed API error message to the UI', () async {
    final paths = <String>[];
    final server = _scriptedServer(
      events: [],
      paths: paths,
      route: (request) async {
        if (request.url.path == '/api/info') {
          return _json({'message': 'bad token'}, status: 401);
        }
        return _json({'message': 'unexpected'}, status: 500);
      },
    );
    final controller = ChatController(clientFactory: server);
    addTearDown(controller.dispose);

    await controller.connectTo(Uri.parse('http://127.0.0.1:4096'));

    expect(controller.connection, ChatConnection.failed);
    expect(controller.connectionError, 'bad token');
    expect(paths, ['/api/info'],
        reason: '401 is not transient: the read is attempted once');
  });

  test('transient read failures retry; prompt writes never retry', () async {
    var sessionListCalls = 0;
    var promptCalls = 0;
    final events = <_MockEventConnection>[];

    final server = _scriptedServer(
      events: events,
      route: (request) async {
        switch (request.url.path) {
          case '/api/info':
            return _json({
              'version': '9.9.9',
              'pid': 7,
              'urls': <Object?>[],
              'paths': {'tmp': '/tmp'},
            });
          case '/api/session':
            sessionListCalls++;
            if (sessionListCalls <= 2) {
              return _json({'message': 'warming up'}, status: 503);
            }
            return _json({
              'data': [_sessionJson('ses_1')],
              'cursor': <String, Object?>{},
            });
          case '/api/agent':
          case '/api/model':
            return _json({
              'location': <String, Object?>{},
              'data': <Object?>[],
            });
          case '/api/session/ses_1/message':
            return _json({'data': <Object?>[], 'cursor': <String, Object?>{}});
          case '/api/session/ses_1/prompt':
            promptCalls++;
            return _json({'message': 'no prompt today'}, status: 503);
          default:
            return _json({'message': 'unexpected'}, status: 500);
        }
      },
    );
    final controller = ChatController(clientFactory: server);
    addTearDown(() {
      controller.dispose();
      for (final connection in events) {
        connection.dispose();
      }
    });

    await controller.connectTo(Uri.parse('http://127.0.0.1:4096'));

    expect(controller.connection, ChatConnection.connected);
    expect(controller.serverVersion, '9.9.9');
    expect(sessionListCalls, 3,
        reason: 'reads retry transient failures (3 attempts, as before)');
    expect(controller.sessions.map((session) => session.id), ['ses_1']);

    controller.activeSession = controller.sessions.single;
    await controller.send('hello');

    expect(promptCalls, 1, reason: 'a prompt is a write: never retried');
    expect(controller.connectionError, 'no prompt today');

    // Let the post-admission transcript refresh (400 ms) settle.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(controller.connectionError, 'no prompt today');
  });

  test('a dropped event stream reconnects and reopens the subscription',
      () async {
    final events = <_MockEventConnection>[];
    final server = _scriptedServer(events: events, route: _plainRoutes);
    final controller = ChatController(clientFactory: server);
    addTearDown(() {
      controller.dispose();
      for (final connection in events) {
        connection.dispose();
      }
    });

    await controller.connectTo(Uri.parse('http://127.0.0.1:4096'));
    expect(events, hasLength(1));

    // The server drops the live-only connection.
    await events.first.controller.close();

    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (events.length < 2 && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(events, hasLength(2),
        reason: 'the controller re-listens after the 2 s backoff');
  });

  test('reconnecting tears down the previous event consumption', () async {
    final events = <_MockEventConnection>[];
    final server = _scriptedServer(events: events, route: _plainRoutes);
    final controller = ChatController(clientFactory: server);
    addTearDown(() {
      controller.dispose();
      for (final connection in events) {
        connection.dispose();
      }
    });

    await controller.connectTo(Uri.parse('http://127.0.0.1:4096'));
    await controller.connectTo(Uri.parse('http://127.0.0.1:4096'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(events, hasLength(2));
    expect(events.first.controller.isClosed, isTrue,
        reason: 'the awaited subscription cancel interrupts the event fiber, '
            'which aborts the previous connection');
    expect(events.last.controller.isClosed, isFalse);
  });
}

/// A connected server with empty session/agent/model lists.
Future<http.StreamedResponse> _plainRoutes(http.BaseRequest request) async {
  switch (request.url.path) {
    case '/api/info':
      return _json({
        'version': '1.0.0',
        'pid': 1,
        'urls': <Object?>[],
        'paths': {'tmp': '/tmp'},
      });
    case '/api/session':
      return _json({'data': <Object?>[], 'cursor': <String, Object?>{}});
    case '/api/agent':
    case '/api/model':
      return _json({'location': <String, Object?>{}, 'data': <Object?>[]});
    default:
      return _json({'message': 'unexpected'}, status: 500);
  }
}

/// Builds the `clientFactory` for a scripted server.
///
/// [route] answers JSON endpoints; `/api/event` is served here, and each
/// event connection ends when its dedicated client is closed — the same way a
/// real client aborts an in-flight SSE request.
http.Client Function() _scriptedServer({
  required List<_MockEventConnection> events,
  required Future<http.StreamedResponse> Function(http.BaseRequest request)
      route,
  List<String>? paths,
}) {
  return () {
    late final _TrackingClient client;
    client = _TrackingClient(
      MockClient.streaming((request, _) async {
        paths?.add(request.url.path);
        if (request.url.path == '/api/event') {
          final connection = _MockEventConnection();
          events.add(connection);
          return client.trackSse(connection.controller);
        }
        return route(request);
      }),
    );
    return client;
  };
}

/// An `http.Client` whose [close] aborts the SSE connections it opened.
final class _TrackingClient extends http.BaseClient {
  _TrackingClient(this._inner);

  final http.Client _inner;
  final List<StreamController<List<int>>> _open = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request);

  http.StreamedResponse trackSse(StreamController<List<int>> controller) {
    _open.add(controller);
    return http.StreamedResponse(
      controller.stream,
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  }

  @override
  void close() {
    for (final controller in _open) {
      if (!controller.isClosed) controller.close();
    }
    _open.clear();
    _inner.close();
  }
}

/// One event connection opened by the controller's event subscription.
class _MockEventConnection {
  final StreamController<List<int>> controller = StreamController();

  void dispose() {
    if (!controller.isClosed) controller.close();
  }
}

http.StreamedResponse _json(Object? body, {int status = 200}) =>
    http.StreamedResponse(
      http.ByteStream.fromBytes(utf8.encode(jsonEncode(body))),
      status,
      headers: {'content-type': 'application/json'},
    );

Map<String, Object?> _sessionJson(String id) => {
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
    };
