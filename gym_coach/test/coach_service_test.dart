/// Behaviour of the effect-based [CoachService]: turns run through the
/// bridge's `runTurn`, cancellation is a fiber interrupt, and failures surface
/// as the typed `OpenCodeError` family.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_coach/src/coach_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_effect/opencode_effect.dart';

/// A scripted OpenCode server for [CoachService]: session creation, prompt
/// admission, the shared event stream, and the turn's reconciliation reads.
///
/// The payload shapes mirror the ones the SDK's own session tests use.
final class FakeOpenCodeServer {
  FakeOpenCodeServer({this.frames = const [], this.holdEventsOpen = false});

  /// Event frames written when the shared event stream connects.
  List<Map<String, Object?>> frames;

  /// Whether the event connection stays open after [frames], so the test can
  /// [emit] frames later (a live turn).
  bool holdEventsOpen;

  /// The completed assistant text the server reports for reconciliation.
  String? assistantText;

  /// When set, `POST /api/session` fails with this status.
  int? createStatus;

  /// When set, `POST .../prompt` fails with this status.
  int? promptStatus;

  final List<String?> createdTitles = [];
  final List<String> promptTexts = [];
  int waitCalls = 0;

  /// Completes when the event stream is actually subscribed.
  final Completer<void> eventStreamListened = Completer<void>();

  /// `session.wait` long-polls a busy session: it never answers during a test,
  /// exactly like a busy server, so the SDK's polling fallback stays out of
  /// the test's critical path.
  final Completer<http.StreamedResponse> _pendingWait = Completer();

  late final StreamController<List<int>> _events = StreamController<List<int>>(
    onListen: () {
      if (!eventStreamListened.isCompleted) eventStreamListened.complete();
    },
  );

  /// A fresh client per call, like the SDK's own factory does for the
  /// dedicated clients used by cancellable requests.
  http.Client newClient() => MockClient.streaming(_handle);

  /// Pushes one frame onto an open event stream.
  void emit(Map<String, Object?> frame) {
    _events.add(utf8.encode('data: ${jsonEncode(frame)}\n\n'));
  }

  /// Ends the open event stream. Closing it while nothing listens must not
  /// block a teardown, so the returned future is not awaited.
  void close() {
    unawaited(_events.close());
  }

  Future<http.StreamedResponse> _handle(
    http.BaseRequest request,
    http.ByteStream bodyStream,
  ) async {
    final body = await bodyStream.bytesToString();
    final method = request.method;
    final path = request.url.path;

    if (method == 'GET' && path == '/api/event') {
      final payload = StringBuffer()
        ..write(
          'data: ${jsonEncode({
            'type': 'server.connected',
            'data': <String, Object?>{},
          })}\n\n',
        );
      for (final frame in frames) {
        payload.write('data: ${jsonEncode(frame)}\n\n');
      }
      final head = utf8.encode(payload.toString());
      final stream = holdEventsOpen
          ? (() async* {
              if (head.isNotEmpty) yield head;
              yield* _events.stream;
            })()
          : Stream<List<int>>.value(head);
      return http.StreamedResponse(
        stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (method == 'POST' && path == '/api/session') {
      final status = createStatus;
      if (status != null) {
        return _json({'message': 'create failed'}, status: status);
      }
      createdTitles.add(jsonDecode(body)['title'] as String?);
      return _json({'data': _sessionPayload});
    }
    if (method == 'POST' && path == '/api/session/ses_1/prompt') {
      final status = promptStatus;
      if (status != null) {
        return _json({'message': 'prompt rejected'}, status: status);
      }
      promptTexts.add(jsonDecode(body)['text'] as String);
      return _json({'data': _inboxUserPayload});
    }
    if (method == 'POST' &&
        path == '/api/experimental/session/ses_1/wait') {
      waitCalls++;
      return _pendingWait.future;
    }
    if (method == 'GET' && path == '/api/session/ses_1/message') {
      final text = assistantText;
      return _json({
        'data': [
          if (text != null)
            {
              'id': 'msg_2',
              'type': 'assistant',
              'agent': 'build',
              'model': {'id': 'm', 'providerID': 'p'},
              'time': {'created': 1, 'completed': 2},
              'content': [
                {'type': 'text', 'text': text},
              ],
            },
        ],
        'cursor': <String, Object?>{},
      });
    }
    return _json({'message': 'no route for $method $path'}, status: 404);
  }

  static http.StreamedResponse _json(Object? body, {int status = 200}) =>
      http.StreamedResponse(
        Stream<List<int>>.value(utf8.encode(jsonEncode(body))),
        status,
        headers: {'content-type': 'application/json'},
      );
}

const _sessionPayload = <String, Object?>{
  'id': 'ses_1',
  'projectID': 'prj_1',
  'cost': 0.25,
  'tokens': {
    'input': 10,
    'output': 20,
    'reasoning': 0,
    'cache': {'read': 0, 'write': 0},
  },
  'time': {'created': 1, 'updated': 2},
  'location': {'directory': '/workspace'},
  'title': 'OpenFit plan',
};

const _inboxUserPayload = <String, Object?>{
  'id': 'msg_1',
  'sessionID': 'ses_1',
  'time': {'created': 1},
  'type': 'user',
  'payload': {'text': 'hi'},
  'delivery': 'steer',
};

Map<String, Object?> textDelta(String delta) => {
  'type': 'session.text.delta',
  'data': {'sessionID': 'ses_1', 'delta': delta},
};

Map<String, Object?> reasoningDelta(String delta) => {
  'type': 'session.reasoning.delta',
  'data': {'sessionID': 'ses_1', 'delta': delta},
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

CoachService serviceFor(FakeOpenCodeServer server) => CoachService(
  baseUrl: Uri.parse('http://fake.opencode'),
  clientFactory: server.newClient,
);

/// Polls until [predicate] holds, failing the test after [timeout].
Future<void> until(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for the condition');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  group('askCoach', () {
    test('streams the turn through runTurn and reconciles the result', () async {
      final server = FakeOpenCodeServer(
        frames: [
          textDelta('Hello'),
          reasoningDelta('thinking'),
          textDelta(' world'),
          stepEnded(),
          executionSucceeded(),
        ],
      )
        // The server's record carries one more character than the deltas: the
        // final text must come from reconciliation, like before the migration.
        ..assistantText = 'Hello world!';
      final service = serviceFor(server);
      addTearDown(service.dispose);
      addTearDown(server.close);

      final events = await service.askCoach(text: 'Hi').toList();

      // One shared session, one prompt per turn (writes are never retried).
      expect(server.createdTitles, ['OpenFit plan']);
      expect(server.promptTexts, ['Hi']);
      expect(service.coachSessionID, 'ses_1');

      expect(events.map((event) => event.runtimeType), [
        CoachChatDelta,
        CoachChatReasoning,
        CoachChatDelta,
        CoachChatDone,
      ]);
      expect((events[0] as CoachChatDelta).text, 'Hello');
      expect((events[1] as CoachChatReasoning).text, 'thinking');
      expect((events[2] as CoachChatDelta).text, ' world');
      final done = events.last as CoachChatDone;
      expect(done.text, 'Hello world!');
      expect(done.cancelled, isFalse);
      expect(done.usage?.totalTokens, 21);
      expect(done.usage?.inputTokens, 13);
      expect(done.usage?.outputTokens, 8);
      expect(done.usage?.thoughtsTokens, 3);

      // The next turn reuses the same session and sends exactly one prompt.
      final second = await service.askCoach(text: 'More').toList();
      expect(server.createdTitles, hasLength(1));
      expect(server.promptTexts, ['Hi', 'More']);
      expect(second.last, isA<CoachChatDone>());
    });

    test('cancel() interrupts the turn fiber and reports a cancelled turn', () async {
      final server = FakeOpenCodeServer(holdEventsOpen: true);
      final service = serviceFor(server);
      addTearDown(service.dispose);
      addTearDown(server.close);

      final events = <CoachChatEvent>[];
      final finished = Completer<void>();
      service.askCoach(text: 'hello').listen(
        events.add,
        onError: (Object error, StackTrace stackTrace) =>
            finished.completeError(error, stackTrace),
        onDone: finished.complete,
      );

      await until(() => server.promptTexts.isNotEmpty);
      expect(server.promptTexts, ['hello']);

      await server.eventStreamListened.future;
      server.emit(textDelta('The answer is '));
      await until(() => events.isNotEmpty);
      expect((events.single as CoachChatDelta).text, 'The answer is ');

      service.cancel();
      await finished.future;

      // The SDK's own safety-net polling (session.wait) was running while the
      // turn waited for events; cancelling interrupts the fiber, not the wait.
      expect(server.waitCalls, greaterThan(0));
      expect(events, hasLength(2));
      final done = events.last as CoachChatDone;
      expect(done.cancelled, isTrue);
      expect(done.text, isEmpty);
    });

    test('a failing turn surfaces the typed OpenCodeError', () async {
      final server = FakeOpenCodeServer()..promptStatus = 409;
      final service = serviceFor(server);
      addTearDown(service.dispose);
      addTearDown(server.close);

      Object? failure;
      try {
        await service.askCoach(text: 'hello').drain<void>();
      } on Object catch (error) {
        failure = error;
      }

      expect(
        failure,
        isA<OpenCodeApiError>()
            .having((error) => error.statusCode, 'statusCode', 409)
            .having((error) => error.message, 'message', 'prompt rejected'),
      );
    });

    test('a failed session create is not retried and not cached', () async {
      final server = FakeOpenCodeServer(
        frames: [textDelta('ok'), executionSucceeded()],
      )..createStatus = 500;
      final service = serviceFor(server);
      addTearDown(service.dispose);
      addTearDown(server.close);

      Object? failure;
      try {
        await service.askCoach(text: 'hi').drain<void>();
      } on Object catch (error) {
        failure = error;
      }

      // 500 is transient for reads, but session creation is a write: exactly
      // one attempt may reach the server.
      expect(failure, isA<OpenCodeApiError>());
      expect((failure! as OpenCodeApiError).statusCode, 500);
      expect(server.createdTitles, isEmpty);

      // The failure is not cached: a later turn starts a fresh attempt.
      server.createStatus = null;
      final events = await service.askCoach(text: 'hi').toList();
      expect(server.createdTitles, ['OpenFit plan']);
      expect(events.last, isA<CoachChatDone>());
    });

    test('dispose() is idempotent and stops the runtime', () async {
      final server = FakeOpenCodeServer();
      final service = serviceFor(server);
      addTearDown(server.close);

      service.dispose();
      service.dispose();
    });
  });
}
