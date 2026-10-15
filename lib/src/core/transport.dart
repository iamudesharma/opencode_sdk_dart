/// HTTP transport for the OpenCode API.
///
/// The transport mirrors the reference `@opencode/client` behavior:
///
/// * base URLs are normalized with a trailing slash and relative operation
///   paths resolve against them;
/// * query parameters use the same nested encoding (`key[child]=value`) with
///   repeated keys for lists;
/// * success responses must carry the declared status code, otherwise the
///   body is decoded as a structured error;
/// * event streams require `text/event-stream` and parse SSE frames;
/// * cancellation aborts the underlying connection.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'errors.dart';
import 'json_utils.dart';
import 'request_options.dart';
import 'sse.dart';

/// Decodes structured API errors. The generated client installs an
/// implementation that maps `_tag` discriminators to generated exception
/// classes.
typedef ApiExceptionDecoder = OpenCodeApiException? Function(
  int statusCode,
  Object? body,
);

/// Talks to one OpenCode server.
final class OpenCodeTransport {
  /// Creates a transport for [baseUrl].
  ///
  /// [headers] are sent with every request. [httpClient] reuses an existing
  /// client; when omitted, requests use a lazily created client from
  /// [clientFactory] (defaults to `http.Client.new`). Requests carrying a
  /// `CancellationToken` use a dedicated client so they can be aborted without
  /// affecting other requests.
  OpenCodeTransport({
    required Uri baseUrl,
    Map<String, String>? headers,
    http.Client? httpClient,
    http.Client Function()? clientFactory,
    this.sseByteLimit = 16 * 1024 * 1024,
  })  : _baseUrl = _normalizeBaseUrl(baseUrl),
        _defaultHeaders = Map<String, String>.unmodifiable(
            headers ?? const <String, String>{}),
        _client = httpClient,
        _clientFactory = clientFactory ?? http.Client.new;

  final Uri _baseUrl;
  final Map<String, String> _defaultHeaders;
  final http.Client Function() _clientFactory;
  final int sseByteLimit;

  http.Client? _client;

  /// Maps error response bodies to structured exceptions. Installed by the
  /// generated client; when unset, errors decode to [OpenCodeStatusException].
  ApiExceptionDecoder? exceptionDecoder;

  /// The normalized base URL of the server.
  Uri get baseUrl => _baseUrl;

  /// The default headers sent with every request.
  Map<String, String> get defaultHeaders => _defaultHeaders;

  http.Client get _sharedClient => _client ??= _clientFactory();

  /// Resolves an operation [path] and [query] against the base URL using the
  /// same encoding rules as the reference client.
  Uri resolve(String path, [JsonMap? query]) {
    var relative = path;
    while (relative.startsWith('/')) {
      relative = relative.substring(1);
    }
    final base = _baseUrl.resolve(relative);
    if (query == null || query.isEmpty) return base;
    final entries = <MapEntry<String, String>>[];
    for (final entry in query.entries) {
      _appendQuery(entries, entry.key, entry.value);
    }
    if (entries.isEmpty) return base;
    final queryString = entries
        .map((entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
        .join('&');
    final text = base.toString();
    return Uri.parse('$text?$queryString');
  }

  /// Performs a request whose success response carries a JSON body.
  ///
  /// Returns the decoded JSON when [empty] is false, otherwise `null`.
  Future<Object?> jsonRequest({
    required String method,
    required String path,
    JsonMap? query,
    Map<String, String>? headers,
    Object? body,
    bool binaryBody = false,
    int successStatus = 200,
    bool empty = false,
    RequestOptions? options,
  }) async {
    final token = options?.cancelToken;
    final dedicated = token != null;
    final client = dedicated ? _clientFactory() : _sharedClient;
    void onCancel() => client.close();
    if (token?.isCancelled ?? false) throw OpenCodeCancelledException();
    token?.addListener(onCancel);
    try {
      final response = await _send(
        method: method,
        path: path,
        query: query,
        headers: headers,
        body: body,
        binaryBody: binaryBody,
        options: options,
        client: client,
      );
      if (token?.isCancelled ?? false) throw OpenCodeCancelledException();
      if (response.statusCode != successStatus) {
        throw await _errorFrom(response);
      }
      if (empty) {
        await response.stream.drain<void>();
        return null;
      }
      final text = await response.stream.bytesToString();
      if (text.isEmpty) {
        throw OpenCodeMalformedResponseException('The response body was empty');
      }
      try {
        return jsonDecode(text);
      } on FormatException catch (error) {
        throw OpenCodeMalformedResponseException(
          'The response body is not valid JSON',
          cause: error,
        );
      }
    } on OpenCodeApiException {
      rethrow;
    } on OpenCodeMalformedResponseException {
      rethrow;
    } on OpenCodeTransportException {
      rethrow;
    } on Object catch (error) {
      if (token?.isCancelled ?? false) throw OpenCodeCancelledException();
      throw OpenCodeTransportException(error);
    } finally {
      token?.removeListener(onCancel);
      if (dedicated) client.close();
    }
  }

  /// Performs a request whose success response carries raw bytes.
  Future<Uint8List> bytesRequest({
    required String method,
    required String path,
    JsonMap? query,
    Map<String, String>? headers,
    Object? body,
    int successStatus = 200,
    RequestOptions? options,
  }) async {
    final token = options?.cancelToken;
    final dedicated = token != null;
    final client = dedicated ? _clientFactory() : _sharedClient;
    void onCancel() => client.close();
    if (token?.isCancelled ?? false) throw OpenCodeCancelledException();
    token?.addListener(onCancel);
    try {
      final response = await _send(
        method: method,
        path: path,
        query: query,
        headers: headers,
        body: body,
        options: options,
        client: client,
      );
      if (token?.isCancelled ?? false) throw OpenCodeCancelledException();
      if (response.statusCode != successStatus) {
        throw await _errorFrom(response);
      }
      return await response.stream.toBytes();
    } on OpenCodeApiException {
      rethrow;
    } on OpenCodeTransportException {
      rethrow;
    } on Object catch (error) {
      if (token?.isCancelled ?? false) throw OpenCodeCancelledException();
      throw OpenCodeTransportException(error);
    } finally {
      token?.removeListener(onCancel);
      if (dedicated) client.close();
    }
  }

  /// Opens a `text/event-stream` endpoint and yields decoded JSON frames.
  ///
  /// The returned stream is controller-based: cancelling a subscription
  /// completes immediately, aborts the underlying request, and releases a
  /// dedicated client when one was created for cancellation.
  Stream<Object?> sseFrames({
    required String path,
    JsonMap? query,
    Map<String, String>? headers,
    int successStatus = 200,
    RequestOptions? options,
    void Function()? onActivity,
  }) {
    final token = options?.cancelToken;
    if (token?.isCancelled ?? false) {
      return Stream<Object?>.error(OpenCodeCancelledException());
    }
    final dedicated = token != null;
    final client = dedicated ? _clientFactory() : _sharedClient;
    void onCancelToken() => client.close();
    token?.addListener(onCancelToken);

    final controller = StreamController<Object?>();
    StreamSubscription<Object?>? inner;
    var cancelled = false;

    void cleanup() {
      token?.removeListener(onCancelToken);
      if (dedicated) client.close();
    }

    void fail(Object error, StackTrace stackTrace) {
      if (cancelled || controller.isClosed) return;
      cancelled = true;
      controller.addError(error, stackTrace);
      unawaited(controller.close());
      cleanup();
    }

    Future<void> run() async {
      try {
        final response = await _send(
          method: 'GET',
          path: path,
          query: query,
          headers: headers,
          options: options,
          client: client,
        );
        if (token?.isCancelled ?? false) {
          throw OpenCodeCancelledException();
        }
        if (response.statusCode != successStatus) {
          throw await _errorFrom(response);
        }
        final contentType = response.headers['content-type'];
        final normalized = contentType?.split(';').first.trim().toLowerCase();
        if (normalized != 'text/event-stream') {
          try {
            await response.stream.drain<void>();
          } on Object {
            // The connection is being torn down anyway.
          }
          throw OpenCodeMalformedResponseException(
            'Expected text/event-stream but received '
            '${contentType ?? 'no content type'}',
          );
        }
        if (cancelled) return;
        inner = decodeSseFrames(
          response.stream,
          byteLimit: sseByteLimit,
          onActivity: onActivity,
        ).listen(
          (frame) {
            if (!cancelled && !controller.isClosed) controller.add(frame);
          },
          onError: fail,
          onDone: () {
            if (cancelled || controller.isClosed) return;
            unawaited(controller.close());
            cleanup();
          },
          cancelOnError: true,
        );
      } on OpenCodeApiException catch (error, stackTrace) {
        fail(error, stackTrace);
      } on OpenCodeMalformedResponseException catch (error, stackTrace) {
        fail(error, stackTrace);
      } on OpenCodeStreamException catch (error, stackTrace) {
        fail(error, stackTrace);
      } on Object catch (error, stackTrace) {
        if (token?.isCancelled ?? false) {
          fail(OpenCodeCancelledException(), stackTrace);
        } else {
          fail(OpenCodeTransportException(error), stackTrace);
        }
      }
    }

    controller.onListen = () {
      unawaited(run());
    };
    controller.onCancel = () {
      cancelled = true;
      unawaited(inner?.cancel());
      cleanup();
    };
    return controller.stream;
  }

  /// Closes the shared HTTP client. The transport cannot be used afterwards.
  void close() {
    _client?.close();
    _client = null;
  }

  Future<http.StreamedResponse> _send({
    required String method,
    required String path,
    required http.Client client,
    JsonMap? query,
    Map<String, String>? headers,
    Object? body,
    bool binaryBody = false,
    RequestOptions? options,
  }) async {
    final request = http.Request(method, resolve(path, query));
    request.headers.addAll(_defaultHeaders);
    if (headers != null) request.headers.addAll(headers);
    final optionHeaders = options?.headers;
    if (optionHeaders != null) request.headers.addAll(optionHeaders);
    if (body != null) {
      if (binaryBody) {
        request.bodyBytes = (body as List<int>);
        request.headers.putIfAbsent(
          'content-type',
          () => 'application/octet-stream',
        );
      } else {
        request.headers.putIfAbsent(
          'content-type',
          () => 'application/json; charset=utf-8',
        );
        request.bodyBytes = utf8.encode(jsonEncode(body));
      }
    }
    try {
      return await client.send(request);
    } on Object catch (error) {
      if (options?.cancelToken?.isCancelled ?? false) {
        throw OpenCodeCancelledException();
      }
      if (error is OpenCodeApiException ||
          error is OpenCodeMalformedResponseException ||
          error is OpenCodeStreamException) {
        rethrow;
      }
      throw OpenCodeTransportException(error);
    }
  }

  Future<OpenCodeApiException> _errorFrom(
    http.StreamedResponse response,
  ) async {
    final status = response.statusCode;
    final contentType = response.headers['content-type'];
    Object? body;
    final isJson = contentType != null &&
        (contentType.split(';').first.trim().toLowerCase() ==
                'application/json' ||
            contentType.contains('+json'));
    if (isJson) {
      try {
        final text = await response.stream.bytesToString();
        if (text.isNotEmpty) {
          body = jsonDecode(text);
        }
      } on Object {
        body = null;
      }
    } else {
      try {
        await response.stream.drain<void>();
      } on Object {
        // Ignore teardown errors while discarding the body.
      }
    }
    final decoded = exceptionDecoder?.call(status, body);
    if (decoded != null) {
      decoded.attachStatusCode(status);
      return decoded;
    }
    var message = 'Unexpected status $status';
    if (body is Map && body['message'] is String) {
      message = body['message'] as String;
    }
    final exception = OpenCodeStatusException(
      statusCode: status,
      message: message,
      raw: body is Map ? asJsonMap(body) : null,
    )..attachStatusCode(status);
    return exception;
  }

  static Uri _normalizeBaseUrl(Uri url) {
    var path = url.path;
    if (!path.endsWith('/')) path = '$path/';
    return url.replace(path: path);
  }

  static void _appendQuery(
    List<MapEntry<String, String>> out,
    String key,
    Object? value,
  ) {
    if (value == null) return;
    if (value is Iterable && value is! String) {
      for (final item in value) {
        _appendQuery(out, key, item);
      }
      return;
    }
    if (value is Map) {
      for (final entry in value.entries) {
        _appendQuery(out, '$key[${entry.key}]', entry.value);
      }
      return;
    }
    out.add(MapEntry<String, String>(key, value.toString()));
  }
}
