import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  test('retries idempotent requests on transient statuses', () async {
    var calls = 0;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        calls++;
        if (calls == 1) {
          return http.Response(
            'temporarily unavailable',
            503,
            headers: {'content-type': 'text/plain', 'retry-after': '0'},
          );
        }
        return jsonResponse({'data': sessionPayload()});
      }),
    );
    client.transport.retry = const RetryPolicy(initialDelay: Duration.zero);

    final session = await client.session.get(sessionID: SessionID('ses_1'));
    expect(session.id, 'ses_1');
    expect(calls, 2);
    client.close();
  });

  test('does not retry writes by default', () async {
    var calls = 0;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        calls++;
        return http.Response(
          'temporarily unavailable',
          503,
          headers: {'content-type': 'text/plain'},
        );
      }),
    );
    client.transport.retry = const RetryPolicy(initialDelay: Duration.zero);

    await expectLater(
      client.session.prompt(sessionID: SessionID('ses_1'), text: 'hi'),
      throwsA(isA<OpenCodeApiException>()),
    );
    expect(calls, 1);
    client.close();
  });

  test('retries writes when retryNonIdempotent is set', () async {
    var calls = 0;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        calls++;
        if (calls == 1) {
          return http.Response(
            'busy',
            503,
            headers: {'content-type': 'text/plain'},
          );
        }
        return jsonResponse({'data': inboxUserPayload()});
      }),
    );
    client.transport.retry = const RetryPolicy(
      initialDelay: Duration.zero,
      retryNonIdempotent: true,
    );

    await client.session.prompt(sessionID: SessionID('ses_1'), text: 'hi');
    expect(calls, 2);
    client.close();
  });

  test('gives up after maxAttempts', () async {
    var calls = 0;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        calls++;
        return http.Response(
          'nope',
          503,
          headers: {'content-type': 'text/plain'},
        );
      }),
    );
    client.transport.retry = const RetryPolicy(
      maxAttempts: 3,
      initialDelay: Duration.zero,
    );

    await expectLater(
      client.session.get(sessionID: SessionID('ses_1')),
      throwsA(isA<OpenCodeApiException>()),
    );
    expect(calls, 3);
    client.close();
  });

  test('per-request policies override the transport policy', () async {
    var calls = 0;
    final client = OpenCodeClient(
      baseUrl: Uri.parse('http://localhost:4096'),
      httpClient: MockClient((request) async {
        calls++;
        return http.Response(
          'nope',
          503,
          headers: {'content-type': 'text/plain'},
        );
      }),
    );
    client.transport.retry = const RetryPolicy(
      maxAttempts: 4,
      initialDelay: Duration.zero,
    );

    await expectLater(
      client.session.get(
        sessionID: SessionID('ses_1'),
        options: const RequestOptions(
          retry: RetryPolicy(maxAttempts: 2, initialDelay: Duration.zero),
        ),
      ),
      throwsA(isA<OpenCodeApiException>()),
    );
    expect(calls, 2);
    client.close();
  });
}
