import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

http.StreamedResponse jsonStream(Object? body, {int status = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream<List<int>>.value(bytes),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// A scripted OpenCode server for session-turn tests.
final class FakeTurnServer {
  FakeTurnServer({this.eventFrames = const []});

  /// Frames (raw JSON maps) written to the event stream after connecting.
  List<Map<String, Object?>> eventFrames;

  /// When set, `GET .../message` reports this as the completed assistant text.
  String? assistantText;

  /// When set, the same message also reports this reasoning text.
  String? assistantReasoning;

  /// When false, the assistant message lacks `time.completed`.
  bool assistantCompleted = true;

  /// When true, the prompt request fails with 409.
  bool failPrompt = false;

  int waitCalls = 0;

  http.Client get client => MockClient.streaming(_handle);

  Future<http.StreamedResponse> _handle(
    http.BaseRequest request,
    http.ByteStream bodyStream,
  ) async {
    await bodyStream.toBytes();
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == '/api/event') {
      final payload = StringBuffer();
      payload.write(
        'data: ${jsonEncode({
          'type': 'server.connected',
          'data': <String, Object?>{},
        })}\n\n',
      );
      for (final frame in eventFrames) {
        payload.write('data: ${jsonEncode(frame)}\n\n');
      }
      return http.StreamedResponse(
        Stream<List<int>>.value(utf8.encode(payload.toString())),
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (method == 'POST' && path == '/api/session/ses_1/prompt') {
      if (failPrompt) {
        return jsonStream({'error': {'message': 'busy'}}, status: 409);
      }
      return jsonStream({
        'data': {
          'id': 'msg_1',
          'sessionID': 'ses_1',
          'time': {'created': 1},
          'type': 'user',
          'payload': {'text': 'prompt'},
          'delivery': 'steer',
        },
      });
    }
    if (method == 'POST' &&
        path == '/api/experimental/session/ses_1/wait') {
      waitCalls++;
      return http.StreamedResponse(const Stream<List<int>>.empty(), 204);
    }
    if (method == 'GET' && path == '/api/session/ses_1/message') {
      final text = assistantText;
      return jsonStream({
        'data': [
          if (text != null)
            {
              'id': 'msg_2',
              'type': 'assistant',
              'agent': 'build',
              'model': {'id': 'm', 'providerID': 'p'},
              'time': {
                'created': 1,
                if (assistantCompleted) 'completed': 2,
              },
              'content': [
                if (assistantReasoning != null)
                  {'type': 'reasoning', 'text': assistantReasoning},
                if (text.isNotEmpty) {'type': 'text', 'text': text},
              ],
            },
        ],
        'cursor': <String, Object?>{},
      });
    }
    return jsonStream(
      {'error': {'message': 'no route for $method $path'}},
      status: 404,
    );
  }
}

Map<String, Object?> textDelta(String delta) => {
  'type': 'session.text.delta',
  'data': {'sessionID': 'ses_1', 'delta': delta},
};

Map<String, Object?> reasoningDelta(String delta) => {
  'type': 'session.reasoning.delta',
  'data': {'sessionID': 'ses_1', 'delta': delta},
};

Map<String, Object?> textEnded(String text) => {
  'type': 'session.text.ended',
  'data': {'sessionID': 'ses_1', 'text': text},
};

Map<String, Object?> reasoningEnded(String text) => {
  'type': 'session.reasoning.ended',
  'data': {'sessionID': 'ses_1', 'text': text},
};

Map<String, Object?> stepEnded() => {
  'type': 'session.step.ended',
  'data': {
    'sessionID': 'ses_1',
    'tokens': {
      'input': 10,
      'output': 5,
      'reasoning': 3,
      'cache': {'read': 2, 'write': 1},
    },
    'cost': 0.01,
  },
};

Map<String, Object?> executionSucceeded() => {
  'type': 'session.execution.succeeded',
  'data': {'sessionID': 'ses_1'},
};

OpenCodeClient clientFor(FakeTurnServer server) => OpenCodeClient(
  baseUrl: Uri.parse('http://fake.opencode'),
  httpClient: server.client,
  clientFactory: () => server.client,
);

void main() {
  group('streamPrompt', () {
    test('streams deltas and resolves the reconciled result', () async {
      final server = FakeTurnServer()
        ..eventFrames = [
          textDelta('Hello'),
          reasoningDelta('thinking'),
          textDelta(' world'),
          stepEnded(),
          executionSucceeded(),
        ];
      final client = clientFor(server);

      final turn = client.streamPrompt(
        sessionID: SessionID('ses_1'),
        text: 'Hi',
      );
      final events = <SessionTurnEvent>[];
      await for (final event in turn) {
        events.add(event);
      }
      final result = await turn.result;

      expect(result.text, 'Hello world');
      expect(result.reasoning, 'thinking');
      expect(result.usage.totalTokens, 21);
      expect(result.usage.cost, 0.01);
      expect(result.admitted, isA<SessionInboxUser>());
      expect(
        events.whereType<SessionTurnTextDelta>().map((e) => e.delta),
        ['Hello', ' world'],
      );
      expect(
        events.whereType<SessionTurnReasoningDelta>().single.delta,
        'thinking',
      );
      expect(events.whereType<SessionTurnStepUsage>(), hasLength(1));
      expect(events.last, isA<SessionTurnCompleted>());
      client.close();
    });

    test('reconciles *.ended events into the final text', () async {
      final server = FakeTurnServer()
        ..eventFrames = [
          textDelta('Hello'),
          textEnded('Hello world'),
          reasoningEnded('because'),
          executionSucceeded(),
        ];
      final client = clientFor(server);

      final turn = client.streamPrompt(
        sessionID: SessionID('ses_1'),
        text: 'Hi',
      );
      final deltas = <String>[];
      await for (final event in turn) {
        if (event is SessionTurnTextDelta) deltas.add(event.delta);
      }
      final result = await turn.result;

      // The ended event's suffix was emitted, not the whole text again.
      expect(deltas, ['Hello', ' world']);
      expect(result.text, 'Hello world');
      expect(result.reasoning, 'because');
      client.close();
    });

    test('completes from session state when the event stream ends early',
        () async {
      // The stream carries one delta and then *ends* without an execution
      // event; the turn must fall back to polling the session.
      final server = FakeTurnServer()
        ..eventFrames = [textDelta('Hello')]
        ..assistantText = 'Hello from the session record'
        ..assistantReasoning = 'thought about it';
      final client = clientFor(server);

      final turn = client.streamPrompt(
        sessionID: SessionID('ses_1'),
        text: 'Hi',
      );
      final deltas = <String>[];
      await for (final event in turn) {
        if (event is SessionTurnTextDelta) deltas.add(event.delta);
      }
      final result = await turn.result;

      expect(deltas, ['Hello']);
      expect(result.text, 'Hello from the session record');
      expect(result.reasoning, 'thought about it');
      expect(server.waitCalls, greaterThan(0));
      client.close();
    });

    test('fails the turn when the execution fails', () async {
      final server = FakeTurnServer()
        ..eventFrames = [
          {
            'type': 'session.execution.failed',
            'data': {
              'sessionID': 'ses_1',
              'error': {'message': 'model exploded'},
            },
          },
        ];
      final client = clientFor(server);

      final turn = client.streamPrompt(
        sessionID: SessionID('ses_1'),
        text: 'Hi',
      );

      await expectLater(
        turn.result,
        throwsA(
          isA<OpenCodeExecutionException>().having(
            (error) => error.message,
            'message',
            contains('model exploded'),
          ),
        ),
      );
      await turn.drain<void>();
      client.close();
    });

    test('fails when the prompt is rejected', () async {
      final server = FakeTurnServer()..failPrompt = true;
      final client = clientFor(server);

      final turn = client.streamPrompt(
        sessionID: SessionID('ses_1'),
        text: 'Hi',
      );

      await expectLater(turn.result, throwsA(isA<OpenCodeApiException>()));
      await turn.drain<void>();
      client.close();
    });
  });

  group('pagination', () {
    test('session.listAll follows cursor.next', () async {
      final pages = <String?>[];
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://fake.opencode'),
        httpClient: MockClient((request) async {
          pages.add(request.url.queryParameters['cursor']);
          if (request.url.queryParameters['cursor'] == null) {
            return jsonResponse({
              'data': [sessionPayload(id: 'ses_1'), sessionPayload(id: 'ses_2')],
              'cursor': {'next': 'cur_2'},
            });
          }
          return jsonResponse({
            'data': [sessionPayload(id: 'ses_3')],
            'cursor': <String, Object?>{},
          });
        }),
      );

      final sessions = await client.session.listAll().toList();
      expect(sessions.map((session) => session.id.value), [
        'ses_1',
        'ses_2',
        'ses_3',
      ]);
      expect(pages, [null, 'cur_2']);
      client.close();
    });

    test('message.listAll follows cursor.next', () async {
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://fake.opencode'),
        httpClient: MockClient((request) async {
          if (request.url.queryParameters['cursor'] == null) {
            return jsonResponse({
              'data': [userMessagePayload(id: 'msg_1')],
              'cursor': {'next': 'cur_2'},
            });
          }
          return jsonResponse({
            'data': [userMessagePayload(id: 'msg_2')],
            'cursor': <String, Object?>{},
          });
        }),
      );

      final messages = await client.session.message
          .listAll(sessionID: SessionID('ses_1'))
          .toList();
      expect(messages.map((message) => message.id.value), ['msg_1', 'msg_2']);
      client.close();
    });
  });
}
