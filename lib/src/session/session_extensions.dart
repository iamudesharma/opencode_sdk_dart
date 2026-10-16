/// High-level session helpers layered on top of the generated resources.
///
/// * [OpenCodeSessionTurn.streamPrompt] runs one turn end to end: it sends
///   the prompt, streams text and reasoning deltas, and resolves with the
///   server's own record of the message — reconciling through
///   `session.wait` plus an assistant-message check when the shared event
///   connection drops mid-turn (it is live-only).
/// * [SessionPagination.listAll] and [SessionMessagePagination.listAll]
///   follow `cursor.next` through every page.
library;

import 'dart:async';

import '../core/errors.dart';
import '../core/json_utils.dart';
import '../core/request_options.dart';
import '../generated/client.dart';
import '../generated/models.dart';
import '../generated/resources/session_resource.dart';

/// Token usage accumulated over the steps of one turn.
final class SessionTurnUsage {
  /// Creates a usage snapshot; every field defaults to zero.
  const SessionTurnUsage({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.reasoningTokens = 0,
    this.cacheReadTokens = 0,
    this.cacheWriteTokens = 0,
    this.cost = 0,
  });

  /// Prompt tokens.
  final int inputTokens;

  /// Generated tokens.
  final int outputTokens;

  /// Reasoning tokens included in the generated total.
  final int reasoningTokens;

  /// Tokens served from the prompt cache.
  final int cacheReadTokens;

  /// Tokens written to the prompt cache.
  final int cacheWriteTokens;

  /// Cost reported for the steps, in the server's currency unit.
  final double cost;

  /// Every token counted by the server, including reasoning and cache.
  int get totalTokens =>
      inputTokens +
      outputTokens +
      reasoningTokens +
      cacheReadTokens +
      cacheWriteTokens;

  /// Folds one `session.step.ended` payload into this usage.
  SessionTurnUsage merge(JsonMap data) {
    final tokens = data['tokens'];
    if (tokens is! Map) return this;
    int read(Object? value) => value is num ? value.toInt() : 0;
    final cache = tokens['cache'];
    final cost = data['cost'];
    return SessionTurnUsage(
      inputTokens: inputTokens + read(tokens['input']),
      outputTokens: outputTokens + read(tokens['output']),
      reasoningTokens: reasoningTokens + read(tokens['reasoning']),
      cacheReadTokens:
          cacheReadTokens + (cache is Map ? read(cache['read']) : 0),
      cacheWriteTokens:
          cacheWriteTokens + (cache is Map ? read(cache['write']) : 0),
      cost: cost is num ? this.cost + cost.toDouble() : this.cost,
    );
  }

  @override
  String toString() =>
      'SessionTurnUsage(input: $inputTokens, output: $outputTokens, '
      'reasoning: $reasoningTokens, cacheRead: $cacheReadTokens, '
      'cacheWrite: $cacheWriteTokens, cost: $cost)';
}

/// The final state of one session turn.
final class SessionTurnResult {
  /// Creates a turn result.
  const SessionTurnResult({
    required this.text,
    required this.reasoning,
    required this.usage,
    this.admitted,
  });

  /// The assistant text, reconciled with the server's record of the message.
  final String text;

  /// The assistant reasoning text, when the model produced any.
  final String reasoning;

  /// Token usage accumulated over the turn's steps.
  final SessionTurnUsage usage;

  /// The admission response of the prompt, when the server returned one.
  final SessionInboxUser? admitted;

  @override
  String toString() => 'SessionTurnResult(${text.length} chars)';
}

/// A streamed event of a turn started by [OpenCodeSessionTurn.streamPrompt].
sealed class SessionTurnEvent {
  const SessionTurnEvent();
}

/// An assistant text delta.
final class SessionTurnTextDelta extends SessionTurnEvent {
  /// Creates a text delta.
  const SessionTurnTextDelta(this.delta);

  /// The newly generated text.
  final String delta;

  @override
  String toString() => 'SessionTurnTextDelta(${delta.length} chars)';
}

/// An assistant reasoning delta.
final class SessionTurnReasoningDelta extends SessionTurnEvent {
  /// Creates a reasoning delta.
  const SessionTurnReasoningDelta(this.delta);

  /// The newly generated reasoning text.
  final String delta;

  @override
  String toString() => 'SessionTurnReasoningDelta(${delta.length} chars)';
}

/// Token usage after one completed step; [usage] is cumulative for the turn.
final class SessionTurnStepUsage extends SessionTurnEvent {
  /// Creates a step-usage event.
  const SessionTurnStepUsage(this.usage);

  /// The turn's usage so far.
  final SessionTurnUsage usage;

  @override
  String toString() => 'SessionTurnStepUsage($usage)';
}

/// The turn finished; this is the last event before the stream closes.
final class SessionTurnCompleted extends SessionTurnEvent {
  /// Creates a completion event.
  const SessionTurnCompleted(this.result);

  /// The final turn state.
  final SessionTurnResult result;

  @override
  String toString() => 'SessionTurnCompleted(${result.text.length} chars)';
}

/// The server reported the turn as failed (`session.execution.failed`).
final class OpenCodeExecutionException implements Exception {
  /// Creates an execution failure carrying the server's [message].
  OpenCodeExecutionException(this.message, {this.data});

  /// The error message the server reported.
  final String message;

  /// The raw `session.execution.failed` payload.
  final JsonMap? data;

  @override
  String toString() => 'OpenCodeExecutionException: $message';
}

/// A live view of one session turn started by [OpenCodeSessionTurn.streamPrompt].
final class SessionTurn extends StreamView<SessionTurnEvent> {
  SessionTurn._(super.stream, this.result);

  /// Resolves when the turn ends.
  ///
  /// The result is reconciled with the server's own record of the assistant
  /// message, so a dropped event stream delays the answer but never loses it.
  final Future<SessionTurnResult> result;
}

/// Adds [streamPrompt] to the client.
extension OpenCodeSessionTurn on OpenCodeClient {
  /// Starts one turn on [sessionID]: sends [text] and returns a live view of
  /// the turn.
  ///
  /// The returned stream emits [SessionTurnTextDelta],
  /// [SessionTurnReasoningDelta], [SessionTurnStepUsage] events and a final
  /// [SessionTurnCompleted] event; [SessionTurn.result] resolves at the same
  /// time. The prompt is sent immediately — listening is optional — and the
  /// turn is completed through the shared event stream when it delivers,
  /// falling back to `session.wait` plus an assistant-message check when the
  /// live-only connection drops or misses events.
  SessionTurn streamPrompt({
    required SessionID sessionID,
    required String text,
    List<PromptInputFileAttachment>? files,
    List<PromptInputSkillAttachment>? skills,
    Map<String, Object?>? metadata,
    SessionInboxDelivery? delivery,
    bool? resume,
    RequestOptions? options,
  }) {
    final controller = StreamController<SessionTurnEvent>();
    final result = Completer<SessionTurnResult>();
    final done = Completer<void>();
    final textBuffer = StringBuffer();
    final reasoningBuffer = StringBuffer();
    var usage = const SessionTurnUsage();
    var closed = false;

    void emit(SessionTurnEvent event) {
      if (closed || controller.isClosed) return;
      controller.add(event);
    }

    void emitDelta(String delta, {required bool isReasoning}) {
      if (delta.isEmpty) return;
      emit(
        isReasoning
            ? SessionTurnReasoningDelta(delta)
            : SessionTurnTextDelta(delta),
      );
    }

    String append(String value, {required bool isReasoning}) {
      final buffer = isReasoning ? reasoningBuffer : textBuffer;
      buffer.write(value);
      return value;
    }

    void reconcileEnded(Object? full, {required bool isReasoning}) {
      if (full is! String || full.isEmpty) return;
      final buffer = isReasoning ? reasoningBuffer : textBuffer;
      final current = buffer.toString();
      if (full == current) return;
      if (full.startsWith(current)) {
        emitDelta(
          append(full.substring(current.length), isReasoning: isReasoning),
          isReasoning: isReasoning,
        );
        return;
      }
      // The event disagrees with what was streamed (for example a late
      // subscription saw a truncated history); trust the event for the final
      // response without emitting duplicate text.
      buffer
        ..clear()
        ..write(full);
    }

    // Subscribe before prompting so early deltas are not missed.
    final subscription = multiplexer
        .subscribe(filter: (event) => event.data['sessionID'] == sessionID)
        .listen(
          (event) {
            if (done.isCompleted) return;
            switch (event.type) {
              case 'session.text.delta':
                final delta = event.data['delta'];
                if (delta is String && delta.isNotEmpty) {
                  emitDelta(
                    append(delta, isReasoning: false),
                    isReasoning: false,
                  );
                }
              case 'session.text.ended':
                reconcileEnded(event.data['text'], isReasoning: false);
              case 'session.reasoning.delta':
                final delta = event.data['delta'];
                if (delta is String && delta.isNotEmpty) {
                  emitDelta(
                    append(delta, isReasoning: true),
                    isReasoning: true,
                  );
                }
              case 'session.reasoning.ended':
                reconcileEnded(event.data['text'], isReasoning: true);
              case 'session.step.ended':
                usage = usage.merge(event.data);
                emit(SessionTurnStepUsage(usage));
              case 'session.execution.succeeded':
                done.complete();
              case 'session.execution.failed':
                done.completeError(_executionError(event.data));
              case 'session.execution.interrupted':
                done.completeError(OpenCodeCancelledException());
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!done.isCompleted) done.completeError(error, stackTrace);
          },
          onDone: () {
            // The shared event stream is live-only: it can end mid-turn
            // (reconnect, slow-consumer overflow, server restart). The
            // polling fallback below finishes the turn from session state.
          },
        );

    Future<void> cleanup() async {
      if (closed) return;
      closed = true;
      await subscription.cancel();
      await controller.close();
    }

    Future<void> run() async {
      SessionInboxUser? admitted;
      try {
        admitted = await session.prompt(
          sessionID: sessionID,
          text: text,
          files: files,
          skills: skills,
          metadata: metadata,
          delivery: delivery,
          resume: resume,
          options: options,
        );
      } catch (error, stackTrace) {
        if (!result.isCompleted) result.completeError(error, stackTrace);
        await cleanup();
        return;
      }

      try {
        // Complete on whichever comes first: the execution event or the
        // session reporting itself idle with a finished assistant message.
        // The event path is the fast one; the polling path is what keeps the
        // turn correct when events are missed.
        await Future.any([
          done.future,
          _awaitExecutionEnd(session, sessionID, options, done),
        ]);

        // Reconcile with the server's own record of the turn so a dropped
        // event stream never loses generated text.
        await _reconcileFromServer(
          session,
          sessionID,
          textBuffer,
          reasoningBuffer,
          options,
        );

        final turnResult = SessionTurnResult(
          text: textBuffer.toString(),
          reasoning: reasoningBuffer.toString(),
          usage: usage,
          admitted: admitted,
        );
        emit(SessionTurnCompleted(turnResult));
        if (!result.isCompleted) result.complete(turnResult);
      } catch (error, stackTrace) {
        if (!result.isCompleted) result.completeError(error, stackTrace);
      } finally {
        await cleanup();
      }
    }

    unawaited(run());

    return SessionTurn._(controller.stream, result.future);
  }
}

/// Waits until the server reports the session idle *and* the assistant message
/// of the turn is completed, then resolves [done].
///
/// This is the safety net for the event stream: a turn must still finish when
/// the shared connection ends or misses events. Errors are surfaced while
/// [done] is still pending; a timeout fails the turn.
Future<void> _awaitExecutionEnd(
  SessionResource session,
  SessionID sessionID,
  RequestOptions? options,
  Completer<void> done,
) async {
  const maxPolls = 180;
  try {
    for (var attempt = 0; attempt < maxPolls && !done.isCompleted; attempt++) {
      await session.wait(sessionID: sessionID, options: options);
      if (done.isCompleted) return;
      final response = await session.message.list(
        sessionID: sessionID,
        limit: '10',
        order: SessionMessageListOrder.desc,
        type: SessionMessageListType.assistant,
        options: options,
      );
      if (done.isCompleted) return;
      final assistants = response.data.whereType<SessionMessageAssistant>();
      final assistant = assistants.isEmpty ? null : assistants.first;
      if (assistant != null && assistant.time.completed != null) {
        done.complete();
        return;
      }
    }
    if (!done.isCompleted) {
      done.completeError(
        OpenCodeStreamException('Timed out waiting for the session to finish.'),
      );
    }
  } catch (error, stackTrace) {
    if (!done.isCompleted) done.completeError(error, stackTrace);
  }
}

/// Fills gaps in the streamed buffers from the server's record of the last
/// assistant message, so a dropped event stream does not lose the answer.
///
/// Best-effort: reconciliation failures leave the turn's streamed text alone.
Future<void> _reconcileFromServer(
  SessionResource session,
  SessionID sessionID,
  StringBuffer text,
  StringBuffer reasoning,
  RequestOptions? options,
) async {
  try {
    final response = await session.message.list(
      sessionID: sessionID,
      limit: '10',
      order: SessionMessageListOrder.desc,
      type: SessionMessageListType.assistant,
      options: options,
    );
    final assistants = response.data.whereType<SessionMessageAssistant>();
    if (assistants.isEmpty) return;
    for (final part in assistants.first.content) {
      switch (part) {
        case SessionMessageAssistantText(text: final serverText):
          if (serverText.length > text.length &&
              serverText.startsWith(text.toString())) {
            text.write(serverText.substring(text.length));
          }
        case SessionMessageAssistantReasoning(text: final serverReasoning):
          if (serverReasoning.length > reasoning.length &&
              serverReasoning.startsWith(reasoning.toString())) {
            reasoning.write(serverReasoning.substring(reasoning.length));
          }
        default:
          break;
      }
    }
  } catch (error) {
    // Reconciliation is best-effort; the turn resolves with what it has.
  }
}

OpenCodeExecutionException _executionError(JsonMap data) {
  final error = data['error'];
  final message = error is Map
      ? (error['message']?.toString() ?? error['_tag']?.toString())
      : error?.toString();
  return OpenCodeExecutionException(
    'The session failed: ${message ?? 'unknown error'}',
    data: data,
  );
}

/// Adds [listAll] to the generated session resource.
extension SessionPagination on SessionResource {
  /// Iterates every page of [list], following `cursor.next` until the server
  /// stops handing out cursors.
  Stream<SessionInfo> listAll({
    String? limit,
    SessionListOrder? order,
    String? search,
    Object? parentID,
    AbsolutePath? directory,
    ProjectID? project,
    RelativePath? subpath,
    RequestOptions? options,
  }) async* {
    SessionsCursor? cursor;
    do {
      final page = await list(
        limit: limit,
        order: order,
        search: search,
        parentID: parentID,
        directory: directory,
        project: project,
        subpath: subpath,
        cursor: cursor,
        options: options,
      );
      for (final session in page.data) {
        yield session;
      }
      if (page.data.isEmpty) return;
      cursor = page.cursor.next;
    } while (cursor != null);
  }
}

/// Adds [listAll] to the generated session message resource.
extension SessionMessagePagination on SessionMessageResource {
  /// Iterates every page of [list], following `cursor.next` until the server
  /// stops handing out cursors.
  ///
  /// Pass the same [type] filter on every page, as the server expects.
  Stream<SessionMessageInfo> listAll({
    required SessionID sessionID,
    String? limit,
    SessionMessageListOrder? order,
    SessionMessageListType? type,
    RequestOptions? options,
  }) async* {
    String? cursor;
    do {
      final page = await list(
        sessionID: sessionID,
        limit: limit,
        order: order,
        cursor: cursor,
        type: type,
        options: options,
      );
      for (final message in page.data) {
        yield message;
      }
      if (page.data.isEmpty) return;
      cursor = page.cursor.next;
    } while (cursor != null);
  }
}
