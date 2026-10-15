import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('extension types', () {
    test('decode, compare, and use as strings', () {
      final id = SessionID.fromJson('ses_123');
      expect(id, 'ses_123');
      expect(id.startsWith('ses'), isTrue);
      expect(SessionID.fromJson('ses_123'), id);
    });

    test('numeric aliases decode from any JSON number', () {
      expect(MoneyUSD.fromJson(3), 3.0);
      expect(MoneyUSD.fromJson(2.5), 2.5);
    });

    test('reject mismatched JSON types with a decode error', () {
      expect(
        () => SessionID.fromJson(3),
        throwsA(isA<OpenCodeDecodeException>()),
      );
    });
  });

  group('enums', () {
    test('round trip wire values', () {
      expect(PtyStatus.running.wire, 'running');
      expect(PtyStatus.fromWire('exited'), PtyStatus.exited);
      expect(PtyStatus.fromJson('running'), PtyStatus.running);
      expect(
        () => PtyStatus.fromJson('nope'),
        throwsA(isA<OpenCodeDecodeException>()),
      );
    });

    test('sanitize awkward member names', () {
      expect(McpProtocol.v20260728.wire, '2026-07-28');
      expect(PermissionEffect.fromWire('ask'), PermissionEffect.ask);
    });
  });

  group('unions', () {
    test('dispatch on the discriminator', () {
      final content = ToolContent.fromJson({'type': 'text', 'text': 'hi'});
      expect(content, isA<ToolTextContent>());
      expect((content as ToolTextContent).text, 'hi');
      expect(content.type, 'text');
      expect(content.toJson(), {'type': 'text', 'text': 'hi'});
    });

    test('optional variant fields are omitted when null', () {
      final content = ToolContent.fromJson({
        'type': 'file',
        'uri': 'file:///a.png',
        'mime': 'image/png',
      });
      expect(content, isA<ToolFileContent>());
      expect(content.toJson(), {
        'type': 'file',
        'uri': 'file:///a.png',
        'mime': 'image/png',
      });
    });

    test('nested unions resolve through the parent discriminator', () {
      final message = SessionMessageInfo.fromJson({
        'id': 'msg_1',
        'type': 'compaction',
        'status': 'running',
        'time': {'created': 1},
        'reason': 'auto',
        'summary': 'summarizing',
        'recent': 'recent context',
      });
      expect(message, isA<SessionMessageCompactionRunning>());
      expect(message.type, 'compaction');
      expect((message as SessionMessageCompactionRunning).reason,
          SessionMessageCompactionRunningReason.auto);
      final encoded = message.toJson();
      expect(encoded['type'], 'compaction');
      expect(encoded['status'], 'running');
    });

    test('reject unknown discriminators', () {
      expect(
        () => SessionMessageInfo.fromJson({'type': 'mystery'}),
        throwsA(isA<OpenCodeDecodeException>()),
      );
    });
  });

  group('objects', () {
    test('round trip optional and required fields', () {
      final pty = Pty.fromJson({
        'id': 'pty_1',
        'title': 'shell',
        'command': '/bin/zsh',
        'args': <String>[],
        'cwd': '/tmp',
        'status': 'running',
        'pid': 42,
      });
      expect(pty.id, 'pty_1');
      expect(pty.status, PtyStatus.running);
      expect(pty.exitCode, isNull);
      expect(pty.toJson(), {
        'id': 'pty_1',
        'title': 'shell',
        'command': '/bin/zsh',
        'args': <String>[],
        'cwd': '/tmp',
        'status': 'running',
        'pid': 42,
      });
    });

    test('missing required fields surface the field path', () {
      try {
        Pty.fromJson({'id': 'pty_1'});
        fail('expected a decode error');
      } on OpenCodeDecodeException catch (error) {
        expect(error.path, 'title');
      }
    });

    test('boolean-or-map config fields decode as dynamic', () {
      final config = ConfigInfoEncoded.fromJson({
        'update': 'auto',
        'share': 'manual',
        'enterprise': <String, Object?>{},
        'permissions': <Object?>[],
        'policies': <Object?>[],
        'agents': <String, Object?>{},
        'formatter': true,
        'lsp': {
          'typescript': {
            'command': <String>['tsc'],
          },
        },
      });
      expect(config.formatter, true);
      expect(config.lsp, isA<Map<String, Object?>>());
    });

    test('sealed unions expose shared members', () {
      final message = SessionMessageInfo.fromJson({
        'id': 'msg_9',
        'type': 'user',
        'time': {'created': 1},
        'text': 'hello',
      });
      expect(message.id, 'msg_9');
      expect(message.type, 'user');
    });
  });

  group('located responses', () {
    test('decode location and payload', () {
      final response = LocatedResponse.fromJson(
        {
          'location': {'directory': '/workspace'},
          'data': <String>['a', 'b'],
        },
        (value) => jsonList(value, asJsonString),
      );
      expect(response.location.directory, '/workspace');
      expect(response.data, ['a', 'b']);
    });
  });

  group('errors', () {
    test('decode structured errors by tag', () {
      final error = decodeOpenCodeException(404, {
        '_tag': 'SessionNotFoundError',
        'message': 'no such session',
        'sessionID': 'ses_1',
      });
      expect(error, isA<SessionNotFoundError>());
      final typed = error! as SessionNotFoundError;
      expect(typed.sessionID, 'ses_1');
      expect(typed.message, 'no such session');
      expect(typed.tag, 'SessionNotFoundError');
    });

    test('decode RPC errors with data', () {
      final error = decodeOpenCodeException(400, {
        '_tag': 'RpcError',
        'type': 'not_found',
        'message': 'Result not found',
        'data': {'query': 'hello'},
      });
      expect(error, isA<RpcError>());
      final rpc = error! as RpcError;
      expect(rpc.type, 'not_found');
      expect(rpc.data, {'query': 'hello'});
    });

    test('unknown tags and bodies return null', () {
      expect(decodeOpenCodeException(500, {'_tag': 'Mystery'}), isNull);
      expect(decodeOpenCodeException(500, 'boom'), isNull);
    });
  });
}
