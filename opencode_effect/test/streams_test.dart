import 'dart:async';

import 'package:opencode_effect/src/streams.dart';
import 'package:test/test.dart';

void main() {
  test('delivers a burst that ends while the consumer is paused', () async {
    final source = StreamController<int>();
    final wrapped = losslessBuffered(source.stream);

    final iterator = StreamIterator<int>(wrapped);
    final first = iterator.moveNext();
    source.add(1);
    source.add(2);
    await source.close();

    expect(await first, isTrue);
    final got = <int>[iterator.current];
    while (await iterator.moveNext()) {
      got.add(iterator.current);
    }
    expect(got, [1, 2]);
  });

  test('reports a terminal error after draining queued values', () async {
    final source = StreamController<int>();
    final wrapped = losslessBuffered(source.stream);

    final iterator = StreamIterator<int>(wrapped);
    final first = iterator.moveNext();
    source.add(1);
    source.addError(StateError('boom'));
    await source.close();

    expect(await first, isTrue);
    expect(iterator.current, 1);
    await expectLater(iterator.moveNext(), throwsStateError);
  });

  test('applies backpressure instead of dropping when full', () async {
    final source = StreamController<int>();
    final wrapped = losslessBuffered(source.stream, capacity: 2);

    final got = <int>[];
    final done = Completer<void>();
    // A plain listener never pauses; count what arrives.
    final subscription = wrapped.listen(got.add, onDone: done.complete);
    for (var i = 0; i < 5; i++) {
      source.add(i);
    }
    await source.close();
    await done.future;
    await subscription.cancel();
    expect(got, [0, 1, 2, 3, 4]);
  });
}
