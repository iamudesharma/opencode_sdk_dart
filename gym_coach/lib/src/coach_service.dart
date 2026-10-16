/// Wires the Genkit `openCode()` plugin into a small app-facing service.
library;

import 'dart:async';

import 'package:genkit/genkit.dart' hide CancellationToken;
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'plan.dart';
import 'plan_request.dart';

/// The model recommended by the app when the server offers it.
const String kPreferredModelId = 'longcat-2.5-preview-free';

/// Flutter's `kIsWeb`, spelled out without importing `package:flutter` so the
/// service stays runnable from pure Dart (`dart run tool/plan_check.dart`).
const bool _kIsWeb = bool.fromEnvironment('dart.library.js_interop');

/// A remote server override passed with `--dart-define=OPENCODE_BASE_URL=...`.
const String _baseUrlOverride = String.fromEnvironment('OPENCODE_BASE_URL');

const String _systemPrompt = '''
You are an expert strength & conditioning coach and sports nutritionist who
writes safe, practical, progressive plans for real people. You are concise,
concrete and never invent equipment the athlete does not have. Plans are
readable as plain text in a narrow window: short lines, no tables, no code
fences.''';

/// A selectable model from the server catalog.
final class CoachModel {
  const CoachModel({required this.id, required this.label});

  final String id;
  final String label;
}

sealed class PlanEvent {
  const PlanEvent();
}

/// A streamed text delta.
final class PlanText extends PlanEvent {
  const PlanText(this.text);

  final String text;
}

/// The generation finished (or was aborted).
final class PlanCompleted extends PlanEvent {
  const PlanCompleted({
    required this.text,
    required this.cancelled,
    this.usage,
    this.finishMessage,
  });

  final String text;
  final bool cancelled;
  final GenerationUsage? usage;
  final String? finishMessage;
}

/// A typed plan plus the generation's usage.
final class TypedPlanResult {
  const TypedPlanResult({required this.plan, this.usage, this.latencyMs});

  /// The parsed plan.
  final WorkoutPlan plan;

  /// Token usage reported by the server.
  final GenerationUsage? usage;

  /// Wall-clock latency of the generation, milliseconds.
  final double? latencyMs;
}

/// Events streamed by an "Ask Coach" turn.
sealed class CoachChatEvent {
  const CoachChatEvent();
}

/// A streamed assistant text delta.
final class CoachChatDelta extends CoachChatEvent {
  const CoachChatDelta(this.text);

  final String text;
}

/// A streamed reasoning delta.
final class CoachChatReasoning extends CoachChatEvent {
  const CoachChatReasoning(this.text);

  final String text;
}

/// The chat turn finished (or was cancelled).
final class CoachChatDone extends CoachChatEvent {
  const CoachChatDone(this.text, {this.cancelled = false, this.usage});

  /// The assistant's full answer, reconciled with the server's record.
  final String text;

  /// Whether the turn was stopped by the athlete.
  final bool cancelled;

  /// Token usage for the turn, when the server reported any.
  final GenerationUsage? usage;
}

/// Drives the OpenCode-backed coach.
///
/// One lazily created [OpenCodeClient] serves both the Genkit bridge (typed
/// and live-text plans) and the persistent "Ask Coach" chat session:
///
/// * `--dart-define=OPENCODE_BASE_URL=...` points at a remote/LAN server;
/// * on the web the app's own origin is used (a LAN host can proxy `/`);
/// * otherwise the local background service is discovered or started.
class CoachService {
  CoachService();

  OpenCodeClient? _client;
  Future<OpenCodeClient>? _connecting;
  Genkit? _genkit;
  OpenCodePlugin? _plugin;
  String? _coachSessionID;
  Future<String>? _creatingSession;
  CancellationController? _active;
  CancellationToken? _chatCancel;

  /// The shared server session, once a plan or chat turn has created it.
  String? get coachSessionID => _coachSessionID;

  // Client + Genkit wiring ---------------------------------------------------

  /// Resolves the one client this service uses, creating it on first use.
  Future<OpenCodeClient> _ensureClient() {
    final existing = _client;
    if (existing != null) return Future.value(existing);
    final pending = _connecting;
    if (pending != null) return pending;
    final future = _connect().whenComplete(() {
      // A failed connect must not be cached forever: the UI's Retry (or a
      // later call) starts a fresh attempt.
      if (_client == null) _connecting = null;
    });
    _connecting = future;
    return future;
  }

  Future<OpenCodeClient> _connect() async {
    final OpenCodeClient client;
    if (_baseUrlOverride.isNotEmpty) {
      client = OpenCodeClient.make(baseUrl: Uri.parse(_baseUrlOverride));
    } else if (_kIsWeb) {
      client = OpenCodeClient.make(baseUrl: Uri.parse(Uri.base.origin));
    } else {
      client = await OpenCodeClient.connectLocal();
    }
    client.transport.retry = const RetryPolicy();
    _client = client;
    return client;
  }

  Future<(Genkit, OpenCodePlugin)> _ensureGenkit() async {
    final existing = _genkit;
    if (existing != null) return (existing, _plugin!);
    final client = await _ensureClient();
    final plugin = openCode(client: client);
    final genkit = Genkit(plugins: [plugin]);
    _plugin = plugin;
    _genkit = genkit;
    return (genkit, plugin);
  }

  /// The session shared by typed plans and "Ask Coach", created on first use.
  Future<String> _ensureCoachSession() {
    final existing = _coachSessionID;
    if (existing != null) return Future.value(existing);
    final pending = _creatingSession;
    if (pending != null) return pending;
    final future = () async {
      final client = await _ensureClient();
      final session = await client.session.create(title: 'OpenFit plan');
      _coachSessionID = session.id.value;
      return _coachSessionID!;
    }().whenComplete(() {
      // A failed create must not be cached forever.
      if (_coachSessionID == null) _creatingSession = null;
    });
    _creatingSession = future;
    return future;
  }

  /// Lists the server's models, with the free LongCat preview first.
  Future<List<CoachModel>> listModels() async {
    final (_, plugin) = await _ensureGenkit();
    final actions = await plugin.list();
    final seen = <String>{};
    final models = <CoachModel>[];
    for (final action in actions) {
      if (!seen.add(action.name)) continue;
      final label = action.metadata['label'];
      models.add(
        CoachModel(
          id: action.name,
          label: label is String && label.isNotEmpty ? label : action.name,
        ),
      );
    }
    int rank(CoachModel model) => switch (model.id) {
      kPreferredModelId => 0,
      final id when id.contains('free') => 1,
      _ => 2,
    };
    models.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
    return models;
  }

  // Plans --------------------------------------------------------------------

  /// Streams a plan for [request] from [modelId].
  ///
  /// [attachments] ride along with the user turn as media parts (the bridge
  /// turns them into session prompt attachments).
  Stream<PlanEvent> generatePlan({
    required String modelId,
    required PlanRequest request,
    List<PromptInputFileAttachment>? attachments,
  }) async* {
    final (genkit, _) = await _ensureGenkit();
    final controller = CancellationController();
    _active = controller;
    final stream = genkit.generateStream<String, OpenCodeModelOptions>(
      model: openCode.model(modelId),
      messages: [
        Message(role: Role.system, content: [TextPart(text: _systemPrompt)]),
        Message(
          role: Role.user,
          content: [
            TextPart(text: request.toPrompt()),
            ..._mediaParts(attachments),
          ],
        ),
      ],
      cancel: controller.token,
    );
    try {
      await for (final chunk in stream) {
        if (chunk.text.isNotEmpty) yield PlanText(chunk.text);
      }
      final result = await stream.onResult;
      yield PlanCompleted(
        text: result.text,
        cancelled:
            controller.isCancelled ||
            result.finishReason == FinishReason.aborted,
        usage: result.usage,
        finishMessage: result.finishMessage,
      );
    } finally {
      _active = null;
    }
  }

  /// Generates a typed plan for [request] from [modelId].
  ///
  /// Runs on the shared "OpenFit plan" session, so "Ask Coach" follow-ups keep
  /// the plan in context. The bridge appends the plan schema to the prompt and
  /// Genkit parses the JSON answer, so a model that ignores the schema fails
  /// with an actionable error instead of a half-parsed plan.
  ///
  /// [onProgress] is called as chunks arrive with the number of characters
  /// received so far. [attachments] ride along as media parts.
  Future<TypedPlanResult> generateTypedPlan({
    required String modelId,
    required PlanRequest request,
    List<PromptInputFileAttachment>? attachments,
    void Function(int receivedCharacters)? onProgress,
  }) async {
    final (genkit, _) = await _ensureGenkit();
    final sessionID = await _ensureCoachSession();
    final controller = CancellationController();
    _active = controller;
    final watch = Stopwatch()..start();
    try {
      final stream = genkit.generateStream<WorkoutPlan, OpenCodeModelOptions>(
        model: openCode.model(modelId),
        messages: [
          Message(role: Role.system, content: [TextPart(text: _systemPrompt)]),
          Message(
            role: Role.user,
            content: [
              TextPart(text: request.toPrompt(structured: true)),
              ..._mediaParts(attachments),
            ],
          ),
        ],
        config: OpenCodeModelOptions(sessionID: sessionID),
        outputSchema: WorkoutPlan.$schema,
        cancel: controller.token,
      );
      var received = 0;
      await for (final chunk in stream) {
        received += chunk.text.length;
        onProgress?.call(received);
      }
      final result = await stream.onResult;
      if (controller.isCancelled ||
          result.finishReason == FinishReason.aborted) {
        throw GenkitException(
          'Stopped by the athlete',
          status: StatusCode.cancelled,
        );
      }
      if (result.finishReason == FinishReason.failed) {
        throw GenkitException(
          result.error?.message ?? 'Generation failed',
          status: StatusCode.internal,
        );
      }
      final plan = result.output;
      if (plan == null) {
        throw GenkitException(
          'The model answered with text that did not match the plan schema. '
          'Try again, or switch to Live text.',
          status: StatusCode.internal,
        );
      }
      return TypedPlanResult(
        plan: plan,
        usage: result.usage,
        latencyMs: watch.elapsedMicroseconds / 1000,
      );
    } finally {
      _active = null;
    }
  }

  // Ask Coach ----------------------------------------------------------------

  /// Streams one "Ask Coach" turn on the shared session.
  ///
  /// The session is created on first use, so chat works before any plan has
  /// been generated; once a typed plan exists, follow-up questions keep the
  /// plan in context. [attachments] ride along with the prompt as files.
  Stream<CoachChatEvent> askCoach({
    required String text,
    List<PromptInputFileAttachment>? attachments,
  }) async* {
    final client = await _ensureClient();
    final sessionID = await _ensureCoachSession();
    final cancel = CancellationToken();
    _chatCancel = cancel;
    try {
      final turn = client.streamPrompt(
        sessionID: SessionID(sessionID),
        text: text,
        files: attachments,
        options: RequestOptions(cancelToken: cancel),
      );
      await for (final event in turn) {
        switch (event) {
          case SessionTurnTextDelta(:final delta):
            yield CoachChatDelta(delta);
          case SessionTurnReasoningDelta(:final delta):
            yield CoachChatReasoning(delta);
          case SessionTurnStepUsage():
          case SessionTurnCompleted():
            break;
        }
      }
      final result = await turn.result;
      yield CoachChatDone(
        result.text,
        cancelled: cancel.isCancelled,
        usage: _generationUsage(result.usage),
      );
    } on OpenCodeCancelledException {
      yield const CoachChatDone('', cancelled: true);
    } finally {
      if (identical(_chatCancel, cancel)) _chatCancel = null;
    }
  }

  /// Aborts the in-flight plan generation or chat turn, if any.
  void cancel() {
    _active?.cancel('Stopped by the athlete');
    _chatCancel?.cancel();
  }

  // Helpers ------------------------------------------------------------------

  /// Media parts for [attachments]; the bridge reads `part.media.url`.
  static List<Part> _mediaParts(
    List<PromptInputFileAttachment>? attachments,
  ) => [
    if (attachments != null)
      for (final attachment in attachments)
        MediaPart(media: Media(url: attachment.uri)),
  ];

  /// Maps the SDK's turn usage onto Genkit's accounting, like the bridge does.
  static GenerationUsage _generationUsage(SessionTurnUsage usage) =>
      GenerationUsage(
        inputTokens:
            usage.inputTokens + usage.cacheReadTokens + usage.cacheWriteTokens,
        outputTokens: usage.outputTokens + usage.reasoningTokens,
        totalTokens: usage.totalTokens,
        cachedContentTokens: usage.cacheReadTokens,
        thoughtsTokens: usage.reasoningTokens,
      );
}
