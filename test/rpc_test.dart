import 'dart:async';
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
  group('RpcSubClient', () {
    test('posts inputs and decodes outputs', () async {
      late http.Request captured;
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          captured = request;
          return jsonResponse({
            'output': {'text': 'found'},
          });
        }),
      );
      final acme = client.rpc('acme');
      final result = await acme.call(
        'search',
        input: {'query': 'hello'},
        decode: (output) => asJsonMap(output)['text'],
      );
      expect(result, 'found');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/rpc/acme/search');
      expect(jsonDecode(captured.body), {
        'input': {'query': 'hello'},
      });
      client.close();
    });

    test('passes the location query parameter', () async {
      late http.Request captured;
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          captured = request;
          return jsonResponse({'output': null});
        }),
      );
      await client.rpc('acme').callJson(
            'search',
            input: {'query': 'x'},
            options: const RequestOptions(
              location: LocationRef.directory('/workspace'),
            ),
          );
      expect(captured.url.queryParameters['location[directory]'], '/workspace');
      client.close();
    });

    test('returns null when a method declares no output', () async {
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async => jsonResponse({})),
      );
      expect(await client.rpc('acme').callJson('noop'), isNull);
      client.close();
    });

    test('surfaces declared errors with type and data', () async {
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return jsonResponse({
            '_tag': 'RpcError',
            'type': 'not_found',
            'message': 'Result not found',
            'data': {'query': 'hello'},
          }, status: 400);
        }),
      );
      try {
        await client.rpc('acme').callJson('search', input: {'query': 'hello'});
        fail('expected an exception');
      } on RpcError catch (error) {
        expect(error.type, 'not_found');
        expect(error.data, {'query': 'hello'});
        expect(error.statusCode, 400);
      }
      client.close();
    });

    test('surfaces framework failures', () async {
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return jsonResponse({
            '_tag': 'RpcInternalError',
            'type': 'rpc.invalid_output',
            'message': 'bad output',
          }, status: 500);
        }),
      );
      expect(
        () => client.rpc('acme').callJson('search', input: {}),
        throwsA(isA<RpcInternalError>()),
      );
      client.close();
    });

    test('wraps decode failures with the method path', () async {
      final client = OpenCodeClient(
        baseUrl: Uri.parse('http://localhost:4096'),
        httpClient: MockClient((request) async {
          return jsonResponse({
            'output': <String, Object?>{},
          });
        }),
      );
      try {
        await client.rpc('acme').call<Object?>(
              'search',
              input: {},
              decode: (output) => asJsonMap(
                (output as Map<String, Object?>)['missing'],
              ),
            );
        fail('expected a decode error');
      } on OpenCodeDecodeException catch (error) {
        expect(error.path, contains('rpc.acme.search'));
      }
      client.close();
    });

    test('subscribes to prefixed events through the shared connection',
        () async {
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

      final received = <RpcEvent<String>>[];
      final subscription = client.rpc('acme').subscribe<String>(
            'updated',
            decode: (data) => asJsonMap(data)['text'] as String,
            onActivity: () {},
          );
      final listen = subscription.listen(received.add);

      frames
        ..add(utf8.encode('data: {"type": "server.connected"}\n\n'))
        ..add(utf8.encode(
          'data: {"type": "rpc.acme.updated", "data": {"text": "ready"}}\n\n',
        ))
        ..add(utf8.encode(
          'data: {"type": "rpc.other.updated", "data": {"text": "skip"}}\n\n',
        ));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(received.length, 1);
      expect(received.single.type, 'rpc.acme.updated');
      expect(received.single.name, 'updated');
      expect(received.single.data, 'ready');

      await listen.cancel();
      await frames.close();
      client.close();
    });

    test('on() awaits async listeners sequentially and unsubscribes', () async {
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

      final order = <String>[];
      final unsubscribe = client.rpc('acme').on<String>(
        'updated',
        (event) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          order.add(event.data);
        },
        decode: (data) => asJsonMap(data)['text'] as String,
      );
      frames
        ..add(utf8.encode(
          'data: {"type": "rpc.acme.updated", "data": {"text": "one"}}\n\n',
        ))
        ..add(utf8.encode(
          'data: {"type": "rpc.acme.updated", "data": {"text": "two"}}\n\n',
        ));
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(order, ['one', 'two']);
      unsubscribe();
      await frames.close();
      client.close();
    });
  });
}
