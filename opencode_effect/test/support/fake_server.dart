/// Shared fakes for the bridge test suite.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// An SSE or JSON response body.
http.StreamedResponse jsonStream(Object? body, {int status = 200}) {
  final bytes = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream<List<int>>.value(bytes),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// An HTTP client that records [close] calls.
final class TrackingClient extends http.BaseClient {
  TrackingClient(this._inner);

  final http.Client _inner;

  /// Whether [close] was called.
  bool closed = false;

  /// Requests sent through this client.
  int requests = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests++;
    return _inner.send(request);
  }

  @override
  void close() {
    closed = true;
    _inner.close();
  }
}

/// A scripted OpenCode server over `MockClient.streaming`.
final class FakeOpenCodeServer {
  FakeOpenCodeServer();

  /// Frames written to the shared event stream after `server.connected`.
  final List<Map<String, Object?>> eventFrames = [];

  /// Completed assistant text reported by `GET .../message`.
  String? assistantText;

  /// Whether assistant messages report `time.completed`.
  bool assistantCompleted = true;

  /// When true, prompts fail with 409.
  bool failPrompt = false;

  int promptCalls = 0;
  int infoCalls = 0;
  int sessionGetCalls = 0;

  /// Fails the first [failures] `server.info` calls with `status`.
  int infoFailures = 0;
  int infoFailureStatus = 500;

  /// When set, `GET .../message` blocks until this completes.
  Completer<void>? blockMessages;

  /// A fresh `MockClient`; pass the same instance to `httpClient` and
  /// `clientFactory` so cancellation paths stay scripted.
  http.Client get client => MockClient.streaming(_handle);

  Future<http.StreamedResponse> _handle(
    http.BaseRequest request,
    http.ByteStream bodyStream,
  ) async {
    await bodyStream.toBytes();
    final path = request.url.path;

    if (request.method == 'GET' && path == '/api/event') {
      final payload = StringBuffer()
        ..write(
          'data: ${jsonEncode({'type': 'server.connected', 'data': <String, Object?>{}})}\n\n',
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
    if (request.method == 'GET' && path == '/api/info') {
      infoCalls++;
      if (infoFailures > 0) {
        infoFailures--;
        return jsonStream({
          'error': {'message': 'later'},
        }, status: infoFailureStatus);
      }
      return jsonStream({
        'version': '1.2.3',
        'pid': 42,
        'urls': ['http://fake.opencode'],
        'paths': {'tmp': '/tmp'},
      });
    }
    if (request.method == 'GET' && path == '/api/session/ses_1') {
      sessionGetCalls++;
      return jsonStream({
        '_tag': 'SessionNotFoundError',
        'message': 'gone',
        'sessionID': 'ses_1',
      }, status: 404);
    }
    if (request.method == 'POST' && path == '/api/session/ses_1/prompt') {
      promptCalls++;
      if (failPrompt) {
        return jsonStream({
          'error': {'message': 'busy'},
        }, status: 409);
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
    if (request.method == 'POST' &&
        path == '/api/experimental/session/ses_1/wait') {
      return http.StreamedResponse(const Stream<List<int>>.empty(), 204);
    }
    if (request.method == 'POST' && path == '/api/rpc/acme/search') {
      return jsonStream({
        'output': {'text': 'hello'},
      });
    }
    if (request.method == 'GET' && path == '/api/session/ses_1/message') {
      final blocked = blockMessages;
      if (blocked != null) await blocked.future;
      final text = assistantText;
      return jsonStream({
        'data': [
          if (text != null)
            {
              'id': 'msg_2',
              'type': 'assistant',
              'agent': 'build',
              'model': {'id': 'm', 'providerID': 'p'},
              'time': {'created': 1, if (assistantCompleted) 'completed': 2},
              'content': [
                if (text.isNotEmpty) {'type': 'text', 'text': text},
              ],
            },
        ],
        'cursor': <String, Object?>{},
      });
    }
    return jsonStream({
      'error': {'message': 'no route for ${request.method} $path'},
    }, status: 404);
  }
}

/// A text-delta event for `ses_1`.
Map<String, Object?> textDelta(String delta) => {
  'type': 'session.text.delta',
  'data': {'sessionID': 'ses_1', 'delta': delta},
};

/// A `session.execution.succeeded` event for `ses_1`.
Map<String, Object?> executionSucceeded() => {
  'type': 'session.execution.succeeded',
  'data': {'sessionID': 'ses_1'},
};

/// Builds an SDK client whose HTTP paths are scripted by [server].
OpenCodeClient sdkClientFor(FakeOpenCodeServer server) => OpenCodeClient(
  baseUrl: Uri.parse('http://fake.opencode'),
  httpClient: server.client,
  clientFactory: () => server.client,
);
