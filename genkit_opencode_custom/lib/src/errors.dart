// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:convert';

import 'package:effect_core/effect_core.dart' as effect;
import 'package:genkit/plugin.dart';
import 'package:opencode_effect/opencode_effect.dart' as bridge;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;

/// Maps an HTTP error response from a Chat Completions endpoint to a
/// [GenkitException], extracting the provider's error message when present.
GenkitException chatCompletionError({
  required Uri url,
  required int statusCode,
  required String body,
}) {
  final message =
      _extractMessage(body) ??
      'Chat completion request to $url failed with HTTP $statusCode.';
  return GenkitException(
    message,
    status: StatusCode.fromHttpStatus(statusCode),
    details: body.isEmpty ? null : body,
  );
}

/// Wraps a transport failure (socket, TLS, malformed response) as a
/// [GenkitException] with an `UNAVAILABLE` status.
GenkitException chatTransportError(
  Object error, {
  required Uri url,
  StackTrace? stackTrace,
}) {
  if (error is sdk.OpenCodeCancelledException) {
    return GenkitException(
      'Chat completion request to $url was cancelled.',
      status: StatusCode.cancelled,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  return GenkitException(
    'Chat completion request to $url failed: $error',
    status: StatusCode.unavailable,
    cause: error,
    stackTrace: stackTrace,
  );
}

/// Maps an error thrown at the plugin's OpenCode boundary to a
/// [GenkitException].
///
/// Internally the plugin runs through the `opencode_effect` bridge, so errors
/// arrive as the typed [bridge.OpenCodeError] family (or an
/// [effect.EffectException] from interruption/defects). Both unwrap to the same
/// [GenkitException]s the plugin produced when it called the SDK directly: the
/// original SDK exception stays in `cause` and API failures keep their HTTP
/// status.
GenkitException openCodeError(Object error, {StackTrace? stackTrace}) {
  if (error is GenkitException) return error;
  if (error is bridge.OpenCodeError) {
    return _fromBridgeError(error, stackTrace: stackTrace);
  }
  if (error is effect.EffectException<bridge.OpenCodeError>) {
    return openCodeCauseError(error.cause, stackTrace: stackTrace);
  }
  if (error is sdk.OpenCodeApiException) {
    final status = error.statusCode;
    return GenkitException(
      error.message,
      status: status == null
          ? StatusCode.unknown
          : StatusCode.fromHttpStatus(status),
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is sdk.OpenCodeCancelledException) {
    return GenkitException(
      error.message,
      status: StatusCode.cancelled,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is sdk.OpenCodeExecutionException) {
    return GenkitException(
      error.message,
      status: StatusCode.internal,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  if (error is sdk.OpenCodeTransportException ||
      error is sdk.OpenCodeMalformedResponseException ||
      error is sdk.OpenCodeDecodeException ||
      error is sdk.OpenCodeStreamException) {
    return GenkitException(
      'OpenCode request failed: $error',
      status: StatusCode.unavailable,
      cause: error,
      stackTrace: stackTrace,
    );
  }
  return GenkitException(
    'OpenCode request failed: $error',
    status: StatusCode.unknown,
    cause: error,
    stackTrace: stackTrace,
  );
}

/// Maps an effect [cause] (the outcome of a run that did not succeed) to the
/// boundary [GenkitException].
///
/// Interruption is a cooperative cancel from the caller's token, so it maps to
/// `CANCELLED`; defects follow the legacy "everything at the boundary is a
/// [GenkitException]" contract.
GenkitException openCodeCauseError(
  effect.Cause<bridge.OpenCodeError> cause, {
  StackTrace? stackTrace,
}) => switch (cause) {
  effect.Expected(:final error) => openCodeError(error, stackTrace: stackTrace),
  effect.Interrupted() => GenkitException(
    'The OpenCode request was cancelled.',
    status: StatusCode.cancelled,
    stackTrace: stackTrace,
  ),
  effect.Defect(:final error, stackTrace: final defectTrace) => openCodeError(
    error,
    stackTrace: defectTrace,
  ),
  effect.Sequential(:final first) => openCodeCauseError(
    first,
    stackTrace: stackTrace,
  ),
};

GenkitException _fromBridgeError(
  bridge.OpenCodeError error, {
  StackTrace? stackTrace,
}) => switch (error) {
  final bridge.OpenCodeApiError api => GenkitException(
    api.message,
    status: api.statusCode == null
        ? StatusCode.unknown
        : StatusCode.fromHttpStatus(api.statusCode!),
    // Keep the decoded SDK exception as the cause, as the direct-SDK plugin
    // did, so callers inspecting `cause` keep seeing `SessionNotFoundError`
    // and friends.
    cause: api.cause,
    stackTrace: stackTrace,
  ),
  final bridge.OpenCodeCallCancelled cancelled => GenkitException(
    cancelled.message,
    status: StatusCode.cancelled,
    cause: cancelled.cause,
    stackTrace: stackTrace,
  ),
  final bridge.OpenCodeExecutionFailed failed => GenkitException(
    failed.message,
    status: StatusCode.internal,
    cause: failed.cause,
    stackTrace: stackTrace,
  ),
  final bridge.OpenCodeTransportError transport => _bridgeUnavailable(
    transport.cause,
    stackTrace,
  ),
  final bridge.OpenCodeMalformedResponseError malformed => _bridgeUnavailable(
    malformed.cause,
    stackTrace,
  ),
  final bridge.OpenCodeDecodeError decode => _bridgeUnavailable(
    decode.cause,
    stackTrace,
  ),
  final bridge.OpenCodeStreamError stream => _bridgeUnavailable(
    stream.cause,
    stackTrace,
  ),
  final bridge.OpenCodeServiceError service => GenkitException(
    service.message,
    status: StatusCode.unavailable,
    cause: service.cause ?? service,
    stackTrace: stackTrace,
  ),
};

/// The shared mapping for transport-shaped bridge failures: `UNAVAILABLE`
/// with the original SDK exception as both the message tail and the cause.
GenkitException _bridgeUnavailable(Object cause, StackTrace? stackTrace) =>
    GenkitException(
      'OpenCode request failed: $cause',
      status: StatusCode.unavailable,
      cause: cause,
      stackTrace: stackTrace,
    );

String? _extractMessage(String body) {
  if (body.isEmpty) return null;
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map) return null;
    final error = decoded['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    final message = decoded['message'];
    if (message is String && message.isNotEmpty) return message;
  } on FormatException {
    return null;
  }
  return null;
}
