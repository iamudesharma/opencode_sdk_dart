import 'dart:async';
import 'dart:convert';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:test/test.dart';

OpenCodeEvent event(String type, [Map<String, Object?>? data]) =>
    OpenCodeEvent.fromJson({
      'type': type,
      if (data != null) 'data': data,
    });

void main() {
  group('SSE frame decoding', () {
    test('decodes frames across chunk boundaries', () async {
      final controller = StreamController<List<int>>();
      final frames = decodeSseFrames(controller.stream).toList();
      controller.add(utf8.encode('data: {"type": "a"}\n\ndata: {"ty'));
      controller.add(utf8.encode('pe": "b"}\n\n'));
      await controller.close();
      expect(await frames, [
        {'type': 'a'},
        {'type': 'b'},
      ]);
    });

    test('normalizes CRLF line endings and joins multi-line data', () async {
      final controller = StreamController<List<int>>();
      final frames = decodeSseFrames(controller.stream).toList();
      controller
          .add(utf8.encode('event: x\r\ndata: {"a":\r\ndata: 1}\r\n\r\n'));
      await controller.close();
      expect(await frames, [
        {
          'a': 1,
        },
      ]);
    });

    test('flushes a trailing frame without a delimiter', () async {
      final controller = StreamController<List<int>>();
      final frames = decodeSseFrames(controller.stream).toList();
      controller.add(utf8.encode('data: {"done": true}'));
      await controller.close();
      expect(await frames, [
        {'done': true},
      ]);
    });

    test('rejects oversized frames', () async {
      final controller = StreamController<List<int>>();
      final frames = decodeSseFrames(controller.stream, byteLimit: 8).toList();
      final expectation =
          expectLater(frames, throwsA(isA<OpenCodeStreamException>()));
      controller.add(utf8.encode('data: {"long": "payload"}'));
      await controller.close();
      await expectation;
    });

    test('rejects invalid JSON payloads', () async {
      final controller = StreamController<List<int>>();
      final frames = decodeSseFrames(controller.stream).toList();
      final expectation = expectLater(
        frames,
        throwsA(isA<OpenCodeMalformedResponseException>()),
      );
      controller.add(utf8.encode('data: {nope}\n\n'));
      await controller.close();
      await expectation;
    });
  });

  group('EventMultiplexer', () {
    test('connects lazily and shares one connection', () async {
      var connects = 0;
      final controller = StreamController<OpenCodeEvent>();
      final multiplexer = EventMultiplexer((token, activity) {
        connects++;
        return controller.stream;
      });

      expect(connects, 0);
      final first = multiplexer.subscribe();
      final second = multiplexer.subscribe();
      future(() {
        controller.add(event('server.connected'));
        controller.add(event('session.updated', {'id': 'ses_1'}));
      });

      final collected = <OpenCodeEvent>[];
      final firstSubscription = first.listen(collected.add);
      final secondSubscription = second.listen(collected.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(connects, 1);
      expect(collected.where((e) => e.isServerConnected).length, 2);
      expect(collected.where((e) => e.type == 'session.updated').length, 2);

      await firstSubscription.cancel();
      await secondSubscription.cancel();
      await controller.close();
    });

    test('replays the connection marker to late subscribers', () async {
      final controller = StreamController<OpenCodeEvent>();
      final multiplexer =
          EventMultiplexer((token, activity) => controller.stream);
      final first = <OpenCodeEvent>[];
      final subscription = multiplexer.subscribe().listen(first.add);
      controller.add(event('server.connected'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final late = <OpenCodeEvent>[];
      final lateSubscription = multiplexer.subscribe().listen(late.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(first.single.isServerConnected, isTrue);
      expect(late.single.isServerConnected, isTrue);

      await subscription.cancel();
      await lateSubscription.cancel();
      await controller.close();
    });

    test('closing the last subscriber aborts the connection', () async {
      final controller = StreamController<OpenCodeEvent>();
      CancellationToken? connectionToken;
      final multiplexer = EventMultiplexer((token, activity) {
        connectionToken = token;
        return controller.stream;
      });
      final subscription = multiplexer.subscribe().listen((_) {});
      controller.add(event('server.connected'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(connectionToken!.isCancelled, isFalse);

      await subscription.cancel();
      expect(connectionToken!.isCancelled, isTrue);
      await controller.close();
    });

    test('source errors end current subscribers', () async {
      final controller = StreamController<OpenCodeEvent>();
      final multiplexer =
          EventMultiplexer((token, activity) => controller.stream);
      final errors = <Object>[];
      final subscription =
          multiplexer.subscribe().listen((_) {}, onError: errors.add);
      controller.addError(StateError('boom'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(errors.single, isA<StateError>());
      await subscription.cancel();
      await controller.close();
    });

    test('applies per-subscriber filters', () async {
      final controller = StreamController<OpenCodeEvent>();
      final multiplexer =
          EventMultiplexer((token, activity) => controller.stream);
      final filtered = <OpenCodeEvent>[];
      final subscription = multiplexer
          .subscribe(filter: (e) => e.type == 'wanted')
          .listen(filtered.add);
      controller
        ..add(event('server.connected'))
        ..add(event('ignored'))
        ..add(event('wanted'))
        ..add(event('ignored'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(filtered.map((e) => e.type), ['wanted']);
      await subscription.cancel();
      await controller.close();
    });

    test('enforces the subscriber capacity', () async {
      final controller = StreamController<OpenCodeEvent>();
      final multiplexer =
          EventMultiplexer((token, activity) => controller.stream);
      final errors = <Object>[];
      final done = Completer<void>();
      final subscription = multiplexer.subscribe().listen(
            (_) {},
            onError: errors.add,
            onDone: done.complete,
          );
      subscription.pause();
      for (var index = 0; index < 5000; index++) {
        controller.add(event('e$index'));
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      subscription.resume();
      await done.future;
      expect(errors.single, isA<OpenCodeStreamException>());
      await controller.close();
    });

    test('subscriptions after dispose fail', () async {
      final multiplexer = EventMultiplexer(
        (token, activity) => const Stream<OpenCodeEvent>.empty(),
      );
      multiplexer.dispose();
      await expectLater(
        multiplexer.subscribe().drain<void>(),
        throwsA(isA<OpenCodeStreamException>()),
      );
    });
  });
}

/// Schedules [action] as a microtask-friendly event.
void future(void Function() action) {
  scheduleMicrotask(action);
}
