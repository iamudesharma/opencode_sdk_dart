import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

http.Response jsonResponse(Object? body, {int status = 200}) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  group('URL resolution', () {
    test('normalizes the base URL and resolves relative paths', () {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
      );
      expect(
        transport.resolve('/api/info').toString(),
        'http://localhost:4096/api/info',
      );
      expect(
        transport.resolve('api/session').toString(),
        'http://localhost:4096/api/session',
      );
    });

    test('keeps a base path prefix', () {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://host:1234/prefix'),
      );
      expect(
        transport.resolve('/api/info').toString(),
        'http://host:1234/prefix/api/info',
      );
    });

    test('encodes nested and repeated query parameters', () {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
      );
      final uri = transport.resolve('/api/session', {
        'limit': '10',
        'order': 'desc',
        'location[directory]': '/work space',
        'ids': ['a', 'b'],
        'missing': null,
      });
      expect(
        uri.query,
        'limit=10&order=desc&location%5Bdirectory%5D=%2Fwork+space&ids=a&ids=b',
      );
    });
  });

  group('requests', () {
    test('decode JSON bodies and send default headers', () async {
      late http.Request captured;
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        headers: {'authorization': 'Basic abc'},
        httpClient: MockClient((request) async {
          captured = request;
          return jsonResponse({'ok': true});
        }),
      );
      final result = await transport.jsonRequest(
        method: 'GET',
        path: '/api/info',
      );
      expect(captured.headers['authorization'], 'Basic abc');
      expect(result, {'ok': true});
    });

    test('send JSON bodies with a content type', () async {
      late http.Request captured;
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          captured = request;
          return jsonResponse({'data': 1});
        }),
      );
      await transport.jsonRequest(
        method: 'POST',
        path: '/api/session',
        body: {'title': 'x'},
      );
      expect(captured.method, 'POST');
      expect(captured.headers['content-type'], startsWith('application/json'));
      expect(jsonDecode(captured.body), {'title': 'x'});
    });

    test('return null for empty (204) responses', () async {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return http.Response('', 204);
        }),
      );
      final result = await transport.jsonRequest(
        method: 'DELETE',
        path: '/api/session/x',
        successStatus: 204,
        empty: true,
      );
      expect(result, isNull);
    });

    test('decode structured errors and attach the status code', () async {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return jsonResponse({
            '_tag': 'SessionNotFoundError',
            'message': 'gone',
            'sessionID': 'ses_1',
          }, status: 404);
        }),
      );
      transport.exceptionDecoder = decodeOpenCodeException;
      try {
        await transport.jsonRequest(method: 'GET', path: '/api/session/ses_1');
        fail('expected an exception');
      } on SessionNotFoundError catch (error) {
        expect(error.message, 'gone');
        expect(error.statusCode, 404);
      }
    });

    test('fall back to a status exception for unknown bodies', () async {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return http.Response('boom', 500, headers: {
            'content-type': 'text/plain',
          });
        }),
      );
      transport.exceptionDecoder = decodeOpenCodeException;
      try {
        await transport.jsonRequest(method: 'GET', path: '/api/info');
        fail('expected an exception');
      } on OpenCodeStatusException catch (error) {
        expect(error.httpStatus, 500);
        expect(error.statusCode, 500);
      }
    });

    test('reject malformed bodies', () async {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return http.Response('{not json', 200, headers: {
            'content-type': 'application/json',
          });
        }),
      );
      expect(
        () => transport.jsonRequest(method: 'GET', path: '/api/info'),
        throwsA(isA<OpenCodeMalformedResponseException>()),
      );
    });

    test('return raw bytes for binary responses', () async {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return http.Response.bytes([1, 2, 3], 200,
              headers: {
                'content-type': 'application/octet-stream',
              });
        }),
      );
      final bytes = await transport.bytesRequest(
        method: 'GET',
        path: '/api/fs/read/a.txt',
      );
      expect(bytes, [1, 2, 3]);
    });

    test('send binary request bodies', () async {
      late http.Request captured;
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          captured = request;
          return jsonResponse({'ok': true});
        }),
      );
      await transport.jsonRequest(
        method: 'POST',
        path: '/api/experimental/fs/write',
        body: [104, 105],
        binaryBody: true,
      );
      expect(captured.headers['content-type'], 'application/octet-stream');
      expect(captured.bodyBytes, [104, 105]);
    });
  });

  group('PTY frames', () {
    test('splits terminal output from cursor markers', () {
      expect(PtyFrame.parse(r'hello\r\n'), isA<PtyOutput>());
      expect(
        (PtyFrame.parse(r'hello') as PtyOutput).data,
        'hello',
      );
      final cursor = PtyFrame.parse(utf8.encode('{"cursor":64}'));
      expect(cursor, isA<PtyCursor>());
      expect((cursor as PtyCursor).cursor, 64);
      // Binary frames that are not cursor JSON decode as output.
      final binary = PtyFrame.parse(utf8.encode('plain bytes'));
      expect(binary, isA<PtyOutput>());
      expect((binary as PtyOutput).data, 'plain bytes');
    });
  });

  group('PTY input protocol', () {
    test('frames input with a 5-byte header', () {
      final frames = PtyInputFrames(cols: 120, rows: 30);
      final frame = frames.input('hi');
      expect(frame.sublist(0, 5), [1, 0, 120, 0, 30]);
      expect(utf8.decode(frame.sublist(5)), 'hi');
    });

    test('frames resize as control frames', () {
      final frames = PtyInputFrames();
      final frame = frames.resize(cols: 100, rows: 40);
      expect(frame, [0, 0, 100, 0, 40]);
      expect(frames.cols, 100);
      expect(frames.rows, 40);
    });
  });

  group('cancellation', () {
    test('cancelled requests throw OpenCodeCancelledException', () async {
      MockClient buildClient() => MockClient((request) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return jsonResponse({'ok': true});
          });
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: buildClient(),
        clientFactory: buildClient,
      );
      final token = CancellationToken();
      final pending = transport.jsonRequest(
        method: 'GET',
        path: '/api/info',
        options: RequestOptions(cancelToken: token),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      token.cancel();
      await expectLater(pending, throwsA(isA<OpenCodeCancelledException>()));
    });

    test('pre-cancelled tokens fail immediately', () async {
      final transport = OpenCodeTransport(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async => jsonResponse({})),
      );
      final token = CancellationToken()..cancel();
      expect(
        () => transport.jsonRequest(
          method: 'GET',
          path: '/api/info',
          options: RequestOptions(cancelToken: token),
        ),
        throwsA(isA<OpenCodeCancelledException>()),
      );
    });
  });
}
