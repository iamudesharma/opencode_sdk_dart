// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A scripted OpenCode V2 server for tests.
///
/// Serves the model catalog, the stateless generate endpoint, session
/// lifecycle endpoints, and a live event stream, using the same envelopes the
/// real server produces.
final class FakeOpenCodeHost {
  FakeOpenCodeHost({
    this.sessionID = 'ses_fake1',
    this.models = const [
      {
        'id': 'kimi-k2.6',
        'modelID': 'kimi-k2.6',
        'providerID': 'opencode-go',
        'name': 'Kimi K2.6',
        'capabilities': {
          'tools': true,
          'input': ['text', 'image'],
          'output': ['text'],
        },
      },
      {
        'id': 'disabled-model',
        'modelID': 'disabled-model',
        'providerID': 'opencode-go',
        'name': 'Disabled Model',
        'enabled': false,
        'capabilities': {
          'tools': true,
          'input': ['text'],
          'output': ['text'],
        },
      },
    ],
    this.generateText = 'Hello from the OpenCode server!',
    this.eventFrames = const [],
  });

  final String sessionID;

  /// Partial model records; defaults are filled in.
  final List<Map<String, dynamic>> models;

  /// Text returned by the stateless generate endpoint.
  String generateText;

  /// Frames (raw JSON maps) written to the event stream after connecting.
  List<Map<String, dynamic>> eventFrames;

  /// When set, `GET .../message` reports this text as a completed assistant
  /// message (used by the polling/reconciliation fallback).
  String? assistantMessageText;

  /// When set, the same message also reports this reasoning text.
  String? assistantMessageReasoning;

  /// When false, the assistant message lacks `time.completed`, so the polling
  /// fallback keeps waiting.
  bool assistantMessageCompleted = true;

  /// Optional hook awaited before a request is handled.
  ///
  /// Tests use it to hold a response until they have set something up (for
  /// example cancelling the caller's token while the request is in flight).
  Future<void> Function(http.BaseRequest request)? hold;

  /// Optional failure injection: when it returns a status, the request answers
  /// that status with `{"error": {"message": [failMessage]}}`.
  int? Function(http.BaseRequest request)? failRequest;

  /// Message carried by an injected failure response.
  String failMessage = 'boom';

  final List<http.BaseRequest> requests = [];
  final List<Map<String, dynamic>> bodies = [];
  final List<String> removedSessions = [];

  http.Client get client => MockClient.streaming(_handle);

  Future<http.StreamedResponse> _handle(
    http.BaseRequest request,
    http.ByteStream bodyStream,
  ) async {
    final bodyBytes = await bodyStream.toBytes();
    requests.add(request);
    bodies.add(
      bodyBytes.isEmpty
          ? <String, dynamic>{}
          : (jsonDecode(utf8.decode(bodyBytes)) as Map).cast<String, dynamic>(),
    );
    final failure = failRequest?.call(request);
    if (failure != null) {
      return _json(failure, {
        'error': {'message': failMessage},
      });
    }
    await hold?.call(request);
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == '/api/model') {
      return _json(200, {
        'location': {'directory': '/tmp/project'},
        'data': [for (final model in models) _completeModel(model)],
      });
    }
    if (method == 'POST' && path == '/api/experimental/generate') {
      return _json(200, {
        'data': {'text': generateText},
      });
    }
    if (method == 'GET' && path == '/api/event') {
      final payload = StringBuffer();
      payload.write(
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
    if (method == 'POST' && path == '/api/session') {
      return _json(200, {
        'location': {'directory': '/tmp/project'},
        'data': {
          'id': sessionID,
          'projectID': 'proj_1',
          'cost': 0,
          'tokens': {
            'input': 0,
            'output': 0,
            'reasoning': 0,
            'cache': {'read': 0, 'write': 0},
          },
          'time': {'created': 1, 'updated': 2},
          'location': {'directory': '/tmp/project'},
          'title': 'genkit generate',
        },
      });
    }
    final promptMatch =
        RegExp(r'^/api/session/([^/]+)/prompt$').firstMatch(path);
    if (method == 'POST' && promptMatch != null) {
      final sid = promptMatch[1]!;
      return _json(200, {
        'data': {
          'id': 'msg_1',
          'sessionID': sid,
          'time': {'created': 1},
          'type': 'user',
          'payload': {'text': 'prompt'},
          'delivery': 'steer',
        },
      });
    }
    final deleteMatch = RegExp(r'^/api/session/([^/]+)$').firstMatch(path);
    if (method == 'DELETE' && deleteMatch != null) {
      removedSessions.add(deleteMatch[1]!);
      return http.StreamedResponse(const Stream<List<int>>.empty(), 204);
    }
    if (method == 'POST' &&
        RegExp(r'^/api/session/[^/]+/(model|agent)$').hasMatch(path)) {
      return http.StreamedResponse(const Stream<List<int>>.empty(), 204);
    }
    if (method == 'POST' &&
        RegExp(r'^/api/experimental/session/[^/]+/wait$').hasMatch(path)) {
      return http.StreamedResponse(const Stream<List<int>>.empty(), 204);
    }
    final messageMatch =
        RegExp(r'^/api/session/([^/]+)/message$').firstMatch(path);
    if (method == 'GET' && messageMatch != null) {
      final text = assistantMessageText;
      return _json(200, {
        'data': [
          if (text != null)
            {
              'id': 'msg_2',
              'type': 'assistant',
              'agent': 'build',
              'model': {'id': 'kimi-k2.6', 'providerID': 'opencode-go'},
              'time': {
                'created': 1,
                if (assistantMessageCompleted) 'completed': 2,
              },
              'content': [
                if (assistantMessageReasoning != null)
                  {
                    'type': 'reasoning',
                    'text': assistantMessageReasoning,
                  },
                if (text.isNotEmpty) {'type': 'text', 'text': text},
              ],
            },
        ],
        'cursor': <String, Object?>{},
      });
    }
    if (method == 'GET' && path == '/api/websearch/provider') {
      return _json(200, {
        'location': {'directory': '/tmp/project'},
        'data': [
          {'id': 'exa', 'name': 'Exa'},
        ],
      });
    }
    if (method == 'POST' && path == '/api/websearch') {
      return _json(200, {
        'location': {'directory': '/tmp/project'},
        'data': {
          'providerID': 'exa',
          'results': [
            {
              'url': 'https://example.com/dart',
              'title': 'Dart',
              'content': 'Dart is a language.',
              'time': <String, Object?>{},
            },
          ],
        },
      });
    }
    return _json(404, {
      'error': {'message': 'no route for $method $path'},
    });
  }

  static Map<String, dynamic> _completeModel(Map<String, dynamic> model) => {
    'id': model['id'],
    'modelID': model['modelID'] ?? model['id'],
    'providerID': model['providerID'] ?? 'opencode-go',
    'name': model['name'] ?? model['id'],
    'capabilities':
        model['capabilities'] ??
        {
          'tools': true,
          'input': ['text'],
          'output': ['text'],
        },
    'variants': model['variants'] ?? <Map<String, Object?>>[],
    'time': model['time'] ?? {'released': 1791849600000},
    'cost': model['cost'] ?? <Map<String, Object?>>[],
    'status': model['status'] ?? 'active',
    'enabled': model['enabled'] ?? true,
    'limit': model['limit'] ?? {'context': 262144, 'output': 32768},
  };

  http.StreamedResponse _json(int status, Object body) {
    final bytes = utf8.encode(jsonEncode(body));
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      status,
      headers: {'content-type': 'application/json'},
    );
  }

  /// A text delta event for [sessionID].
  static Map<String, dynamic> textDelta(String sessionID, String delta) => {
    'type': 'session.text.delta',
    'data': {
      'sessionID': sessionID,
      'assistantMessageID': 'msg_2',
      'ordinal': 0,
      'delta': delta,
    },
  };

  /// A reasoning delta event for [sessionID].
  static Map<String, dynamic> reasoningDelta(String sessionID, String delta) =>
      {
        'type': 'session.reasoning.delta',
        'data': {
          'sessionID': sessionID,
          'assistantMessageID': 'msg_2',
          'ordinal': 0,
          'delta': delta,
        },
      };

  /// A step-usage event for [sessionID].
  static Map<String, dynamic> stepEnded(String sessionID) => {
    'type': 'session.step.ended',
    'data': {
      'sessionID': sessionID,
      'assistantMessageID': 'msg_2',
      'tokens': {
        'input': 10,
        'output': 5,
        'reasoning': 3,
        'cache': {'read': 2, 'write': 1},
      },
      'cost': 0.01,
    },
  };

  /// A text-finished event carrying the full text for [sessionID].
  static Map<String, dynamic> textEnded(String sessionID, String text) => {
    'type': 'session.text.ended',
    'data': {
      'sessionID': sessionID,
      'assistantMessageID': 'msg_2',
      'ordinal': 0,
      'text': text,
    },
  };

  /// A reasoning-finished event carrying the full text for [sessionID].
  static Map<String, dynamic> reasoningEnded(String sessionID, String text) => {
    'type': 'session.reasoning.ended',
    'data': {
      'sessionID': sessionID,
      'assistantMessageID': 'msg_2',
      'ordinal': 0,
      'text': text,
    },
  };

  /// A successful execution event for [sessionID].
  static Map<String, dynamic> executionSucceeded(String sessionID) => {
    'type': 'session.execution.succeeded',
    'data': {'sessionID': sessionID},
  };
}
