/// Server-sent events (SSE) framing for `text/event-stream` endpoints.
///
/// The parser mirrors the reference `@opencode/client` implementation: only
/// `data:` lines are collected (joined with newlines), blank lines terminate a
/// frame, and each frame is decoded as JSON. Frames larger than [byteLimit]
/// characters abort the stream.
///
/// The implementation is controller-based so that cancelling a subscription
/// completes immediately instead of waiting for the next frame.
library;

import 'dart:async';
import 'dart:convert';

import 'errors.dart';

/// Decodes a byte stream of SSE frames into decoded JSON values.
///
/// [onActivity] is invoked for every received chunk, matching the activity
/// callback exposed by the reference client.
Stream<Object?> decodeSseFrames(
  Stream<List<int>> byteStream, {
  int byteLimit = 16 * 1024 * 1024,
  void Function()? onActivity,
}) {
  final controller = StreamController<Object?>();
  final decoded = StringBuffer();
  final sink = const Utf8Decoder(allowMalformed: true)
      .startChunkedConversion(StringConversionSink.fromStringSink(decoded));
  var buffer = '';
  var failed = false;
  StreamSubscription<List<int>>? subscription;

  void fail(Object error, [StackTrace? stackTrace]) {
    if (failed || controller.isClosed) return;
    failed = true;
    controller.addError(error, stackTrace);
    unawaited(subscription?.cancel());
    unawaited(controller.close());
  }

  void emit(String block) {
    try {
      final frame = decodeSseBlock(block);
      if (frame != null && !failed) controller.add(frame);
    } on OpenCodeMalformedResponseException catch (error, stackTrace) {
      fail(error, stackTrace);
    }
  }

  void drainBufferedFrames() {
    var boundary = buffer.indexOf('\n\n');
    while (boundary >= 0 && !failed) {
      final block = buffer.substring(0, boundary);
      buffer = buffer.substring(boundary + 2);
      emit(block);
      boundary = buffer.indexOf('\n\n');
    }
  }

  void handleChunk(List<int> chunk) {
    if (failed) return;
    onActivity?.call();
    decoded.clear();
    sink.add(chunk);
    buffer += decoded.toString();
    decoded.clear();
    if (buffer.length > byteLimit) {
      fail(
        OpenCodeStreamException(
          'SSE event exceeded the $byteLimit character limit',
        ),
      );
      return;
    }
    // Normalize CRLF and lone CR line endings, keeping a trailing CR that may
    // be completed by the next chunk.
    final trailingCarriageReturn = buffer.endsWith('\r');
    var normalized = buffer;
    if (trailingCarriageReturn) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    normalized = normalized.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (trailingCarriageReturn) normalized += '\r';
    buffer = normalized;
    drainBufferedFrames();
  }

  void handleDone() {
    if (failed) return;
    sink.close();
    buffer += decoded.toString();
    decoded.clear();
    if (buffer.isNotEmpty) {
      buffer += '\n\n';
      drainBufferedFrames();
    }
    if (!failed && !controller.isClosed) {
      unawaited(controller.close());
    }
  }

  controller.onListen = () {
    subscription = byteStream.listen(
      handleChunk,
      onError: fail,
      onDone: handleDone,
      cancelOnError: true,
    );
  };
  controller.onCancel = () {
    failed = true;
    unawaited(subscription?.cancel());
  };
  return controller.stream;
}

/// Decodes a single SSE frame block, or returns `null` when it has no data.
Object? decodeSseBlock(String block) {
  final data = <String>[];
  for (final line in block.split('\n')) {
    if (line.startsWith('data:')) {
      data.add(line.substring(5).trimLeft());
    }
  }
  if (data.isEmpty) return null;
  final joined = data.join('\n');
  if (joined.isEmpty) return null;
  try {
    return jsonDecode(joined);
  } on FormatException catch (error) {
    throw OpenCodeMalformedResponseException(
      'Invalid JSON in an SSE frame',
      cause: error,
    );
  }
}
