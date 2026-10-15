import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

Map<String, Object?> sessionPayload({String id = 'ses_1'}) => {
      'id': id,
      'projectID': 'prj_1',
      'cost': 0.25,
      'tokens': {
        'input': 10,
        'output': 20,
        'reasoning': 0,
        'cache': {'read': 0, 'write': 0},
      },
      'time': {'created': 1, 'updated': 2},
      'location': {'directory': '/workspace'},
      'title': 'hello',
    };

void main() {
  test('decodes data envelopes into typed models', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return jsonResponse({'data': sessionPayload()});
      }),
    );
    final session = await client.session.get(sessionID: SessionID('ses_1'));
    expect(session, isA<SessionInfo>());
    expect(session.id, 'ses_1');
    expect(session.title, 'hello');
    expect(session.cost, 0.25);
    expect(captured.url.path, '/api/session/ses_1');
    client.close();
  });

  test('decodes located envelopes', () async {
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        return jsonResponse({
          'location': {'directory': '/workspace'},
          'data': [
            {
              'id': 'agent_1',
              'name': 'build',
              'request': {
                'settings': <String, Object?>{},
                'headers': <String, Object?>{},
                'body': <String, Object?>{},
              },
              'mode': 'primary',
              'hidden': false,
              'permissions': <Object?>[],
            },
          ],
        });
      }),
    );
    final agents = await client.agent.list();
    expect(agents.location.directory, '/workspace');
    expect(agents.data.single.name, 'build');
    expect(agents.data.single.mode, AgentInfoMode.primary);
    client.close();
  });
  test('sends typed enum and string query parameters', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return jsonResponse({
          'data': <Object?>[],
          'cursor': <String, Object?>{},
        });
      }),
    );
    await client.session.list(limit: '5', order: SessionListOrder.desc);
    expect(captured.url.queryParameters['limit'], '5');
    expect(captured.url.queryParameters['order'], 'desc');
    client.close();
  });

  test('sends the location as a deep object query parameter', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return jsonResponse({
          'location': {'directory': '/work space'},
          'data': {
            'id': 'pty_1',
            'title': 'shell',
            'command': 'zsh',
            'args': <String>[],
            'cwd': '/work space',
            'status': 'running',
            'pid': 7,
          },
        });
      }),
    );
    await client.pty.get(
      ptyID: PtyID('pty_1'),
      location: const LocationRef.directory('/work space'),
    );
    expect(captured.url.queryParameters['location[directory]'], '/work space');
    client.close();
  });

  test('sends operation headers', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return jsonResponse({
          'location': {'directory': '/w'},
          'data': {'ticket': 'abc', 'expires_in': 30},
        });
      }),
    );
    final token = await client.pty.connectToken(
      ptyID: PtyID('pty_1'),
      xOpencodeTicket: '1',
    );
    expect(captured.headers['x-opencode-ticket'], '1');
    expect(token.data.ticket, 'abc');
    expect(token.data.expiresIn, 30);
    client.close();
  });

  test('completes void responses', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response('', 204);
      }),
    );
    await client.session.remove(sessionID: SessionID('ses_1'));
    expect(captured.method, 'DELETE');
    expect(captured.url.path, '/api/session/ses_1');
    client.close();
  });

  test('reads binary files with wildcard paths', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response.bytes(
          [1, 2, 3],
          200,
          headers: {'content-type': 'application/octet-stream'},
        );
      }),
    );
    final bytes = await client.filesystem.read(path: 'src/a b.txt');
    expect(bytes, Uint8List.fromList([1, 2, 3]));
    expect(captured.url.path, '/api/fs/read/src/a%20b.txt');
    client.close();
  });

  test('writes binary files with a content type', () async {
    late http.Request captured;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        captured = request;
        return jsonResponse({
          'location': {'directory': '/tmp'},
          'data': {'path': '/tmp/x.txt'},
        });
      }),
    );
    await client.filesystem.write(path: '/tmp/x.txt', payload: [104, 105]);
    expect(captured.headers['content-type'], 'application/octet-stream');
    expect(captured.bodyBytes, [104, 105]);
    expect(captured.url.queryParameters['path'], '/tmp/x.txt');
    client.close();
  });

  test('maps error statuses to typed exceptions', () async {
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        return jsonResponse({
          '_tag': 'SessionNotFoundError',
          'message': 'gone',
          'sessionID': 'ses_1',
        }, status: 404);
      }),
    );
    try {
      await client.session.get(sessionID: SessionID('ses_1'));
      fail('expected an exception');
    } on SessionNotFoundError catch (error) {
      expect(error.statusCode, 404);
      expect(error.sessionID, 'ses_1');
    }
    client.close();
  });

  test('shares one event connection between subscribers', () async {
    var requests = 0;
    final frames = StreamController<List<int>>();
    MockClient streamClient() => MockClient.streaming((request, bodyStream) {
          requests++;
          return Future<http.StreamedResponse>.value(
            http.StreamedResponse(
              frames.stream,
              200,
              headers: {'content-type': 'text/event-stream'},
            ),
          );
        });
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: streamClient(),
      clientFactory: streamClient,
    );

    final first = <String>[];
    final second = <String>[];
    final firstSubscription =
        client.event.subscribe().listen((event) => first.add(event.type));
    final secondSubscription =
        client.events.subscribe().listen((event) => second.add(event.type));
    frames.add(utf8.encode('data: {"type": "server.connected"}\n\n'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    frames.add(utf8.encode(
      'data: {"type": "session.updated", "data": {"sessionID": "ses_1"}}\n\n',
    ));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(requests, 1);
    expect(first, ['server.connected', 'session.updated']);
    expect(second, ['server.connected', 'session.updated']);

    await firstSubscription.cancel();
    await secondSubscription.cancel();
    await frames.close();
    client.close();
  });

  test('streams session logs as JSON maps', () async {
    final frames = StreamController<List<int>>();
    MockClient streamClient() => MockClient.streaming((request, bodyStream) {
          return Future<http.StreamedResponse>.value(
            http.StreamedResponse(
              frames.stream,
              200,
              headers: {'content-type': 'text/event-stream'},
            ),
          );
        });
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: streamClient(),
      clientFactory: streamClient,
    );
    final logs = <Map<String, Object?>>[];
    final subscription =
        client.session.log(sessionID: SessionID('ses_1')).listen(logs.add);
    frames.add(utf8.encode('data: {"level": "info", "message": "hello"}\n\n'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(logs.single, {'level': 'info', 'message': 'hello'});
    await subscription.cancel();
    await frames.close();
    client.close();
  });

  test('rejects non-event-stream responses for SSE endpoints', () async {
    MockClient mock() =>
        MockClient((request) async => jsonResponse({'nope': true}));
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: mock(),
      clientFactory: mock,
    );
    await expectLater(
      client.event.subscribe().drain<void>(),
      throwsA(isA<OpenCodeMalformedResponseException>()),
    );
    client.close();
  });
}
