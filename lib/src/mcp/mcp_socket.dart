/// MCP client WebSocket connections.
///
/// `GET /api/experimental/client-mcp` upgrades the connection and lets the
/// client host an MCP server named after the `name` query parameter. One
/// JSON-RPC message travels per text frame.
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/request_options.dart';
import '../generated/resources/mcp_resource.dart';
import '../pty/pty_socket.dart' show websocketUri;
import '../pty/websocket_stub.dart'
    if (dart.library.io) '../pty/websocket_io.dart' as ws;

/// A live client-hosted MCP server connection.
final class McpClientSocket {
  McpClientSocket._(this._channel);

  final WebSocketChannel _channel;

  /// Raw incoming messages: [String] for text frames, `List<int>` for binary
  /// frames.
  Stream<Object?> get messages => _channel.stream;

  /// Incoming messages decoded as JSON-RPC objects.
  Stream<Map<String, Object?>> get jsonRpc => messages.map((message) {
        final text = message is String
            ? message
            : utf8.decode((message as List<int>), allowMalformed: true);
        final decoded = jsonDecode(text);
        if (decoded is! Map) {
          throw const FormatException('Expected a JSON-RPC object');
        }
        return decoded.cast<String, Object?>();
      });

  /// Whether the WebSocket upgrade has completed.
  Future<void> get ready => _channel.ready;

  /// Sends a JSON-RPC object (or a raw text/binary frame).
  void send(Object? message) {
    if (message is String || message is List<int>) {
      _channel.sink.add(message);
    } else {
      _channel.sink.add(jsonEncode(message));
    }
  }

  /// Closes the connection.
  Future<void> close([int? closeCode, String? closeReason]) =>
      _channel.sink.close(closeCode, closeReason);

  /// The underlying channel, for advanced use.
  WebSocketChannel get channel => _channel;
}

/// Adds [connectClientSocket] to the generated MCP resource.
extension McpResourceClientSocket on McpResource {
  /// Opens the client-hosted MCP server WebSocket for [name].
  ///
  /// The server exposes the client's tools while the socket stays open. Use
  /// [McpClientSocket.jsonRpc] for decoded messages or
  /// [McpClientSocket.messages] for raw frames. Browsers cannot set upgrade
  /// headers, so web callers should create a ticket through
  /// `client.mcp.clientToken(...)` and pass it as [ticket].
  Future<McpClientSocket> connectClientSocket({
    required String name,
    String? ticket,
    LocationRef? location,
    Map<String, String>? headers,
    RequestOptions? options,
  }) async {
    final directory = (location ?? options?.location)?.directory;
    final uri = websocketUri(
      transport.baseUrl,
      'api/experimental/client-mcp',
      query: <String, String>{
        'name': name,
        if (ticket != null) 'ticket': ticket,
        if (directory != null) 'location[directory]': directory,
      },
    );
    final channel = ws.openWebSocketChannel(
      uri,
      headers: <String, String>{
        ...transport.defaultHeaders,
        ...?headers,
      },
    );
    await channel.ready;
    return McpClientSocket._(channel);
  }
}
