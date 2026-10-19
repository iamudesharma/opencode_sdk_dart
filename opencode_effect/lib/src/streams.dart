/// Native-stream adapter that preserves buffered events on close.
library;

import 'dart:async';
import 'dart:collection';

/// Wraps [source] so events the source already delivered are never dropped
/// when it closes while the consumer is paused.
///
/// The SDK's shared event subscriber queues events that arrive while its
/// consumer is paused, and drops that queue when the source ends. Pull
/// consumers (like the one behind `EffectStream.fromNative`) pause between
/// pulls, so a source that bursts and then closes could lose its last events.
/// This adapter keeps its own bounded queue, applies backpressure to the
/// source when full, and always drains the queue before closing or reporting
/// the terminal error.
Stream<A> losslessBuffered<A>(Stream<A> source, {int capacity = 4096}) {
  late StreamController<A> controller;
  StreamSubscription<A>? subscription;
  final queue = Queue<A>();
  var sourcePaused = false;
  var done = false;
  var cancelled = false;
  Object? error;
  StackTrace? errorStack;

  void flush() {
    if (cancelled || controller.isClosed) return;
    while (!controller.isPaused && queue.isNotEmpty) {
      controller.add(queue.removeFirst());
    }
    if (sourcePaused && queue.length < capacity) {
      sourcePaused = false;
      subscription?.resume();
    }
    if (done && queue.isEmpty && !controller.isPaused) {
      if (error != null) {
        controller.addError(error!, errorStack);
      }
      unawaited(controller.close());
    }
  }

  controller = StreamController<A>(
    onListen: () {
      subscription = source.listen(
        (value) {
          if (cancelled) return;
          queue.add(value);
          if (queue.length >= capacity && !sourcePaused) {
            sourcePaused = true;
            subscription!.pause();
          }
          flush();
        },
        onError: (Object object, StackTrace stackTrace) {
          error = object;
          errorStack = stackTrace;
          flush();
        },
        onDone: () {
          done = true;
          flush();
        },
        cancelOnError: false,
      );
    },
    onResume: flush,
    onCancel: () async {
      cancelled = true;
      await subscription?.cancel();
      queue.clear();
    },
  );
  return controller.stream;
}
