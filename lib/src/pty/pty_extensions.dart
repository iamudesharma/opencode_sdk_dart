/// WebSocket helpers layered on top of the generated PTY resources.
///
/// The HTTP surface only exposes tickets; the actual terminal stream runs over
/// a WebSocket. These extensions perform the full handshake used by the
/// reference client:
///
/// 1. `POST /api/pty/{ptyID}/connect-token` with `x-opencode-ticket: 1`;
/// 2. upgrade `/api/pty/{ptyID}/connect?ticket=...` to a WebSocket.
library;

import '../core/request_options.dart';
import '../generated/models.dart';
import '../generated/resources/persistent_pty_resource.dart';
import '../generated/resources/pty_resource.dart';
import 'pty_socket.dart';

/// Adds [connectSocket] to the generated PTY resource.
extension PtyResourceWebSocket on PtyResource {
  /// Requests a connection ticket and opens the PTY WebSocket.
  ///
  /// [cursor] resumes from a previously seen output offset. Messages are
  /// delivered as text and binary frames through [PtySocket.messages].
  Future<PtySocket> connectSocket({
    required PtyID ptyID,
    int? cursor,
    LocationRef? location,
    RequestOptions? options,
  }) async {
    final token = await connectToken(
      ptyID: ptyID,
      location: location,
      xOpencodeTicket: '1',
      options: options,
    );
    return openPtyWebSocket(
      baseUrl: transport.baseUrl,
      path: 'api/pty/${Uri.encodeComponent(ptyID.toString())}/connect',
      ticket: token.data.ticket,
      cursor: cursor,
      directory: token.location.directory ?? location?.directory,
      headers: transport.defaultHeaders,
    );
  }
}

/// Adds [connectSocket] to the generated persistent PTY resource.
extension PersistentPtyResourceWebSocket on PersistentPtyResource {
  /// Requests a connection ticket and opens the persistent PTY WebSocket.
  ///
  /// [cursor] names the output offset to resume from, [takeover] steals an
  /// existing attachment, and [attachmentID] re-attaches to a known one.
  Future<PtySocket> connectSocket({
    required PtyID ptyID,
    String? cursor,
    String? role,
    String? attachmentID,
    bool takeover = false,
    RequestOptions? options,
  }) async {
    final token = await connectToken(
      ptyID: ptyID,
      xOpencodeTicket: '1',
      options: options,
    );
    return openPtyWebSocket(
      baseUrl: transport.baseUrl,
      path: 'api/experimental/persistent-pty/'
          '${Uri.encodeComponent(ptyID.toString())}/connect',
      ticket: token.ticket,
      cursor: cursor != null && int.tryParse(cursor) != null
          ? int.parse(cursor)
          : null,
      headers: transport.defaultHeaders,
      query: <String, String>{
        'input_protocol': '1',
        'takeover': '$takeover',
        if (cursor != null && int.tryParse(cursor) == null) 'cursor': cursor,
        if (role != null) 'role': role,
        if (attachmentID != null) 'attachment_id': attachmentID,
      },
    );
  }
}
