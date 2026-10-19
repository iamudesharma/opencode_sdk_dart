import 'dart:async';

import 'package:effect_core/effect_core.dart';
import 'package:http/testing.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

import 'support/fake_server.dart';

void main() {
  late Runtime<Unit> runtime;

  setUp(() => runtime = Runtime<Unit>(Unit.value));

  group('events', () {
    test('consumes the shared event stream as a pull stream', () async {
      final server = FakeOpenCodeServer()..eventFrames.add(textDelta('Hi'));
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final events = await runtime.runFuture(
        client.events<Unit>().runCollect(),
      );
      final types = events.map((event) => event.type).toList();
      expect(types, contains('server.connected'));
      expect(types, contains('session.text.delta'));
    });

    test('bridge to native streams delivers events and cancels', () async {
      final server = FakeOpenCodeServer()..eventFrames.add(textDelta('Hi'));
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final received = <OpenCodeEvent>[];
      final done = Completer<void>();
      final subscription = client
          .events<Unit>()
          .toNative(runtime)
          .listen(
            (event) {
              received.add(event);
              if (event.type == 'session.text.delta' && !done.isCompleted) {
                done.complete();
              }
            },
            onDone: () {
              if (!done.isCompleted) done.complete();
            },
          );
      await done.future;
      await subscription.cancel();
      expect(
        received.map((event) => event.type),
        contains('session.text.delta'),
      );
    });

    test('maps a failed connection to OpenCodeApiError', () async {
      final failing = MockClient.streaming((request, bodyStream) async {
        await bodyStream.toBytes();
        return jsonStream({
          'error': {'message': 'broken'},
        }, status: 500);
      });
      final client = EffectOpenCodeClient(
        OpenCodeClient(
          baseUrl: Uri.parse('http://fake.opencode'),
          httpClient: failing,
          clientFactory: () => failing,
        ),
      );

      final exit = await runtime.runExit(
        client.events<Unit>().take(1).runCollect(),
      );
      final error = exit.expectedError;
      expect(error, isA<OpenCodeApiError>());
      expect((error! as OpenCodeApiError).statusCode, 500);
    });
  });

  group('runTurn', () {
    test('streams deltas and resolves the reconciled result', () async {
      final server = FakeOpenCodeServer()
        ..eventFrames.addAll([
          textDelta('Hello'),
          textDelta(' world'),
          executionSucceeded(),
        ])
        ..assistantText = 'Hello world';
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final seen = <SessionTurnEvent>[];
      final result = await runtime.runFuture(
        client.runTurn<Unit>(
          sessionID: SessionID('ses_1'),
          text: 'Hi',
          onEvent: seen.add,
        ),
      );

      expect(result.text, 'Hello world');
      expect(server.promptCalls, 1);
      expect(seen.whereType<SessionTurnTextDelta>().length, 2);
      expect(seen.last, isA<SessionTurnCompleted>());
    });

    test('maps a failed execution to OpenCodeApiError', () async {
      final server = FakeOpenCodeServer()..failPrompt = true;
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final exit = await runtime.runExit(
        client.runTurn<Unit>(sessionID: SessionID('ses_1'), text: 'Hi'),
      );
      final error = exit.expectedError;
      expect(error, isA<OpenCodeApiError>());
      expect((error! as OpenCodeApiError).statusCode, 409);
    });

    test('interruption stops waiting; the prompt stays single-shot', () async {
      final server = FakeOpenCodeServer()
        ..assistantCompleted = false
        ..blockMessages = Completer<void>();
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final fiber = runtime.fork(
        client.runTurn<Unit>(sessionID: SessionID('ses_1'), text: 'Hi'),
      );
      while (server.promptCalls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      await Future<void>.delayed(Duration.zero);
      fiber.interrupt();
      final exit = await fiber.awaitExit();
      expect(
        (exit as Failure<SessionTurnResult, OpenCodeError>).cause,
        isA<Interrupted<OpenCodeError>>(),
      );
      expect(server.promptCalls, 1);

      // Release the scripted server so the orphaned turn can finish its
      // internal cleanup without surfacing an unhandled error.
      server.blockMessages!.complete();
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('turnStream', () {
    test('ends with SessionTurnCompleted', () async {
      final server = FakeOpenCodeServer()
        ..eventFrames.addAll([textDelta('Hello'), executionSucceeded()])
        ..assistantText = 'Hello';
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final events = await runtime.runFuture(
        client
            .turnStream<Unit>(sessionID: SessionID('ses_1'), text: 'Hi')
            .runCollect(),
      );
      expect(events.last, isA<SessionTurnCompleted>());
      expect((events.last as SessionTurnCompleted).result.text, 'Hello');
    });

    test('fails with the turn error when the prompt fails', () async {
      final server = FakeOpenCodeServer()..failPrompt = true;
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final exit = await runtime.runExit(
        client
            .turnStream<Unit>(sessionID: SessionID('ses_1'), text: 'Hi')
            .runDrain(),
      );
      final error = exit.expectedError;
      expect(error, isA<OpenCodeApiError>());
      expect((error! as OpenCodeApiError).statusCode, 409);
    });
  });

  group('rpc', () {
    test('calls a plugin method and decodes its output', () async {
      final server = FakeOpenCodeServer();
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final result = await runtime.runFuture(
        client.rpcCall<String, Unit>(
          'acme',
          'search',
          input: {'query': 'x'},
          decode: (output) => asJsonMap(output)['text']! as String,
        ),
      );
      expect(result, 'hello');
    });

    test('subscribes to plugin events', () async {
      final server = FakeOpenCodeServer()
        ..eventFrames.add({
          'type': 'rpc.acme.ping',
          'data': {'text': 'pong'},
        });
      final client = EffectOpenCodeClient(sdkClientFor(server));

      final events = await runtime.runFuture(
        client
            .rpcEvents<String, Unit>(
              'acme',
              'ping',
              decode: (data) => asJsonMap(data)['text']! as String,
            )
            .take(1)
            .runCollect(),
      );
      expect(events.single.data, 'pong');
      expect(events.single.name, 'ping');
    });
  });
}
