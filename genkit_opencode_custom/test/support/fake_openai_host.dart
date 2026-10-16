// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A scripted OpenAI-compatible host for tests.
///
/// Records every request (and decoded JSON body) and replies from canned
/// fixtures. Streaming replies are emitted as SSE frames split into small
/// chunks so the parser is exercised across chunk boundaries.
final class FakeOpenAIHost {
  FakeOpenAIHost({
    this.unaryResponse,
    this.streamFrames,
    this.models = const ['gpt-4o', 'gpt-4o-mini'],
    this.statusCode = 200,
    this.errorBody,
    this.chunkSize = 7,
  });

  /// Body returned for unary chat completion requests.
  Map<String, dynamic>? unaryResponse;

  /// Frames (as JSON maps) streamed for `stream: true` requests.
  List<Map<String, dynamic>>? streamFrames;

  /// Model ids returned by `GET /models`.
  List<String> models;

  /// Text returned by the audio transcription/translation endpoints.
  String transcriptText = 'hello from audio';

  /// When not 200, every request fails with this status and [errorBody].
  int statusCode;
  String? errorBody;

  /// Byte size used to slice SSE payloads.
  final int chunkSize;

  final List<http.BaseRequest> requests = [];
  final List<Map<String, dynamic>> bodies = [];

  /// The raw request payloads, for multipart requests that do not decode as
  /// JSON.
  final List<Uint8List> rawBodies = [];

  final Map<String, List<String>> query = {};

  http.Client get client => MockClient.streaming(_handle);

  int get chatRequests =>
      requests.where((r) => r.url.path.endsWith('/chat/completions')).length;

  Map<String, dynamic> get lastBody => bodies.last;

  Future<http.StreamedResponse> _handle(
    http.BaseRequest request,
    http.ByteStream bodyStream,
  ) async {
    final bodyBytes = await bodyStream.toBytes();
    requests.add(request);
    rawBodies.add(bodyBytes);
    query[request.url.path] = request.url.queryParametersAll.entries
        .map((e) => '${e.key}=${e.value.join(',')}')
        .toList();
    final isJson = (request.headers['content-type'] ?? '').contains(
      'application/json',
    );
    final body = (bodyBytes.isEmpty || !isJson)
        ? <String, dynamic>{}
        : (jsonDecode(utf8.decode(bodyBytes)) as Map).cast<String, dynamic>();
    bodies.add(body);

    if (statusCode != 200) {
      return _json(statusCode, errorBody ?? '{"error": {"message": "boom"}}');
    }

    final path = request.url.path;
    if (path.endsWith('/models')) {
      return _json(
        200,
        jsonEncode({
          'object': 'list',
          'data': [
            for (final id in models) {'id': id, 'object': 'model'},
          ],
        }),
      );
    }
    if (path.endsWith('/chat/completions')) {
      if (body['stream'] == true) {
        return _sse(streamFrames ?? _defaultStreamFrames);
      }
      return _json(200, jsonEncode(unaryResponse ?? _defaultUnaryResponse));
    }
    if (path.endsWith('/embeddings')) {
      final input = body['input'];
      final count = input is List ? input.length : 0;
      return _json(
        200,
        jsonEncode({
          'object': 'list',
          'model': body['model'] ?? 'text-embedding-3-small',
          'data': [
            for (var i = 0; i < count; i++)
              {
                'object': 'embedding',
                'index': i,
                'embedding': [0.1 * (i + 1), 0.2, 0.3],
              },
          ],
          'usage': {'prompt_tokens': count, 'total_tokens': count},
        }),
      );
    }
    if (path.endsWith('/audio/speech')) {
      return http.StreamedResponse(
        Stream<List<int>>.value(const [1, 2, 3, 4]),
        200,
        headers: {'content-type': 'audio/mpeg'},
      );
    }
    if (path.endsWith('/audio/transcriptions') ||
        path.endsWith('/audio/translations')) {
      return _json(200, jsonEncode({'text': transcriptText}));
    }
    return _json(404, '{"error": {"message": "no route for $path"}}');
  }

  http.StreamedResponse _json(int status, String body) {
    final bytes = utf8.encode(body);
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      status,
      headers: {'content-type': 'application/json'},
    );
  }

  http.StreamedResponse _sse(List<Map<String, dynamic>> frames) {
    final payload = StringBuffer();
    for (final frame in frames) {
      payload.write('data: ${jsonEncode(frame)}\n\n');
    }
    payload.write('data: [DONE]\n\n');
    final units = utf8.encode(payload.toString());
    final chunks = <List<int>>[];
    for (var i = 0; i < units.length; i += chunkSize) {
      chunks.add(units.sublist(i, (i + chunkSize).clamp(0, units.length)));
    }
    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(chunks),
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  }

  static Map<String, dynamic> get _defaultUnaryResponse => {
    'id': 'chatcmpl-test',
    'object': 'chat.completion',
    'model': 'gpt-4o',
    'choices': [
      {
        'index': 0,
        'message': {
          'role': 'assistant',
          'content': 'Hello from the fake host!',
        },
        'finish_reason': 'stop',
      },
    ],
    'usage': {
      'prompt_tokens': 5,
      'completion_tokens': 6,
      'total_tokens': 11,
      'prompt_tokens_details': {'cached_tokens': 2},
      'completion_tokens_details': {'reasoning_tokens': 3},
    },
  };

  static List<Map<String, dynamic>> get _defaultStreamFrames => [
    {
      'choices': [
        {
          'index': 0,
          'delta': {'role': 'assistant', 'content': 'Hello'},
          'finish_reason': null,
        },
      ],
    },
    {
      'choices': [
        {
          'index': 0,
          'delta': {'content': ' from'},
          'finish_reason': null,
        },
      ],
    },
    {
      'choices': [
        {
          'index': 0,
          'delta': {'content': ' streaming!'},
          'finish_reason': 'stop',
        },
      ],
    },
    {
      'choices': <Map<String, dynamic>>[],
      'usage': {'prompt_tokens': 3, 'completion_tokens': 4, 'total_tokens': 7},
    },
  ];
}
