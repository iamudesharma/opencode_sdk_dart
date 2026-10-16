import 'dart:io';

import 'package:gym_coach/src/coach_service.dart';
import 'package:gym_coach/src/plan_request.dart';

/// Streams or generates one plan from the live OpenCode server and prints it.
///
/// Run from the app directory:
///
///     dart run tool/plan_check.dart [model-id] [--typed]
///
/// `--typed` exercises the structured-output path the app's typed view uses.
Future<void> main(List<String> args) async {
  final typed = args.contains('--typed');
  final modelArgs = args.where((arg) => !arg.startsWith('--')).toList();
  final service = CoachService();
  final models = await service.listModels();
  if (models.isEmpty) {
    stderr.writeln('No models reported by the server.');
    exitCode = 1;
    return;
  }
  final model = modelArgs.isNotEmpty
      ? models.firstWhere(
          (m) => m.id == modelArgs.first,
          orElse: () => models.first,
        )
      : models.firstWhere(
          (m) => m.id == kPreferredModelId,
          orElse: () => models.first,
        );
  stdout.writeln('catalog: ${models.length} models · using ${model.id}');

  final request = PlanRequest(
    goal: modelArgs.length > 1 ? FitnessGoal.loseFat : FitnessGoal.buildMuscle,
    level: ExperienceLevel.intermediate,
    daysPerWeek: 3,
    sessionMinutes: 45,
    equipment: GymEquipment.dumbbells,
    notes: 'Bad left knee, no barbell squats.',
    includeNutrition: true,
    nutritionTargets: typed
        ? '~2760 kcal/day, 144 g protein, 77 g fat, 373 g carbs (TDEE 2759 kcal).'
        : null,
  );

  if (typed) {
    final stopwatch = Stopwatch()..start();
    final result = await service.generateTypedPlan(
      modelId: model.id,
      request: request,
    );
    stopwatch.stop();
    final plan = result.plan;
    stdout.writeln('--- typed plan ---');
    stdout.writeln('overview: ${plan.overview}');
    stdout.writeln('days: ${plan.days.length}');
    for (final day in plan.days) {
      stdout.writeln(
        '  ${day.name} — ${day.focus} '
        '(${day.exercises.length} exercises, warmup=${day.warmup != null})',
      );
      for (final exercise in day.exercises) {
        stdout.writeln('    - ${exercise.name}: ${exercise.prescription}');
      }
    }
    stdout.writeln('progression: ${plan.progression}');
    final meals = plan.meals ?? const [];
    stdout.writeln(
      'meals: ${meals.length} '
      '(${meals.fold<int>(0, (sum, meal) => sum + (meal.calories ?? 0))} kcal, '
      '${meals.fold<int>(0, (sum, meal) => sum + (meal.proteinG ?? 0))} g protein)',
    );
    stdout.writeln('safety: ${plan.safetyNotes}');
    stdout.writeln(
      '--- done in ${stopwatch.elapsedMilliseconds}ms · '
      '${result.usage?.totalTokens} tokens',
    );
    return;
  }

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
