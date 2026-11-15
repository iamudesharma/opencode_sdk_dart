import 'dart:io';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  test('connectClientSocket upgrades and exchanges JSON-RPC', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    server.listen((request) async {
      if (request.uri.path == '/api/experimental/client-mcp' &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        socket.listen(socket.add);
        return;
      }
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    });

    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    addTearDown(client.close);

    final socket = await client.mcp.connectClientSocket(name: 'test-tools');
    addTearDown(socket.close);
    socket.send({
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'ping',
    });

    final message = await socket.jsonRpc.first;
    expect(message['jsonrpc'], '2.0');
    expect(message['method'], 'ping');
  });
}
