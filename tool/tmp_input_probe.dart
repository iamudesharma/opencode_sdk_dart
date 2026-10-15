// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

Future<void> main() async {
  final endpoint = await OpenCodeService.discover();
  final client = OpenCodeClient(
    baseUrl: endpoint!.url,
    headers: OpenCodeService.headers(endpoint),
  );
  try {
    final sessions = await client.session.list(limit: '1', order: SessionListOrder.desc);
    final session = sessions.data.first;
    final info = await client.persistentPty.create(
      sessionID: session.id,
      title: 'input-probe',
      args: const [],
      env: const {},
    );
    final socket = await client.persistentPty.connectSocket(ptyID: info.id, takeover: true);
    String? attachmentID;
    final sub = socket.frames.listen((frame) {
      if (frame is PtyOutput) {
        try {
          final decoded = jsonDecode(frame.data);
          if (decoded is Map && decoded['attachmentID'] is String && attachmentID == null) {
            attachmentID = decoded['attachmentID'] as String;
            print('captured attachmentID=$attachmentID');
          }
        } on Object {
          // raw output
        }
      }
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    attachmentID ??= 'unknown';
    print('using attachment=$attachmentID');

    Future<bool> tryFrame(String label, Object payload) async {
      socket.send(payload is String ? payload : jsonEncode(payload));
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final snapshot = await client.persistentPty.snapshot(ptyID: info.id);
      final hit = snapshot.text.contains(label);
      if (hit) print('HIT: $label  payload=${jsonEncode(payload)}');
      return hit;
    }

    final attempt = 0;
    if (await tryFrame('C1', {'type': 'input', 'data': 'echo C1\n'})) return;
    if (await tryFrame('C2', {'type': 'stdin', 'data': 'echo C2\n'})) return;
    if (await tryFrame('C3', {'type': 'input', 'text': 'echo C3\n'})) return;
    if (await tryFrame('C4', {'type': 'input', 'data': 'echo C4\n', 'attachmentID': attachmentID})) return;
    if (await tryFrame('C5', {'type': 'input', 'data': base64Encode(utf8.encode('echo C5\n'))})) return;
    if (await tryFrame('C6', {'type': 'input', 'base64': base64Encode(utf8.encode('echo C6\n'))})) return;
    if (await tryFrame('C7', {'type': 'write', 'data': 'echo C7\n', 'attachmentID': attachmentID})) return;
    if (await tryFrame('C8', {'type': 'input', 'payload': 'echo C8\n', 'attachmentID': attachmentID})) return;
    if (await tryFrame('C9', {'type': 'data', 'data': 'echo C9\n', 'attachmentID': attachmentID})) return;
    if (await tryFrame('C10', {'type': 'input', 'data': 'echo C10\n', 'attachmentID': attachmentID, 'inputProtocol': 1})) return;
    print('no candidate frame worked (attempt $attempt)');

    await sub.cancel();
    await socket.close();
    await client.persistentPty.remove(ptyID: info.id);
    print('cleaned up');
  } finally {
    client.close();
  }
}
