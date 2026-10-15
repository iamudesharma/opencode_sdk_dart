/// Browser WebSocket channel creation.
///
/// Browsers do not allow custom headers on WebSocket upgrades, so [headers]
/// are ignored; authentication relies on the connection ticket carried in the
/// URL.
library;

import 'package:web_socket_channel/web_socket_channel.dart';

/// Opens a WebSocket channel.
WebSocketChannel openWebSocketChannel(
  Uri uri, {
  Map<String, String>? headers,
}) {
  return WebSocketChannel.connect(uri);
}
