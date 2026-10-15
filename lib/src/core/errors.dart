/// Exception hierarchy used across the SDK.
///
/// Every structured error returned by the OpenCode server is decoded into a
/// concrete [OpenCodeApiException] subclass by the generated
/// `decodeOpenCodeException` function. Transport-level and decoding failures
/// use the dedicated exception types in this library.
library;

import 'json_utils.dart';

/// Base class for structured errors from the OpenCode HTTP API.
///
/// Concrete subclasses are generated from the OpenAPI contract (for example
/// `SessionNotFoundException` or `UnauthorizedException`) and expose their
/// schema fields as properties. Every instance carries the wire discriminator
/// in [tag], the human readable [message], and the raw JSON body in [raw].
abstract class OpenCodeApiException implements Exception {
  OpenCodeApiException({required this.tag, required this.message, this.raw});

  /// The stable wire discriminator, for example `SessionNotFoundError`.
  final String tag;

  /// Human readable message provided by the server.
  final String message;

  /// The decoded JSON body as returned by the server, when available.
  final JsonMap? raw;

  int? _statusCode;

  /// The HTTP status code of the response that produced this error.
  int? get statusCode => _statusCode;

  /// Attaches the HTTP status code. Called by the transport when decoding.
  void attachStatusCode(int value) => _statusCode = value;

  @override
  String toString() => '$runtimeType($tag): $message';
}

/// A non-declared HTTP status code or an error body that could not be decoded
/// into a structured exception.
final class OpenCodeStatusException extends OpenCodeApiException {
  OpenCodeStatusException({
    required int statusCode,
    required super.message,
    super.raw,
  })  : _httpStatus = statusCode,
        super(tag: 'UnexpectedStatus');

  final int _httpStatus;

  /// The HTTP status code returned by the server.
  int get httpStatus => _httpStatus;

  @override
  String toString() => 'OpenCodeStatusException($_httpStatus): $message';
}

/// Thrown when the underlying transfer fails (DNS, socket, TLS, aborted
/// connection, ...).
final class OpenCodeTransportException implements Exception {
  OpenCodeTransportException(this.cause);

  /// The original error thrown by the HTTP stack.
  final Object cause;

  @override
  String toString() => 'OpenCodeTransportException: $cause';
}

/// Thrown when a response body is missing, truncated, or not valid JSON.
final class OpenCodeMalformedResponseException implements Exception {
  OpenCodeMalformedResponseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'OpenCodeMalformedResponseException: $message';
}

/// Thrown when a value does not match the shape declared by the contract.
final class OpenCodeDecodeException implements Exception {
  OpenCodeDecodeException(this.message, {this.path});

  final String message;

  /// Dotted path of the value inside the payload, when known.
  final String? path;

  @override
  String toString() {
    final at = path == null ? '' : ' at $path';
    return 'OpenCodeDecodeException: $message$at';
  }
}

/// Thrown when a request is cancelled through a `CancellationToken`.
final class OpenCodeCancelledException implements Exception {
  OpenCodeCancelledException([this.message = 'The request was cancelled']);

  final String message;

  @override
  String toString() => 'OpenCodeCancelledException: $message';
}

/// Thrown when an event stream fails: oversized SSE frames, exceeded
/// subscriber capacity, or an unsupported content type.
final class OpenCodeStreamException implements Exception {
  OpenCodeStreamException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'OpenCodeStreamException: $message';
}
