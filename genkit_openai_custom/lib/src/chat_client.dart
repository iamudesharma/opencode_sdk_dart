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

import 'package:genkit/plugin.dart';
import 'package:http/http.dart' as http;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;

import 'errors.dart';

/// A minimal Chat Completions client.
///
/// The streaming side reuses [sdk.decodeSseFrames] from `opencode_sdk_dart`
/// for SSE framing, so OpenAI-compatible and OpenCode transports share one
/// parser. Cancellation follows the same pattern as the SDK transport: a
/// cancelled request gets a dedicated `http.Client` that is closed to tear the
/// connection down immediately.
final class OpenAIChatClient {
  OpenAIChatClient({
    required this.baseUrl,
    Map<String, String> Function()? headers,
    http.Client? httpClient,
    http.Client Function()? clientFactory,
  }) : headers = headers ?? (() => const <String, String>{}),
       client = httpClient ?? http.Client(),
       owned = httpClient == null,
       clientFactory = clientFactory ?? http.Client.new;

  /// The normalized base URL (everything up to and including `/v1/`).
  final Uri baseUrl;

  /// Supplies headers for every request.
  final Map<String, String> Function() headers;

  /// The shared client used when a request is not cancellable.
  final http.Client client;

  /// Whether [client] is owned by this instance (and must be closed).
  final bool owned;

  /// Creates dedicated clients for cancellable requests.
  final http.Client Function() clientFactory;

  Uri get _endpoint => baseUrl.resolve('chat/completions');

  /// Whether [baseUrl] already ends in `/chat/completions`.
  static Uri normalizeBaseUrl(String baseUrl) {
    var normalized = baseUrl.trim();
    if (normalized.endsWith('/chat/completions')) {
      normalized = normalized.substring(
        0,
        normalized.length - '/chat/completions'.length,
      );
    }
    if (!normalized.endsWith('/')) {
      normalized = '$normalized/';
    }
    return Uri.parse(normalized);
  }

  /// Sends a unary chat completion request and returns the decoded JSON body.
  Future<Map<String, dynamic>> createChatCompletion(
    Map<String, dynamic> body, {
    CancellationToken? cancel,
  }) async {
    cancel?.throwIfCancelled();
    final dedicated = cancel != null;
    final client = dedicated ? clientFactory() : this.client;
    final dispose = cancel?.onCancel(() {
      if (dedicated) client.close();
    });
    try {
      final request = http.Request('POST', _endpoint)
        ..headers.addAll(headers())
        ..headers['content-type'] = 'application/json'
        ..headers['accept'] = 'application/json'
        ..body = jsonEncode(body);
      final response = await client.send(request);
      final text = await response.stream.bytesToString();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw chatCompletionError(
          url: _endpoint,
          statusCode: response.statusCode,
          body: text,
        );
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw GenkitException(
          'Chat completion response was not a JSON object.',
          status: StatusCode.internal,
        );
      }
      return decoded;
    } on GenkitException {
      rethrow;
    } catch (error, stackTrace) {
      throw chatTransportError(error, url: _endpoint, stackTrace: stackTrace);
    } finally {
      dispose?.call();
    }
  }

  /// Sends a streaming chat completion request and emits every decoded frame.
  ///
  /// The caller is expected to cancel its subscription to stop reading; when
  /// [cancel] is provided the request is torn down eagerly.
  Stream<Map<String, dynamic>> streamChatCompletion(
    Map<String, dynamic> body, {
    CancellationToken? cancel,
    void Function()? onActivity,
  }) {
    if (cancel?.isCancelled ?? false) {
      return Stream<Map<String, dynamic>>.error(
        GenkitException(
          'Chat completion request was cancelled.',
          status: StatusCode.cancelled,
        ),
      );
    }
    final dedicated = cancel != null;
    final client = dedicated ? clientFactory() : this.client;
    final controller = StreamController<Map<String, dynamic>>();
    StreamSubscription<Map<String, dynamic>>? frames;
    var closed = false;

    void finish([Object? error, StackTrace? stackTrace]) {
      if (closed) return;
      closed = true;
      if (error != null) {
        controller.addError(error, stackTrace ?? StackTrace.current);
      }
      controller.close();
      if (dedicated) client.close();
    }

    final dispose = cancel?.onCancel(() {
      if (dedicated) client.close();
      finish(
        GenkitException(
          'Chat completion request was cancelled.',
          status: StatusCode.cancelled,
        ),
      );
    });

    Future<void> start() async {
      try {
        final request = http.Request('POST', _endpoint)
          ..headers.addAll(headers())
          ..headers['content-type'] = 'application/json'
          ..headers['accept'] = 'text/event-stream'
          ..body = jsonEncode(body);
        final response = await client.send(request);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          final text = await response.stream.bytesToString();
          throw chatCompletionError(
            url: _endpoint,
            statusCode: response.statusCode,
            body: text,
          );
        }
        frames = _openAiSseFrames(response.stream, onActivity: onActivity)
            .listen(
              controller.add,
              onError: (Object error, StackTrace stackTrace) {
                if (error is GenkitException) {
                  finish(error, stackTrace);
                } else {
                  finish(
                    chatTransportError(
                      error,
                      url: _endpoint,
                      stackTrace: stackTrace,
                    ),
                    stackTrace,
                  );
                }
              },
              onDone: finish,
            );
      } catch (error, stackTrace) {
        finish(
          error is GenkitException
              ? error
              : chatTransportError(
                  error,
                  url: _endpoint,
                  stackTrace: stackTrace,
                ),
          stackTrace,
        );
      }
    }

    controller.onListen = start;
    controller.onCancel = () {
      closed = true;
      dispose?.call();
      unawaited(frames?.cancel());
      if (dedicated) client.close();
    };
    return controller.stream;
  }

  /// Closes the underlying HTTP client.
  void close() {
    if (owned) client.close();
  }

  /// Lists model ids from `GET /models`.
  Future<List<String>> listModels() async {
    final uri = baseUrl.resolve('models');
    final response = await client.get(uri, headers: headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw chatCompletionError(
        url: uri,
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return const [];
    final data = decoded['data'];
    if (data is! List) return const [];
    return [
      for (final entry in data)
        if (entry is Map && entry['id'] is String) entry['id'] as String,
    ];
  }

  /// Decodes OpenAI's SSE dialect on top of [sdk.decodeSseFrames].
  ///
  /// OpenAI terminates the stream with a literal `data: [DONE]` frame, which
  /// is not JSON; the shared decoder reports it as a malformed frame and this
  /// wrapper converts that specific case into a normal end of stream.
  Stream<Map<String, dynamic>> _openAiSseFrames(
    Stream<List<int>> bytes, {
    void Function()? onActivity,
  }) {
    final controller = StreamController<Map<String, dynamic>>();
    StreamSubscription<Object?>? subscription;
    var closed = false;

    void complete() {
      if (closed) return;
      closed = true;
      controller.close();
    }

    subscription = sdk
        .decodeSseFrames(bytes, onActivity: onActivity)
        .listen(
          (frame) {
            if (closed) return;
            if (frame is Map) {
              controller.add(frame.cast<String, dynamic>());
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (_isDoneSentinel(error)) {
              complete();
              return;
            }
            if (closed) return;
            closed = true;
            controller.addError(
              error is sdk.OpenCodeMalformedResponseException
                  ? GenkitException(
                      error.message,
                      status: StatusCode.internal,
                      cause: error,
                    )
                  : error,
              stackTrace,
            );
            controller.close();
          },
          onDone: complete,
        );
    controller.onCancel = () => unawaited(subscription?.cancel());
    return controller.stream;
  }

  static bool _isDoneSentinel(Object error) {
    if (error is! sdk.OpenCodeMalformedResponseException) return false;
    final cause = error.cause;
    if (cause is FormatException && cause.source == '[DONE]') return true;
    return cause?.toString().contains('[DONE]') ?? false;
  }
}
