// Copyright 2026 The genkit_openai_custom authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';

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

  /// When not 200, every request fails with this status and [errorBody].
  int statusCode;
  String? errorBody;

  /// Byte size used to slice SSE payloads.
  final int chunkSize;

  final List<http.BaseRequest> requests = [];
  final List<Map<String, dynamic>> bodies = [];
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
    query[request.url.path] = request.url.queryParametersAll.entries
        .map((e) => '${e.key}=${e.value.join(',')}')
        .toList();
    final body = bodyBytes.isEmpty
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
