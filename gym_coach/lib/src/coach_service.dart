/// Wires the Genkit `openCode()` plugin into a small app-facing service.
library;

import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';

import 'plan_request.dart';

/// The model recommended by the app when the server offers it.
const String kPreferredModelId = 'longcat-2.5-preview-free';

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

/// Drives the OpenCode-backed coach.
///
/// The OpenCode plugin connects to the local background service (starting one
/// when needed); no API key is involved because the server owns the models.
class CoachService {
  CoachService() {
    _genkit = Genkit(plugins: [_plugin]);
  }

  final OpenCodePlugin _plugin = openCode();
  late final Genkit _genkit;
  CancellationController? _active;

  /// Lists the server's models, with the free LongCat preview first.
  Future<List<CoachModel>> listModels() async {
    final actions = await _plugin.list();
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

  /// Streams a plan for [request] from [modelId].
  Stream<PlanEvent> generatePlan({
    required String modelId,
    required PlanRequest request,
  }) async* {
    final controller = CancellationController();
    _active = controller;
    final stream = _genkit.generateStream<String, OpenCodeModelOptions>(
      model: openCode.model(modelId),
      messages: [
        Message(role: Role.system, content: [TextPart(text: _systemPrompt)]),
        Message(role: Role.user, content: [TextPart(text: request.toPrompt())]),
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

  /// Aborts the in-flight generation, if any.
  void cancel() => _active?.cancel('Stopped by the athlete');
}
