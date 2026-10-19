/// The shared sealed expected-error family for every OpenCode effect.
///
/// `OpenCodeError` is deliberately a single sealed hierarchy: composing
/// effects from different layers keeps one exhaustive error channel, so
/// `catchAll`, `retry(whileError: ...)` and UI error switches stay total.
///
/// Mapping rules:
///
/// * structured API errors become [OpenCodeApiError] carrying the original
///   `OpenCodeApiException` (tag, status code, raw body);
/// * transport, decode, malformed-payload, stream and local-service failures
///   become their dedicated variants;
/// * anything the SDK did not type (bugs, programming errors, foreign
///   exceptions) stays a *defect* — it is never silently converted into an
///   expected error.
library;

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// The sealed expected-error family of all `opencode_effect` effects.
sealed class OpenCodeError implements Exception {
  const OpenCodeError();

  /// A human readable summary of the failure.
  String get message;
}

/// A structured error returned by the OpenCode HTTP API.
///
/// Every `_tag`-decoded error (`SessionNotFoundError`, `UnauthorizedError`,
/// `RpcError`, ...) is preserved in [cause] with its status code and raw
/// payload, so existing `on SessionNotFoundError` handling keeps working.
final class OpenCodeApiError extends OpenCodeError {
  /// Wraps the decoded API exception.
  const OpenCodeApiError(this.cause);

  /// The original decoded exception thrown by the SDK.
  final OpenCodeApiException cause;

  /// The wire discriminator, for example `SessionNotFoundError`.
  String get tag => cause.tag;

  /// The HTTP status code of the response, when known.
  int? get statusCode => cause.statusCode;

  /// The decoded JSON body, when available.
  JsonMap? get raw => cause.raw;

  /// Whether the server answered `404`.
  bool get isNotFound => statusCode == 404;

  /// Whether the server answered `401` or `403`.
  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  /// Whether the server answered `429`: the caller is being throttled.
  bool get isThrottled => statusCode == 429;

  @override
  String get message => cause.message;

  @override
  String toString() =>
      'OpenCodeApiError($tag, status: $statusCode): ${cause.message}';
}

/// The HTTP transfer failed: DNS, sockets, TLS, aborted connections.
final class OpenCodeTransportError extends OpenCodeError {
  /// Wraps the transport exception.
  const OpenCodeTransportError(this.cause);

  /// The original exception thrown by the SDK.
  final OpenCodeTransportException cause;

  /// The underlying error from the HTTP stack.
  Object get reason => cause.cause;

  @override
  String get message => 'The request to the OpenCode server failed: $reason';

  @override
  String toString() => 'OpenCodeTransportError($reason)';
}

/// A response body was missing, truncated or not valid JSON.
final class OpenCodeMalformedResponseError extends OpenCodeError {
  /// Wraps the malformed-response exception.
  const OpenCodeMalformedResponseError(this.cause);

  /// The original exception thrown by the SDK.
  final OpenCodeMalformedResponseException cause;

  @override
  String get message => cause.message;

  @override
  String toString() => 'OpenCodeMalformedResponseError(${cause.message})';
}

/// A payload did not match the shape declared by the OpenAPI contract.
final class OpenCodeDecodeError extends OpenCodeError {
  /// Wraps the decode exception.
  const OpenCodeDecodeError(this.cause);

  /// The original exception thrown by the SDK.
  final OpenCodeDecodeException cause;

  /// Dotted path of the offending value, when known.
  String? get path => cause.path;

  @override
  String get message => cause.message;

  @override
  String toString() =>
      'OpenCodeDecodeError(${cause.message}${path == null ? '' : ' at $path'})';
}

/// An event stream failed: oversized frames, subscriber overflow, a wrong
/// content type, or an ended live-only connection.
final class OpenCodeStreamError extends OpenCodeError {
  /// Wraps the stream exception.
  const OpenCodeStreamError(this.cause);

  /// The original exception thrown by the SDK.
  final OpenCodeStreamException cause;

  @override
  String get message => cause.message;

  @override
  String toString() => 'OpenCodeStreamError(${cause.message})';
}

/// A request was cancelled through an SDK cancellation token that the effect
/// runtime did not create (for example a turn interrupted server-side).
///
/// Effect interruption is reported as `Interrupted` in the fiber's cause and
/// never surfaces through this error.
final class OpenCodeCallCancelled extends OpenCodeError {
  /// Wraps the SDK cancellation exception.
  const OpenCodeCallCancelled(this.cause);

  /// The original exception thrown by the SDK.
  final OpenCodeCancelledException cause;

  @override
  String get message => cause.message;

  @override
  String toString() => 'OpenCodeCallCancelled(${cause.message})';
}

/// The server reported a session turn as failed
/// (`session.execution.failed`).
final class OpenCodeExecutionFailed extends OpenCodeError {
  /// Wraps the execution exception.
  const OpenCodeExecutionFailed(this.cause);

  /// The original exception thrown by the SDK.
  final OpenCodeExecutionException cause;

  /// The raw `session.execution.failed` payload.
  JsonMap? get data => cause.data;

  @override
  String get message => cause.message;

  @override
  String toString() => 'OpenCodeExecutionFailed(${cause.message})';
}

/// Local background service management failed (discovery, start, stop).
final class OpenCodeServiceError extends OpenCodeError {
  /// Creates a service error.
  const OpenCodeServiceError(this.message, {this.cause});

  @override
  final String message;

  /// The underlying failure, when one exists.
  final Object? cause;

  @override
  String toString() =>
      'OpenCodeServiceError($message${cause == null ? '' : ': $cause'})';
}

/// The set of HTTP statuses a retry may safely be attempted for.
const Set<int> transientStatusCodeSet = {408, 429, 500, 502, 503, 504};

/// Whether [error] is a transient failure that a *read* operation may retry.
///
/// Writes must never be retried implicitly: a timed-out prompt may already
/// have been admitted server-side, and a blind retry would execute it twice.
bool isTransient(OpenCodeError error) => switch (error) {
  OpenCodeTransportError() => true,
  OpenCodeStreamError() => true,
  OpenCodeApiError(:final statusCode) =>
    statusCode != null && transientStatusCodeSet.contains(statusCode),
  _ => false,
};

/// Maps a thrown SDK exception to the typed family.
///
/// Returns `null` when [error] is not a known SDK exception; callers decide
/// whether that is a defect.
OpenCodeError? mapOpenCodeException(Object error) => switch (error) {
  final OpenCodeApiException exception => OpenCodeApiError(exception),
  final OpenCodeTransportException exception => OpenCodeTransportError(
    exception,
  ),
  final OpenCodeMalformedResponseException exception =>
    OpenCodeMalformedResponseError(exception),
  final OpenCodeDecodeException exception => OpenCodeDecodeError(exception),
  final OpenCodeStreamException exception => OpenCodeStreamError(exception),
  final OpenCodeCancelledException exception => OpenCodeCallCancelled(
    exception,
  ),
  final OpenCodeExecutionException exception => OpenCodeExecutionFailed(
    exception,
  ),
  _ => null,
};

/// Maps [error] to the typed family, rethrowing unknown objects with their
/// original stack trace (so they stay defects).
OpenCodeError mapOrRethrow(Object error, StackTrace stackTrace) {
  final mapped = mapOpenCodeException(error);
  if (mapped != null) return mapped;
  Error.throwWithStackTrace(error, stackTrace);
}
