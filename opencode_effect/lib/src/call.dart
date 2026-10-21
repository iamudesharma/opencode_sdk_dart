/// Interruptible adapters that turn SDK work into typed effects.
///
/// [openCodeCall] wraps any generated resource method: it accepts the method's
/// `RequestOptions` and derives a fresh, effect-owned SDK cancellation token
/// per run, so interrupting the fiber aborts the in-flight HTTP request.
///
/// [openCodeTask] wraps everything else (local service management, PTY
/// handshakes, raw SDK futures) with the same error mapping and interrupt
/// hook support.
library;

import 'dart:async';

import 'package:effect_core/effect_core.dart' hide CancellationToken;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'errors.dart';

/// Runs one SDK call as an effect.
///
/// By default each run creates a fresh SDK [CancellationToken]; interrupting
/// the running fiber cancels it, which aborts the underlying HTTP request. The
/// token is never shared between runs, so a retried call (see
/// [OpenCodeReadRetry]) always starts cleanly.
///
/// Set [abortable] to `false` for hot request/response loops that prefer the
/// SDK's pooled shared client over per-call abortability: the SDK then opens
/// no dedicated client/connection per call, but interrupting the fiber only
/// stops waiting — the request runs to completion and its result is discarded.
/// Writes, streams and long operations should stay abortable.
///
/// [invoke] receives the [RequestOptions] the run must use. Always forward
/// them to the SDK method:
///
/// ```dart
/// openCodeCall((options) => client.sdk.agent.list(options: options));
/// ```
///
/// [base] contributes the location and extra headers of every run. The SDK's
/// own transport retry is deliberately left unset: retries belong in the
/// effect ([retry]) so they compose with interruption, metrics and tests.
///
/// [onInterruptedResult] releases a value produced in the instant before an
/// interrupt (for example a just-opened socket) so acquisitions cannot leak.
Effect<A, OpenCodeError, R> openCodeCall<A, R>(
  Future<A> Function(RequestOptions options) invoke, {
  RequestOptions? base,
  bool abortable = true,
  FutureOr<void> Function(A value)? onInterruptedResult,
}) => Effect.asyncExit<A, OpenCodeError, R>((context) async {
  final sdkToken = abortable ? CancellationToken() : null;
  final detach = sdkToken == null
      ? null
      : context.token.onCancel(sdkToken.cancel);
  final options = RequestOptions(
    location: base?.location,
    headers: base?.headers,
    cancelToken: sdkToken,
  );
  try {
    return await _evaluate(() => invoke(options), context, onInterruptedResult);
  } finally {
    detach?.call();
  }
});

/// Runs one asynchronous SDK operation as an effect.
///
/// Use this for work that does not take [RequestOptions]: local service
/// management, PTY connect handshakes, or any raw SDK future. [onCancel]
/// receives a chance to abort the operation when the fiber is interrupted
/// (for example cancelling a socket or a token owned by the operation).
Effect<A, OpenCodeError, R> openCodeTask<A, R>(
  Future<A> Function() run, {
  FutureOr<void> Function()? onCancel,
}) => Effect.asyncExit<A, OpenCodeError, R>((context) {
  void Function()? detach;
  if (onCancel != null) {
    detach = context.token.onCancel(() {
      final cleanup = onCancel();
      if (cleanup is Future<void>) {
        unawaited(cleanup);
      }
    });
  }
  return _evaluate(run, context).whenComplete(() => detach?.call());
});

Future<Exit<A, OpenCodeError>> _evaluate<A, R>(
  Future<A> Function() run,
  FiberContext<R> context, [
  FutureOr<void> Function(A value)? onInterruptedResult,
]) async {
  try {
    final value = await run();
    if (context.token.isCancelled) {
      if (onInterruptedResult != null) {
        try {
          await onInterruptedResult(value);
        } on Object catch (error, stackTrace) {
          return Failure(
            Sequential(const Interrupted(), Defect(error, stackTrace)),
          );
        }
      }
      return const Failure(Interrupted());
    }
    return Success(value);
  } on OpenCodeCancelledException catch (error) {
    if (context.token.isCancelled) return const Failure(Interrupted());
    return Failure(Expected(OpenCodeCallCancelled(error)));
  } on Object catch (error, stackTrace) {
    final mapped = mapOpenCodeException(error);
    if (mapped != null) return Failure(Expected(mapped));
    return Failure(Defect(error, stackTrace));
  }
}

/// The default retry schedule for read operations.
///
/// Mirrors the SDK's `RetryPolicy()` defaults: three attempts total (two
/// recurrences), 250 ms initial backoff, doubling, capped at five seconds.
final Schedule standardReadRetry = Schedule(
  recurrences: 2,
  initialDelay: const Duration(milliseconds: 250),
  factor: 2,
  maxDelay: const Duration(seconds: 5),
);

/// Retry composition for OpenCode effects.
extension OpenCodeReadRetry<A, R> on Effect<A, OpenCodeError, R> {
  /// Retries this effect on transient failures with [schedule] (defaults to
  /// [standardReadRetry]) when it represents a *read*.
  ///
  /// The SDK exception does not retain response headers, so `Retry-After`
  /// hints are not replayed; the schedule's backoff applies.
  ///
  /// Never apply this to writes: a server that failed after admitting a
  /// prompt would run it twice. For an explicitly idempotent write, compose
  /// `retry(schedule, whileError: isTransient)` directly with a comment
  /// saying why it is safe.
  Effect<A, OpenCodeError, R> withReadRetry([Schedule? schedule]) =>
      retry(schedule ?? standardReadRetry, whileError: isTransient);
}

/// Exit helpers for callers embedding effects in existing async code.
extension OpenCodeExit<A> on Exit<A, OpenCodeError> {
  /// The value, when this exit succeeded.
  A? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// The expected error, when this exit is a standalone expected failure.
  ///
  /// Interruption, defects and composite causes return `null`; inspect the
  /// cause for those.
  OpenCodeError? get expectedError => switch (this) {
    Failure(cause: Expected(:final error)) => error,
    _ => null,
  };
}

/// Throw-style running for effects whose environment is [Unit].
extension OpenCodeRuntimeRun on Runtime<Unit> {
  /// Awaits [effect] and returns its value.
  ///
  /// Expected failures throw the typed [OpenCodeError] they carry, so
  /// existing `try`/`catch` controller code keeps working with
  /// `on OpenCodeError`. Interruption, defects and composite cleanup causes
  /// throw [EffectException] with the full cause attached.
  Future<A> runOpenCode<A>(Effect<A, OpenCodeError, Unit> effect) async {
    final exit = await runExit(effect);
    return switch (exit) {
      Success(:final value) => value,
      Failure(cause: Expected(:final error)) => throw error,
      Failure(:final cause) => throw EffectException(cause),
    };
  }
}
