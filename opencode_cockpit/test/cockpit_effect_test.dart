import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_cockpit/src/cockpit_controller.dart';
import 'package:opencode_cockpit/src/models.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

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

/// Covers the effect-bridge migration contracts of the controller:
/// read retries, write isolation, typed error surfacing, streamed event
/// ordering, and fiber cancellation on dispose.
void main() {
  http.Response json(Object? body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  Map<String, Object?> sessionPayload({String id = 'ses_1'}) => {
    'id': id,
    'projectID': 'prj_1',
    'cost': 0.01,
    'tokens': {
      'input': 10,
      'output': 20,
      'reasoning': 0,
      'cache': {'read': 0, 'write': 0},
    },
    'time': {'created': 1, 'updated': 2},
    'location': {'directory': '/workspace'},
    'title': 'Effect session',
  };

  Map<String, Object?> projectPayload() => {
    'id': 'prj_1',
    'canonical': '/workspace',
    'name': 'workspace',
    'commands': <String, Object?>{},
    'sandboxes': <Object?>[],
    'time': {'created': 1, 'updated': 2, 'active': 3},
  };

  /// The connect-time responses every controller needs.
  Object? cannedBody(http.BaseRequest request) {
    switch ((request.method, request.url.path)) {
      case ('GET', '/api/info'):
        return {
          'version': '2.0.28',
          'pid': 42,
          'urls': ['http://localhost:4096'],
          'paths': {'tmp': '/tmp'},
        };
      case ('GET', '/api/project'):
        return [projectPayload()];
      case ('GET', '/api/session'):
        return {
          'data': [sessionPayload()],
          'cursor': <String, Object?>{},
        };
      case ('GET', '/api/agent'):
      case ('GET', '/api/model'):
        return {
          'location': {'directory': '/workspace'},
          'data': <Object?>[],
        };
    }
    return null;
  }

  /// A mock server whose `handler` answers first (return `null` to fall back
  /// to the canned responses).
  MockClient server(Future<http.Response?> Function(http.Request) handler) =>
      MockClient((request) async {
        final override = await handler(request);
        if (override != null) return override;
        if (request.url.path == '/api/event') {
          return http.Response(
            '',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }
        final body = cannedBody(request);
        if (body == null) {
          return json({
            'message': 'unhandled ${request.url.path}',
          }, status: 404);
        }
        return json(body);
      });

  /// A mock server whose event connection is driven by [events].
  MockClient streamingServer(
    Stream<List<int>> events, {
    void Function()? onEvent,
  }) => MockClient.streaming((request, body) async {
    if (request.url.path == '/api/event') {
      onEvent?.call();
      return http.StreamedResponse(
        events,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    final canned = cannedBody(request);
    return http.StreamedResponse(
      http.ByteStream.fromBytes(
        utf8.encode(jsonEncode(canned ?? {'message': 'unhandled'})),
      ),
      canned == null ? 404 : 200,
      headers: {'content-type': 'application/json'},
    );
  });

  SessionInfo activeSession() => SessionInfo.fromJson(sessionPayload());

  test('reads retry transient failures exactly like the old policy', () async {
    var projectRequests = 0;
    final controller = CockpitController()
      ..httpClientFactory = () => server((request) async {
        if (request.method == 'GET' && request.url.path == '/api/project') {
          projectRequests++;
          if (projectRequests < 3) {
            return json({'message': 'starting up'}, status: 503);
          }
        }
        return null;
      });

    await controller.connectTo(Uri.parse('http://localhost:4096'));

    // Three attempts total: the old `RetryPolicy(maxAttempts: 3)`.
    expect(projectRequests, 3);
    expect(controller.projects.single.id, 'prj_1');
    expect(controller.connectionError, isNull);
    controller.dispose();
  });

  test('read failures that are not transient surface once, typed', () async {
    var sessionRequests = 0;
    final controller = CockpitController()
      ..httpClientFactory = () => server((request) async {
        if (request.method == 'GET' && request.url.path == '/api/session') {
          sessionRequests++;
          return json({'message': 'gone away'}, status: 404);
        }
        return null;
      });

    await controller.connectTo(Uri.parse('http://localhost:4096'));

    expect(sessionRequests, 1);
    // `OpenCodeApiError` carries the old `OpenCodeStatusException` message.
    expect(controller.connectionError, 'gone away');
    controller.dispose();
  });

  test('writes are never retried, even on transient statuses', () async {
    var prompts = 0;
    final controller = CockpitController()
      ..httpClientFactory = () => server((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/api/session/ses_1/prompt') {
          prompts++;
          return json({'message': 'server busy'}, status: 503);
        }
        return null;
      });

    await controller.connectTo(Uri.parse('http://localhost:4096'));
    controller.activeSession = activeSession();
    await controller.send('hello');

    // A re-sent prompt could run the turn twice; one attempt only.
    expect(prompts, 1);
    expect(controller.connectionError, 'server busy');
    expect(controller.sending, isFalse);
    controller.dispose();
  });

  test('the shared event stream feeds the reducer in order', () async {
    final frames = StreamController<List<int>>();
    var subscribed = 0;
    final controller = CockpitController()
      ..httpClientFactory = () =>
          streamingServer(frames.stream, onEvent: () => subscribed++);

    await controller.connectTo(Uri.parse('http://localhost:4096'));
    expect(subscribed, 1);
    controller.activeSession = activeSession();

    void frame(String type, Map<String, Object?> data) {
      frames.add(
        utf8.encode(
          'data: ${jsonEncode({'type': type, 'created': 1000, 'data': data})}\n\n',
        ),
      );
    }

    frame('session.execution.started', {'sessionID': 'ses_1'});
    frame('session.step.started', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'agent': 'build',
    });
    frame('session.text.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'delta': 'Hel',
    });
    frame('session.text.delta', {
      'sessionID': 'ses_1',
      'assistantMessageID': 'msg_1',
      'ordinal': 0,
      'delta': 'lo',
    });
    await pumpEventQueue();

    expect(controller.activeBusy, isTrue);
    expect(
      controller.messages.single.parts.whereType<ChatTextPart>().single.text,
      'Hello',
    );

    frame('session.execution.succeeded', {'sessionID': 'ses_1'});
    await pumpEventQueue();
    expect(controller.activeBusy, isFalse);

    controller.dispose();
    await pumpEventQueue();
    await frames.close();
  });

  test('dispose cancels the shared event subscription and its fiber', () async {
    final frames = StreamController<List<int>>();
    var events = 0;
    var eventClientClosed = false;
    final controller = CockpitController()
      ..httpClientFactory = () => _TrackingClient(
        streamingServer(frames.stream, onEvent: () => events++),
        (servedEvents) {
          if (servedEvents) eventClientClosed = true;
        },
      );

    await controller.connectTo(Uri.parse('http://localhost:4096'));
    expect(events, 1);

    controller.dispose();
    // The toNative fiber interrupted its consumption, which removed the
    // multiplexer subscriber, cancelled the connection token, and force-closed
    // the dedicated SSE HTTP client.
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!eventClientClosed && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(eventClientClosed, isTrue);
    await frames.close();
  });

  test('connect failures surface the typed bridge error', () async {
    final controller = CockpitController()
      ..httpClientFactory = () =>
          MockClient((request) async => json({'message': 'nope'}, status: 500));

    await controller.connectTo(Uri.parse('http://localhost:4096'));

    expect(controller.connection, CockpitConnection.failed);
    expect(controller.connectionError, 'nope');
    controller.dispose();
  });

  test('theme and panel behavior is unchanged after the migration', () {
    final controller = CockpitController();
    expect(controller.themeMode, ThemeMode.dark);
    controller.toggleTheme();
    expect(controller.themeMode, ThemeMode.light);
    controller.dispose();
  });
}
