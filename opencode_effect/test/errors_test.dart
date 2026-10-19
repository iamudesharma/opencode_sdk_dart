import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('mapOpenCodeException', () {
    test('maps every known SDK exception to its typed variant', () {
      expect(
        mapOpenCodeException(
          OpenCodeStatusException(statusCode: 404, message: 'missing'),
        ),
        isA<OpenCodeApiError>(),
      );
      expect(
        mapOpenCodeException(OpenCodeTransportException(StateError('x'))),
        isA<OpenCodeTransportError>(),
      );
      expect(
        mapOpenCodeException(OpenCodeMalformedResponseException('bad')),
        isA<OpenCodeMalformedResponseError>(),
      );
      expect(
        mapOpenCodeException(OpenCodeDecodeException('bad', path: 'a.b')),
        isA<OpenCodeDecodeError>(),
      );
      expect(
        mapOpenCodeException(OpenCodeStreamException('gone')),
        isA<OpenCodeStreamError>(),
      );
      expect(
        mapOpenCodeException(OpenCodeCancelledException()),
        isA<OpenCodeCallCancelled>(),
      );
      expect(
        mapOpenCodeException(OpenCodeExecutionException('failed')),
        isA<OpenCodeExecutionFailed>(),
      );
    });

    test('returns null for foreign errors so they stay defects', () {
      expect(mapOpenCodeException(StateError('bug')), isNull);
      expect(mapOpenCodeException('not an error'), isNull);
    });

    test('preserves status code and tag on API errors', () {
      final exception = OpenCodeStatusException(
        statusCode: 503,
        message: 'warming up',
      )..attachStatusCode(503);
      final mapped = mapOpenCodeException(exception) as OpenCodeApiError;
      expect(mapped.statusCode, 503);
      expect(mapped.tag, 'UnexpectedStatus');
      expect(mapped.message, 'warming up');
      expect(mapped.isNotFound, isFalse);
    });

    test('decode errors keep their dotted path', () {
      final mapped = mapOpenCodeException(
        OpenCodeDecodeException('bad shape', path: 'data.items'),
      ) as OpenCodeDecodeError;
      expect(mapped.path, 'data.items');
      expect(mapped.toString(), contains('data.items'));
    });
  });

  group('isTransient', () {
    test('transport and stream failures are transient', () {
      expect(
        isTransient(OpenCodeTransportError(OpenCodeTransportException('x'))),
        isTrue,
      );
      expect(
        isTransient(OpenCodeStreamError(OpenCodeStreamException('x'))),
        isTrue,
      );
    });

    test('only the classic gateway statuses are transient', () {
      for (final status in transientStatusCodeSet) {
        final error = OpenCodeApiError(
          OpenCodeStatusException(statusCode: status, message: 'x')
            ..attachStatusCode(status),
        );
        expect(isTransient(error), isTrue, reason: 'status $status');
      }
      for (final status in [400, 401, 403, 404, 409, 422]) {
        final error = OpenCodeApiError(
          OpenCodeStatusException(statusCode: status, message: 'x')
            ..attachStatusCode(status),
        );
        expect(isTransient(error), isFalse, reason: 'status $status');
      }
    });

    test('execution and service failures are never retried implicitly', () {
      expect(
        isTransient(OpenCodeServiceError('cannot start service')),
        isFalse,
      );
      expect(
        isTransient(OpenCodeExecutionFailed(OpenCodeExecutionException('x'))),
        isFalse,
      );
    });
  });

  group('OpenCodeApiError predicates', () {
    OpenCodeApiError api(int status) => OpenCodeApiError(
      OpenCodeStatusException(statusCode: status, message: 'x')
        ..attachStatusCode(status),
    );

    test('classifies common server answers', () {
      expect(api(404).isNotFound, isTrue);
      expect(api(401).isUnauthorized, isTrue);
      expect(api(403).isUnauthorized, isTrue);
      expect(api(429).isThrottled, isTrue);
      expect(api(200).isNotFound, isFalse);
    });
  });
}
