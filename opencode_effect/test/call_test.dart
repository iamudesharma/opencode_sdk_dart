import 'dart:async';

import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

import 'support/fake_server.dart';

void main() {
  group('openCodeCall', () {
    test('runs the closure per run and yields the value', () async {
      var runs = 0;
      final effect = openCodeCall<int, Unit>((_) async => ++runs);
      final runtime = Runtime<Unit>(Unit.value);
      expect(await runtime.runFuture(effect), 1);
      expect(await runtime.runFuture(effect), 2);
    });

    test('maps SDK API errors into OpenCodeApiError', () async {
      final runtime = Runtime<Unit>(Unit.value);
      final effect = openCodeCall<void, Unit>(
        (_) async =>
            throw OpenCodeStatusException(statusCode: 409, message: 'busy')
              ..attachStatusCode(409),
      );
      final exit = await runtime.runExit(effect);
      final error = exit.expectedError;
      expect(error, isA<OpenCodeApiError>());
      expect((error! as OpenCodeApiError).statusCode, 409);
    });

    test('keeps foreign errors as defects', () async {
      final runtime = Runtime<Unit>(Unit.value);
      final effect = openCodeCall<void, Unit>(
        (_) async => throw StateError('bug'),
      );
      final exit = await runtime.runExit(effect);
      expect(exit, isA<Failure<void, OpenCodeError>>());
      final cause = (exit as Failure<void, OpenCodeError>).cause;
      expect(cause, isA<Defect<OpenCodeError>>());
      expect((cause as Defect<OpenCodeError>).error, isA<StateError>());
      expect(exit.expectedError, isNull);
    });

    test('interruption cancels the SDK token and yields Interrupted', () async {
      RequestOptions? seen;
      final effect = openCodeCall<int, Unit>((options) async {
        seen = options;
        await options.cancelToken!.whenCancelled;
        throw OpenCodeCancelledException();
      });
      final runtime = Runtime<Unit>(Unit.value);
      final fiber = runtime.fork(effect);
      while (seen == null) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(seen!.cancelToken!.isCancelled, isFalse);
      fiber.interrupt();
      final exit = await fiber.awaitExit();
      expect(seen!.cancelToken!.isCancelled, isTrue);
      expect(exit, isA<Failure<int, OpenCodeError>>());
      expect(
        (exit as Failure<int, OpenCodeError>).cause,
        isA<Interrupted<OpenCodeError>>(),
      );
    });

    test('forwards location and headers into RequestOptions', () async {
      RequestOptions? seen;
      final runtime = Runtime<Unit>(Unit.value);
      final effect = openCodeCall<int, Unit>(
        (options) {
          seen = options;
          return Future.value(7);
        },
        base: const RequestOptions(
          location: LocationRef.directory('/workspace'),
          headers: {'x-extra': 'yes'},
        ),
      );
      expect(await runtime.runFuture(effect), 7);
      expect(seen!.location!.directory, '/workspace');
      expect(seen!.headers!['x-extra'], 'yes');
      expect(seen!.cancelToken, isNotNull);
    });
  });

  group('openCodeTask', () {
    test('runs and maps errors like calls', () async {
      final runtime = Runtime<Unit>(Unit.value);
      expect(
        await runtime.runFuture(openCodeTask<int, Unit>(() async => 3)),
        3,
      );
    });

    test('invokes onCancel before reporting Interrupted', () async {
      var cancelled = false;
      final gate = Completer<void>();
      final effect = openCodeTask<int, Unit>(
        () async {
          await gate.future;
          return 1;
        },
        onCancel: () {
          cancelled = true;
          gate.complete();
        },
      );
      final runtime = Runtime<Unit>(Unit.value);
      final fiber = runtime.fork(effect);
      await Future<void>.delayed(Duration.zero);
      fiber.interrupt();
      final exit = await fiber.awaitExit();
      expect(cancelled, isTrue);
      expect(
        (exit as Failure<int, OpenCodeError>).cause,
        isA<Interrupted<OpenCodeError>>(),
      );
    });
  });

  group('withReadRetry', () {
    test('retries a transient API failure and then succeeds', () async {
      final server = FakeOpenCodeServer()..infoFailures = 1;
      final client = EffectOpenCodeClient(sdkClientFor(server));
      final Effect<ServerInfo, OpenCodeError, Unit> effect = client
          .call<ServerInfo, Unit>(
            (options) => client.sdk.server.info(options: options),
          )
          .withReadRetry(Schedule(recurrences: 2, initialDelay: Duration.zero));
      final runtime = Runtime<Unit>(Unit.value);
      final exit = await runtime.runExit(effect);
      expect(server.infoCalls, 2);
      expect(exit, isA<Success<ServerInfo, OpenCodeError>>());
    });

    test('does not retry non-transient failures', () async {
      final server = FakeOpenCodeServer();
      final client = EffectOpenCodeClient(sdkClientFor(server));
      final Effect<SessionInfo, OpenCodeError, Unit> effect = client
          .call<SessionInfo, Unit>(
            (options) => client.sdk.session.get(
              sessionID: SessionID('ses_1'),
              options: options,
            ),
          )
          .withReadRetry(Schedule(recurrences: 3, initialDelay: Duration.zero));
      final runtime = Runtime<Unit>(Unit.value);
      final exit = await runtime.runExit(effect);
      expect(server.sessionGetCalls, 1);
      final error = exit.expectedError;
      expect(error, isA<OpenCodeApiError>());
      final api = error! as OpenCodeApiError;
      expect(api.statusCode, 404);
      expect(api.tag, 'SessionNotFoundError');
      expect(api.cause, isA<SessionNotFoundError>());
    });

    test('retries transport failures', () async {
      var calls = 0;
      final effect = openCodeCall<int, Unit>((_) {
        calls++;
        if (calls == 1) {
          return Future.error(OpenCodeTransportException(StateError('down')));
        }
        return Future.value(1);
      }).withReadRetry(Schedule(recurrences: 1, initialDelay: Duration.zero));
      final runtime = Runtime<Unit>(Unit.value);
      expect(await runtime.runFuture(effect), 1);
      expect(calls, 2);
    });

    test('client.read infers in argument position and retries', () async {
      final server = FakeOpenCodeServer()..infoFailures = 1;
      final client = EffectOpenCodeClient(sdkClientFor(server));
      final runtime = Runtime<Unit>(Unit.value);
      // No explicit type arguments: `read` must stay inferable from the
      // surrounding `runOpenCode(...)` argument context.
      final info = await runtime.runOpenCode(
        client.read(
          (options) => client.sdk.server.info(options: options),
          schedule: Schedule(recurrences: 2, initialDelay: Duration.zero),
        ),
      );
      expect(info.version, '1.2.3');
      expect(server.infoCalls, 2);
    });

    test('client.call infers in argument position', () async {
      final server = FakeOpenCodeServer();
      final client = EffectOpenCodeClient(sdkClientFor(server));
      final runtime = Runtime<Unit>(Unit.value);
      final info = await runtime.runOpenCode(
        client.call((options) => client.sdk.server.info(options: options)),
      );
      expect(info.version, '1.2.3');
    });

    test('releases a result produced just before interruption', () async {
      var started = false;
      final gate = Completer<int>();
      Object? released;
      final effect = openCodeCall<int, Unit>((_) {
        started = true;
        return gate.future;
      }, onInterruptedResult: (value) => released = value);
      final runtime = Runtime<Unit>(Unit.value);
      final fiber = runtime.fork(effect);
      while (!started) {
        await Future<void>.delayed(Duration.zero);
      }
      fiber.interrupt();
      gate.complete(7);
      final exit = await fiber.awaitExit();
      expect(released, 7);
      expect(
        (exit as Failure<int, OpenCodeError>).cause,
        isA<Interrupted<OpenCodeError>>(),
      );
    });
  });

  group('abortability', () {
    test('default calls carry a per-run cancellation token', () async {
      RequestOptions? seen;
      final runtime = Runtime<Unit>(Unit.value);
      await runtime.runFuture(
        openCodeCall<int, Unit>((options) {
          seen = options;
          return Future.value(1);
        }),
      );
      expect(seen!.cancelToken, isNotNull);
    });

    test('abortable: false uses the pooled path (no token)', () async {
      RequestOptions? seen;
      final runtime = Runtime<Unit>(Unit.value);
      await runtime.runFuture(
        openCodeCall<int, Unit>((options) {
          seen = options;
          return Future.value(1);
        }, abortable: false),
      );
      expect(seen!.cancelToken, isNull);
    });

    test('abortable: false interruption stops waiting', () async {
      var started = false;
      final gate = Completer<int>();
      Object? released;
      final effect = openCodeCall<int, Unit>(
        (_) {
          started = true;
          return gate.future;
        },
        abortable: false,
        onInterruptedResult: (value) => released = value,
      );
      final runtime = Runtime<Unit>(Unit.value);
      final fiber = runtime.fork(effect);
      while (!started) {
        await Future<void>.delayed(Duration.zero);
      }
      fiber.interrupt();
      gate.complete(9);
      final exit = await fiber.awaitExit();
      expect(released, 9);
      expect(
        (exit as Failure<int, OpenCodeError>).cause,
        isA<Interrupted<OpenCodeError>>(),
      );
    });

    test('reads stay retryable when not abortable', () async {
      final server = FakeOpenCodeServer()..infoFailures = 1;
      final client = EffectOpenCodeClient(sdkClientFor(server));
      final runtime = Runtime<Unit>(Unit.value);
      final info = await runtime.runOpenCode(
        client.read(
          (options) => client.sdk.server.info(options: options),
          abortable: false,
          schedule: Schedule(recurrences: 2, initialDelay: Duration.zero),
        ),
      );
      expect(info.version, '1.2.3');
      expect(server.infoCalls, 2);
    });
  });

  group('EffectOpenCodeClient.make', () {
    test('forwards clientFactory for cancellable requests', () async {
      final server = FakeOpenCodeServer();
      var created = 0;
      final client = EffectOpenCodeClient.make(
        baseUrl: Uri.parse('http://fake.opencode'),
        httpClient: server.client,
        clientFactory: () {
          created++;
          return server.client;
        },
      );
      final runtime = Runtime<Unit>(Unit.value);
      final info = await runtime.runOpenCode(
        client.call((options) => client.sdk.server.info(options: options)),
      );
      expect(info.version, '1.2.3');
      expect(created, greaterThan(0));
    });
  });

  group('runOpenCode', () {
    test('returns values and throws typed errors', () async {
      final runtime = Runtime<Unit>(Unit.value);
      expect(
        await runtime.runOpenCode(openCodeCall<int, Unit>((_) async => 5)),
        5,
      );
      await expectLater(
        runtime.runOpenCode(
          openCodeCall<void, Unit>(
            (_) async =>
                throw OpenCodeStatusException(statusCode: 400, message: 'bad')
                  ..attachStatusCode(400),
          ),
        ),
        throwsA(isA<OpenCodeApiError>()),
      );
    });
  });
}
