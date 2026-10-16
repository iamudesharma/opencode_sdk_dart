// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:convert';

import 'package:genkit/plugin.dart';
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

/// Maps an error thrown by [sdk.OpenCodeClient] (or friends) to a
/// [GenkitException].
///
/// The OpenCode SDK surfaces provider failures as `OpenCodeApiException`
/// subclasses carrying the HTTP status; anything else is treated as a
/// transport failure.
GenkitException openCodeError(Object error, {StackTrace? stackTrace}) {
  if (error is GenkitException) return error;
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
