/// The typed training plan the coach generates through structured output.
library;

import 'package:schemantic/schemantic.dart';

part 'plan.g.dart';

/// A complete training plan, parsed from the model's JSON answer.
@Schema()
abstract class $WorkoutPlan {
  /// One short paragraph summarizing the plan and who it is for.
  String get overview;

  /// One entry per training day, in order.
  List<$TrainingDay> get days;

  /// The exact progression rule for weeks 2 and beyond, and when to deload.
  String get progression;

  /// The sample food day; null or empty when nutrition was not requested.
  List<$FoodMeal>? get meals;

  /// One short safety line: injuries to respect, when to stop.
  String? get safetyNotes;
}

/// One training day.
@Schema()
abstract class $TrainingDay {
  /// Short day label, e.g. `'Day 1 — Push'` or `'Full body A'`.
  String get name;

  /// One line naming the focus of the day.
  String get focus;

  /// The warm-up line (mobility and ramp-up sets).
  String? get warmup;

  /// The working exercises, in order.
  List<$Exercise> get exercises;

  /// The cool-down line.
  String? get cooldown;
}

/// One exercise prescription.
@Schema()
abstract class $Exercise {
  /// Exercise name.
  String get name;

  /// Sets, reps and rest, e.g. `'3 x 8-12, rest 90s'`.
  String get prescription;

  /// Optional form cue or substitution.
  String? get notes;
}

/// One meal of the sample day.
@Schema()
abstract class $FoodMeal {
  /// Meal name, e.g. `'Breakfast'`.
  String get meal;

  /// The foods with rough portions in grams.
  List<String> get items;

  /// Rough calories for the meal.
  int? get calories;

  /// Rough protein for the meal, in grams.
  int? get proteinG;
}

/// Markdown rendering shared by copy and export.
extension WorkoutPlanMarkdown on WorkoutPlan {
  /// Renders the plan as Markdown.
  String toMarkdown() {
    final buffer = StringBuffer()..writeln('# Training plan\n');
    buffer.writeln(overview);

    final trainingDays = days;
    if (trainingDays.isNotEmpty) {
      buffer.writeln('\n## Weekly split');
      for (final day in trainingDays) {
        buffer.writeln('\n### ${day.name} — ${day.focus}');
        final warmup = day.warmup;
        if (warmup != null && warmup.isNotEmpty) {
          buffer.writeln('Warm-up: $warmup');
        }
        for (final exercise in day.exercises) {
          final notes = exercise.notes;
          buffer.writeln(
            '- ${exercise.name} — ${exercise.prescription}'
            '${notes == null || notes.isEmpty ? '' : ' ($notes)'}',
          );
        }
        final cooldown = day.cooldown;
        if (cooldown != null && cooldown.isNotEmpty) {
          buffer.writeln('Cool-down: $cooldown');
        }
      }
    }

    buffer.writeln('\n## Progression');
    buffer.writeln(progression);

    final foodMeals = meals;
    if (foodMeals != null && foodMeals.isNotEmpty) {
      buffer.writeln('\n## Food plan');
      for (final meal in foodMeals) {
        final macros = [
          if (meal.calories != null) '${meal.calories} kcal',
          if (meal.proteinG != null) '${meal.proteinG} g protein',
        ].join(', ');
        buffer.writeln(
          '\n**${meal.meal}**${macros.isEmpty ? '' : ' ($macros)'}',
        );
        for (final item in meal.items) {
          buffer.writeln('- $item');
        }
      }
    }

    final safety = safetyNotes;
    if (safety != null && safety.isNotEmpty) {
      buffer.writeln('\n## Safety notes');
      buffer.writeln(safety);
    }
    return buffer.toString().trimRight();
  }
}
