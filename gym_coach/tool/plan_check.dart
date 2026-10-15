import 'dart:io';

import 'package:gym_coach/src/coach_service.dart';
import 'package:gym_coach/src/plan_request.dart';

/// Streams one plan from the live OpenCode server and prints it.
///
/// Run from the app directory:
///
///     dart run tool/plan_check.dart [model-id]
Future<void> main(List<String> args) async {
  final service = CoachService();
  final models = await service.listModels();
  if (models.isEmpty) {
    stderr.writeln('No models reported by the server.');
    exitCode = 1;
    return;
  }
  final model = args.isNotEmpty
      ? models.firstWhere(
          (m) => m.id == args.first,
          orElse: () => models.first,
        )
      : models.firstWhere(
          (m) => m.id == kPreferredModelId,
          orElse: () => models.first,
        );
  stdout.writeln('catalog: ${models.length} models · using ${model.id}');

  final request = PlanRequest(
    goal: args.length > 1 ? FitnessGoal.loseFat : FitnessGoal.buildMuscle,
    level: ExperienceLevel.intermediate,
    daysPerWeek: 3,
    sessionMinutes: 45,
    equipment: GymEquipment.dumbbells,
    notes: 'Bad left knee, no barbell squats.',
    includeNutrition: true,
  );

  final buffer = StringBuffer();
  var chunks = 0;
  final stopwatch = Stopwatch()..start();
  await for (final event in service.generatePlan(
    modelId: model.id,
    request: request,
  )) {
    switch (event) {
      case PlanText(:final text):
        chunks++;
        buffer.write(text);
      case PlanCompleted(:final usage, :final cancelled, :final finishMessage):
        stopwatch.stop();
        stdout.writeln(
          '\n--- done in ${stopwatch.elapsedMilliseconds}ms · '
          '$chunks chunks · ${usage?.totalTokens} tokens · '
          'cancelled=$cancelled${finishMessage == null ? '' : ' · $finishMessage'}',
        );
    }
  }

  stdout.writeln('--- plan ---');
  stdout.writeln(buffer);
}
