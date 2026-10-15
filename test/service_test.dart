import 'dart:convert';
import 'dart:io';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceInfo', () {
    test('parses registrations written by the server', () {
      final info = ServiceInfo.parse({
        'id': 'abc',
        'version': '2.0.28',
        'url': 'http://127.0.0.1:49374',
        'pid': 42,
        'password': 'secret',
      });
      expect(info, isNotNull);
      expect(info!.url, 'http://127.0.0.1:49374');
      expect(info.pid, 42);
      expect(info.version, '2.0.28');
      expect(info.endpoint.url, Uri.parse('http://127.0.0.1:49374'));
    });

    test('rejects malformed registrations', () {
      expect(ServiceInfo.parse(null), isNull);
      expect(ServiceInfo.parse({'url': 'http://x', 'pid': 'nope'}), isNull);
      expect(ServiceInfo.parse({'pid': 1}), isNull);
    });
  });

  group('ServiceEndpoint', () {
    test('creates Basic authentication headers', () {
      final endpoint = ServiceEndpoint(
        url: Uri.parse('http://127.0.0.1:49374'),
        auth: const ServiceAuth(username: 'opencode', password: 'secret'),
      );
      expect(
        endpoint.headers()['authorization'],
        'Basic ${base64.encode(utf8.encode('opencode:secret'))}',
      );
      expect(OpenCodeService.headers(endpoint), endpoint.headers());
    });

    test('omits headers without credentials', () {
      final endpoint = ServiceEndpoint(url: Uri.parse('http://127.0.0.1'));
      expect(endpoint.headers(), isEmpty);
    });
  });

  group('version constraints', () {
    test('exact equality', () {
      const constraint = ServiceVersionConstraint.exact('2.0.28');
      expect(constraint.matches('2.0.28'), isTrue);
      expect(constraint.matches('2.0.27'), isFalse);
      expect(constraint.matches(null), isFalse);
    });

    test('predicates', () {
      final constraint = ServiceVersionConstraint.matches(
          (version) => version.startsWith('2.'));
      expect(constraint.matches('2.1.0'), isTrue);
      expect(constraint.matches('1.0.0'), isFalse);
      expect(constraint.matches(null), isFalse);
    });
  });

  group('discovery', () {
    late Directory directory;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('opencode-sdk-test');
    });

    tearDown(() {
      directory.deleteSync(recursive: true);
    });

    test('returns null without a registration file', () async {
      final file = '${directory.path}/missing/service.json';
      final endpoint = await OpenCodeService.discover(
        options: EnsureOptions(file: file),
      );
      expect(endpoint, isNull);
    });

    test('returns null when the registered service is unreachable', () async {
      final file = '${directory.path}/service.json';
      File(file).writeAsStringSync(jsonEncode({
        'id': 'stale',
        'version': '2.0.28',
        'url': 'http://127.0.0.1:1',
        'pid': 999999,
      }));
      final endpoint = await OpenCodeService.discover(
        options: EnsureOptions(
          file: file,
          requestTimeout: const Duration(milliseconds: 250),
        ),
      );
      expect(endpoint, isNull);
    });

    test('stop() is a no-op without a registration', () async {
      final file = '${directory.path}/service.json';
      await OpenCodeService.stop(options: EnsureOptions(file: file));
    });

    test('defaultFile points at the standard registration path', () {
      expect(OpenCodeService.defaultFile(), endsWith('service.json'));
    });
  });
}
