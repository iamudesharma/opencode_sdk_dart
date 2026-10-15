/// PTY WebSocket connections.
///
/// PTY sessions are streamed over WebSocket. The sequence mirrors the
/// reference client: request a short-lived ticket through
/// `POST /api/pty/{ptyID}/connect-token` (or the persistent variant), then
/// upgrade `/api/pty/{ptyID}/connect?ticket=...` to a WebSocket.
library;

import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_stub.dart' if (dart.library.io) 'websocket_io.dart' as ws;

/// A live PTY WebSocket connection.
final class PtySocket {
  PtySocket._(this._channel);

  final WebSocketChannel _channel;

  /// Raw incoming messages: [String] for text frames, `List<int>` for binary
  /// frames.
  Stream<Object?> get messages => _channel.stream;

  /// Terminal frames with cursor bookkeeping removed.
  ///
  /// The server sends terminal output as text frames and resume cursors as
  /// binary frames containing `{"cursor":<offset>}`. Consume [frames] to get
  /// pure output plus cursor updates; use [output] when only the text matters.
  Stream<PtyFrame> get frames => messages.map(PtyFrame.parse);

  /// Terminal output with cursor markers stripped.
  Stream<String> get output => frames
      .where((frame) => frame is PtyOutput)
      .map((frame) => (frame as PtyOutput).data);

  /// Incoming messages decoded as UTF-8 text.
  Stream<String> get text {
    return messages.map((message) {
      if (message is String) return message;
      if (message is List<int>) return utf8.decode(message);
      return message.toString();
    });
  }

  /// Whether the connection is closed.
  Future<void> get ready => _channel.ready;

  /// Sends a message. [String] values are text frames, [List<int>] values are
  /// binary frames, and any other value is JSON encoded as a text frame.
  void send(Object? data) {
    switch (data) {
      case String():
        _channel.sink.add(data);
      case List<int>():
        _channel.sink.add(data);
      case null:
        _channel.sink.add(null);
      default:
        _channel.sink.add(jsonEncode(data));
    }
  }

  /// Sends terminal input to the shell.
  void sendInput(String data) => send(data);

  /// Closes the connection.
  Future<void> close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  /// The underlying channel, for advanced use.
  WebSocketChannel get channel => _channel;
}

/// One decoded PTY frame.
sealed class PtyFrame {
  const PtyFrame();

  /// Decodes one raw WebSocket message.
  factory PtyFrame.parse(Object? message) {
    if (message is List<int>) {
      try {
        final decoded = jsonDecode(utf8.decode(message));
        if (decoded is Map && decoded['cursor'] is num) {
          return PtyCursor((decoded['cursor'] as num).toInt());
        }
      } on Object {
        // Not a cursor marker; fall through to raw output.
      }
      return PtyOutput(utf8.decode(message, allowMalformed: true));
    }
    if (message is String) return PtyOutput(message);
    return PtyOutput('$message');
  }
}

/// Encodes frames for PTY sockets that negotiated `input_protocol=1`.
///
/// The persistent-terminal protocol (verified against the server
/// implementation) frames input as binary messages:
///
/// ```text
/// byte 0      type: 0 = control (resize), 1 = input
/// bytes 1-2   columns, big endian uint16
/// bytes 3-4   rows, big endian uint16
/// bytes 5..   UTF-8 payload (input only)
/// ```
///
/// Columns and rows travel with every frame so the server can resize the
/// terminal atomically with the keystrokes that produced the change.
final class PtyInputFrames {
  PtyInputFrames({this.cols = 80, this.rows = 24});

  /// Current terminal width in columns (must be non-zero).
  int cols;

  /// Current terminal height in rows (must be non-zero).
  int rows;

  /// Encodes a keystroke payload as an input frame.
  List<int> input(String data) => _encode(1, utf8.encode(data));

  /// Encodes a resize control frame using the current [cols] and [rows].
  List<int> resize({int? cols, int? rows}) {
    if (cols != null) this.cols = cols;
    if (rows != null) this.rows = rows;
    return _encode(0, null);
  }

  List<int> _encode(int type, List<int>? payload) {
    final frame = Uint8List(5 + (payload?.length ?? 0));
    frame[0] = type;
    frame[1] = (cols >> 8) & 0xFF;
    frame[2] = cols & 0xFF;
    frame[3] = (rows >> 8) & 0xFF;
    frame[4] = rows & 0xFF;
    if (payload != null) frame.setRange(5, frame.length, payload);
    return frame;
  }
}

/// Terminal output from the shell.
final class PtyOutput extends PtyFrame {
  const PtyOutput(this.data);

  final String data;

  @override
  String toString() => 'PtyOutput(${data.length} chars)';
}

/// A resume cursor reported by the server.
final class PtyCursor extends PtyFrame {
  const PtyCursor(this.cursor);

  /// The byte offset to pass back as the `cursor` parameter when reconnecting.
  final int cursor;

  @override
  String toString() => 'PtyCursor($cursor)';
}

/// Opens a PTY WebSocket with an already acquired [ticket].
///
/// [path] is the operation path relative to the server root, for example
/// `api/pty/<ptyID>/connect`. Extra [query] entries are appended after the
/// standard `ticket`, `cursor`, and location parameters.
Future<PtySocket> openPtyWebSocket({
  required Uri baseUrl,
  required String path,
  required String ticket,
  int? cursor,
  String? directory,
  Map<String, String>? headers,
  Map<String, String>? query,
}) async {
  final uri = websocketUri(
    baseUrl,
    path,
    query: <String, String>{
      if (directory != null) 'location[directory]': directory,
      if (cursor != null) 'cursor': '$cursor',
      'ticket': ticket,
      ...?query,
    },
  );
  final channel = ws.openWebSocketChannel(uri, headers: headers);
  await channel.ready;
  return PtySocket._(channel);
}

/// Builds a `ws:`/`wss:` URL from an HTTP base URL.
Uri websocketUri(
  Uri baseUrl,
  String path, {
  Map<String, String>? query,
}) {
  var relative = path;
  while (relative.startsWith('/')) {
    relative = relative.substring(1);
  }
  var normalized = baseUrl;
  if (!normalized.path.endsWith('/')) {
    normalized = normalized.replace(path: '${normalized.path}/');
  }
  final http = normalized.resolve(relative);
  final scheme = switch (http.scheme) {
    'https' => 'wss',
    'http' => 'ws',
    _ => http.scheme,
  };
  final entries = query?.entries ?? const <MapEntry<String, String>>[];
  final queryString = entries
      .map((entry) =>
          '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}')
      .join('&');
  final authority = http.hasPort ? '${http.host}:${http.port}' : http.host;
  final base = '$scheme://$authority${http.path}';
  return Uri.parse(queryString.isEmpty ? base : '$base?$queryString');
}
