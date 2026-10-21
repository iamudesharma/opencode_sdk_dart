/// The effect-native OpenCode client.
///
/// [EffectOpenCodeClient] wraps a plain `OpenCodeClient` from
/// `opencode_sdk_dart`. Every operation it exposes is a lazy, rerunnable
/// `Effect` (or `EffectStream`) with one sealed error channel and effect-owned
/// cancellation:
///
/// * any generated resource method binds through [EffectOpenCodeClient.call];
/// * [EffectOpenCodeClient.events] is a pull stream over the shared event
///   connection;
/// * [EffectOpenCodeClient.runTurn] runs one session turn end to end;
/// * [EffectOpenCodeClient.rpcCall] / [EffectOpenCodeClient.rpcEvents] cover
///   plugin RPC;
/// * PTY sockets are acquired with effects and consumed as effect streams.
library;

import 'dart:async';

import 'package:effect_core/effect_core.dart' hide CancellationToken;
import 'package:http/http.dart' as http;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'call.dart';
import 'errors.dart';
import 'streams.dart';

/// An OpenCode client whose operations are typed effects.
///
/// Construct one directly with [EffectOpenCodeClient] or [make] when you own
/// its lifetime, or let [openCodeClientLayer] acquire and release it for you
/// (preferred: the layer closes the client — aborting the shared event
/// connection and the HTTP pool — when its scope ends).
final class EffectOpenCodeClient {
  /// Wraps [sdk].
  EffectOpenCodeClient(this.sdk);

  /// Creates a client for a known server [baseUrl].
  ///
  /// [httpClient] reuses an existing client (the caller keeps ownership);
  /// [clientFactory] supplies the dedicated client used by cancellable
  /// requests and the event connection — pass the same client/factory as the
  /// SDK under test to script those paths.
  factory EffectOpenCodeClient.make({
    required Uri baseUrl,
    Map<String, String>? headers,
    http.Client? httpClient,
    http.Client Function()? clientFactory,
  }) => EffectOpenCodeClient(
    OpenCodeClient(
      baseUrl: baseUrl,
      headers: headers,
      httpClient: httpClient,
      clientFactory: clientFactory,
    ),
  );

  /// The underlying SDK client.
  ///
  /// Use it for capabilities the bridge does not wrap yet; binder methods
  /// ([call], [events], ...) accept raw SDK futures in their callbacks.
  final OpenCodeClient sdk;

  /// Binds any SDK call to the effect runtime.
  ///
  /// ```dart
  /// final agents =
  ///     client.call((options) => client.sdk.agent.list(options: options));
  /// ```
  ///
  /// The run gets a fresh SDK cancellation token; interrupting the fiber
  /// aborts the in-flight request. [location] pins the call to a working
  /// directory and [headers] adds per-call headers.
  ///
  /// Set [abortable] to `false` for hot request/response loops that prefer the
  /// SDK's pooled shared client: no dedicated client/connection is opened per
  /// call, but interruption only stops waiting (the request completes and its
  /// result is discarded). Streams, writes and long operations should stay
  /// abortable.
  Effect<A, OpenCodeError, R> call<A, R>(
    Future<A> Function(RequestOptions options) invoke, {
    LocationRef? location,
    Map<String, String>? headers,
    bool abortable = true,
    FutureOr<void> Function(A value)? onInterruptedResult,
  }) => openCodeCall(
    invoke,
    base: (location == null && headers == null)
        ? null
        : RequestOptions(location: location, headers: headers),
    abortable: abortable,
    onInterruptedResult: onInterruptedResult,
  );

  /// Binds a *read* SDK call with [OpenCodeReadRetry.withReadRetry] applied.
  ///
  /// Prefer this over composing `call(...).withReadRetry()` inline: the
  /// chained form loses `R` when inferred from an outer argument position
  /// (`R` falls back to `dynamic`), while [read] is the outermost generic
  /// call and infers both `A` and `R` from context.
  ///
  /// Never use this for writes; see [OpenCodeReadRetry.withReadRetry].
  /// [abortable] forwards to [call] — pass `false` for hot read loops.
  Effect<A, OpenCodeError, R> read<A, R>(
    Future<A> Function(RequestOptions options) invoke, {
    LocationRef? location,
    Map<String, String>? headers,
    Schedule? schedule,
    bool abortable = true,
  }) => call<A, R>(
    invoke,
    location: location,
    headers: headers,
    abortable: abortable,
  ).withReadRetry(schedule);

  /// The shared event stream as a pull stream.
  ///
  /// Each consumption opens one shared-connection subscription and closes it
  /// when the consumption ends or is interrupted — the SDK multiplexer keeps
  /// the upstream connection alive while other subscribers remain. Streams
  /// are live-only: a source failure ends the consumption with
  /// [OpenCodeStreamError] and a later run opens a fresh connection.
  EffectStream<OpenCodeEvent, OpenCodeError, R> events<R>({
    bool Function(OpenCodeEvent event)? filter,
    void Function()? onActivity,
  }) => EffectStream.fromNative(
    () => losslessBuffered(
      sdk.multiplexer.subscribe(filter: filter, onActivity: onActivity),
    ),
    onError: mapOrRethrow,
  );

  /// Runs one session turn end to end and resolves with its final result.
  ///
  /// One run sends exactly one prompt — this is a write; never retry it. Each
  /// run allocates a fresh turn, so rerunning (or racing) effects duplicate
  /// the prompt. [onEvent] observes the live deltas; the final result is
  /// reconciled with the server's record of the assistant message.
  ///
  /// Interruption stops *waiting* and cancels this run's SDK-side token: an
  /// in-flight prompt request aborts, and the `session.wait` polling plus
  /// reconciliation requests of this run stop. It does not revoke a prompt
  /// the server already admitted — run `session.interrupt` to stop that
  /// generation.
  Effect<SessionTurnResult, OpenCodeError, R> runTurn<R>({
    required SessionID sessionID,
    required String text,
    List<PromptInputFileAttachment>? files,
    List<PromptInputSkillAttachment>? skills,
    Map<String, Object?>? metadata,
    SessionInboxDelivery? delivery,
    bool? resume,
    LocationRef? location,
    void Function(SessionTurnEvent event)? onEvent,
  }) => Effect.asyncExit<SessionTurnResult, OpenCodeError, R>((context) async {
    if (context.token.isCancelled) return const Failure(Interrupted());
    final sdkToken = CancellationToken();
    final detach = context.token.onCancel(sdkToken.cancel);
    try {
      final turn = sdk.streamPrompt(
        sessionID: sessionID,
        text: text,
        files: files,
        skills: skills,
        metadata: metadata,
        delivery: delivery,
        resume: resume,
        options: RequestOptions(location: location, cancelToken: sdkToken),
      );
      final subscription = turn.listen(
        (event) => onEvent?.call(event),
        onError: (Object _, StackTrace __) {
          // Failures are reported through turn.result below.
        },
      );
      final done = Completer<Exit<SessionTurnResult, OpenCodeError>>();
      unawaited(
        turn.result.then(
          (result) {
            if (!done.isCompleted) done.complete(Success(result));
          },
          onError: (Object error, StackTrace stackTrace) {
            if (done.isCompleted) return;
            final mapped = mapOpenCodeException(error);
            done.complete(
              mapped != null
                  ? Failure(Expected(mapped))
                  : Failure(Defect(error, stackTrace)),
            );
          },
        ),
      );
      final exit = await Future.any<Exit<SessionTurnResult, OpenCodeError>>([
        done.future,
        context.token.whenCancelled.then((_) => const Failure(Interrupted())),
      ]);
      await subscription.cancel();
      return exit;
    } finally {
      detach();
    }
  });

  /// The live event stream of one turn: deltas, step usage, completion.
  ///
  /// One run sends exactly one prompt (a write — never retry). The stream
  /// ends after [SessionTurnCompleted]; when the turn fails, the stream
  /// fails with [OpenCodeExecutionFailed] (or the underlying API error).
  /// Cancelling a consumption stops observing; it does not stop generation.
  EffectStream<SessionTurnEvent, OpenCodeError, R> turnStream<R>({
    required SessionID sessionID,
    required String text,
    List<PromptInputFileAttachment>? files,
    List<PromptInputSkillAttachment>? skills,
    Map<String, Object?>? metadata,
    SessionInboxDelivery? delivery,
    bool? resume,
    LocationRef? location,
  }) => EffectStream.fromNative(
    () => _withTurnResult(
      sdk.streamPrompt(
        sessionID: sessionID,
        text: text,
        files: files,
        skills: skills,
        metadata: metadata,
        delivery: delivery,
        resume: resume,
        options: location == null ? null : RequestOptions(location: location),
      ),
    ),
    onError: mapOrRethrow,
  );

  /// Calls a plugin RPC method and decodes its output.
  ///
  /// RPC writes are POSTs; treat them as writes unless the plugin documents
  /// the method as idempotent.
  Effect<O, OpenCodeError, R> rpcCall<O, R>(
    String id,
    String method, {
    Object? input,
    required O Function(Object? output) decode,
    LocationRef? location,
  }) => call(
    (options) => sdk
        .rpc(id)
        .call<O>(method, input: input, decode: decode, options: options),
    location: location,
  );

  /// A plugin RPC event stream.
  ///
  /// Events are delivered from every location, matching the reference client;
  /// filter on [RpcEvent.location] when needed.
  EffectStream<RpcEvent<T>, OpenCodeError, R> rpcEvents<T, R>(
    String id,
    String event, {
    required T Function(Object? data) decode,
    void Function()? onActivity,
  }) => EffectStream.fromNative(
    () => losslessBuffered(
      sdk.rpc(id).subscribe<T>(event, decode: decode, onActivity: onActivity),
    ),
    onError: mapOrRethrow,
  );

  /// Performs the PTY ticket handshake and opens the terminal WebSocket.
  ///
  /// Compose with `Effect.acquireUseRelease` (release: [ptyClose]) so the
  /// socket is always closed; see the package README.
  Effect<PtySocket, OpenCodeError, R> ptyConnect<R>({
    required PtyID ptyID,
    int? cursor,
    LocationRef? location,
  }) => call(
    (options) => sdk.pty.connectSocket(
      ptyID: ptyID,
      cursor: cursor,
      location: location,
      options: options,
    ),
    location: location,
    // A socket produced in the instant before an interrupt must not leak.
    onInterruptedResult: (socket) => socket.close(),
  );

  /// Opens a persistent PTY attachment (with `cursor`, `role`, `takeover`).
  Effect<PtySocket, OpenCodeError, R> persistentPtyConnect<R>({
    required PtyID ptyID,
    String? cursor,
    String? role,
    String? attachmentID,
    bool takeover = false,
  }) => call(
    (options) => sdk.persistentPty.connectSocket(
      ptyID: ptyID,
      cursor: cursor,
      role: role,
      attachmentID: attachmentID,
      takeover: takeover,
      options: options,
    ),
    onInterruptedResult: (socket) => socket.close(),
  );

  /// A PTY socket's typed frames as a pull stream: [PtyOutput] text and
  /// [PtyCursor] resume markers, decoded from text and binary frames.
  ///
  /// Prefer this over [ptyText] when resume cursors matter: the text stream
  /// exposes binary cursor markers as JSON text and cannot distinguish them
  /// from terminal output that happens to spell the same JSON.
  ///
  /// The underlying WebSocket stream is single-subscription: consume it once
  /// per socket.
  EffectStream<PtyFrame, OpenCodeError, R> ptyFrames<R>(PtySocket socket) =>
      EffectStream.fromNative(() => socket.frames, onError: mapOrRethrow);

  /// A PTY socket's text output as a pull stream.
  ///
  /// The underlying WebSocket stream is single-subscription: consume it once
  /// per socket. Cursor markers arrive as JSON text; use [ptyFrames] to get
  /// typed frames instead.
  EffectStream<String, OpenCodeError, R> ptyText<R>(PtySocket socket) =>
      EffectStream.fromNative(() => socket.text, onError: mapOrRethrow);

  /// Closes a PTY socket.
  Effect<Unit, OpenCodeError, R> ptyClose<R>(PtySocket socket) =>
      openCodeTask(() async {
        await socket.close();
        return Unit.value;
      });

  /// Closes the underlying SDK client: aborts the shared event connection
  /// and closes the HTTP pool. Effects already running fail with transport
  /// errors; acquire a new client to continue.
  void close() => sdk.close();
}

/// Merges a turn's event stream with its result: the stream ends after
/// [SessionTurnCompleted] or fails with the result's error.
Stream<SessionTurnEvent> _withTurnResult(SessionTurn turn) {
  late StreamController<SessionTurnEvent> controller;
  StreamSubscription<SessionTurnEvent>? subscription;
  var closed = false;

  Future<void> finish(Object? error, StackTrace? stackTrace) async {
    if (closed) return;
    closed = true;
    await subscription?.cancel();
    if (!controller.isClosed) {
      if (error != null) {
        controller.addError(error, stackTrace ?? StackTrace.current);
      }
      await controller.close();
    }
  }

  controller = StreamController<SessionTurnEvent>(
    onListen: () {
      subscription = turn.listen(
        (event) {
          if (!closed && !controller.isClosed) controller.add(event);
        },
        onError: (Object _, StackTrace __) {
          // Failures are reported through turn.result below.
        },
      );
      unawaited(turn.result.then((_) => finish(null, null), onError: finish));
    },
    onCancel: () async {
      closed = true;
      await subscription?.cancel();
    },
  );
  return controller.stream;
}
