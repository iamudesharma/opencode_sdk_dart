/// `dart:io` WebSocket channel creation with header support.
library;

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a WebSocket channel, sending [headers] during the HTTP upgrade.
WebSocketChannel openWebSocketChannel(
  Uri uri, {
  Map<String, String>? headers,
}) {
  return IOWebSocketChannel.connect(uri, headers: headers);
}
