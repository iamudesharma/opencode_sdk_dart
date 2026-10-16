/// Cross-platform Dart SDK for the OpenCode V2 HTTP API.
///
/// The SDK is generated from the official OpenAPI 3.1 contract and mirrors the
/// reference `@opencode/client` semantics:
///
/// * typed resources for every API group (`client.session`, `client.pty`, ...);
/// * sealed model unions, branded scalar types, and enums;
/// * structured errors decoded from `_tag` payloads;
/// * one lazily shared event connection for native events and plugin RPC;
/// * PTY WebSocket helpers and local background service discovery.
///
/// ```dart
/// final client = OpenCodeClient.make(
///   baseUrl: Uri.parse('http://localhost:4096'),
/// );
/// final session = await client.session.create(title: 'Hello');
/// await client.session.prompt(sessionID: session.id, text: 'Hi!');
/// ```
library;

export 'src/core/errors.dart';
export 'src/core/events.dart';
export 'src/core/json_utils.dart';
export 'src/core/request_options.dart';
export 'src/core/retry.dart';
export 'src/core/sse.dart';
export 'src/core/transport.dart';
export 'src/generated/client.dart';
export 'src/generated/models.dart';
export 'src/pty/pty_extensions.dart';
export 'src/pty/pty_socket.dart';
export 'src/rpc/rpc.dart';
export 'src/service/service.dart';
export 'src/session/session_extensions.dart';
