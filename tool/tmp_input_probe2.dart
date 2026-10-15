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
      title: 'input-probe-2',
      args: const [],
      env: const {},
    );
    final socket = await client.persistentPty.connectSocket(ptyID: info.id, takeover: true);
    final control = <String>[];
    final sub = socket.frames.listen((frame) {
      if (frame is PtyOutput) {
        final text = frame.data;
        try {
          final decoded = jsonDecode(text);
          if (decoded is Map) {
            control.add(text);
            print('CONTROL: $text');
            return;
          }
        } on Object {
          // raw output
        }
      }
    });
    await Future<void>.delayed(const Duration(seconds: 2));

    Future<void> attempt(String label, Object? payload, {bool binary = false}) async {
      control.clear();
      if (binary) {
        socket.send(utf8.encode(jsonEncode(payload)));
      } else {
        socket.send(payload);
      }
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final snapshot = await client.persistentPty.snapshot(ptyID: info.id);
      final echo = snapshot.text.contains(label);
      print('[$label] echo=$echo controlFrames=${control.length} ${control.isNotEmpty ? control.first : ''}');
    }

    await attempt('D1', {'type': 'input', 'data': 'echo D1\n'});
    await attempt('D2', {'type': 'input', 'data': 'echo D2\n'}, binary: true);
    await attempt('D3', {'type': 'stdin', 'data': 'echo D3\n'}, binary: true);
    await attempt('D4', {'type': 'input', 'input': 'echo D4\n'});
    await attempt('D5', {'type': 'input', 'data': <int>[101, 99, 104, 111, 32, 68, 53, 10]});
    await attempt('D6', 'echo D6\n', binary: true);
    await attempt('D7', {'type': 'input', 'data': 'echo D7\n', 'attachmentID': 'x'}, binary: true);

    await sub.cancel();
    await socket.close();
    await client.persistentPty.remove(ptyID: info.id);
    print('cleaned up');
  } finally {
    client.close();
  }
}
