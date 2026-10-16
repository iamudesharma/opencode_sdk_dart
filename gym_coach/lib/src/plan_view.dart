import 'dart:async';

import 'package:flutter/material.dart';

import 'macros.dart';
import 'plan.dart';
import 'style.dart';

/// Renders a typed [WorkoutPlan]: day chips, an interactive day card with
/// per-exercise completion and a rest timer, macro targets, progression,
/// meals and safety notes.
class PlanView extends StatefulWidget {
  /// Creates the plan view.
  const PlanView({super.key, required this.plan, this.targets});

  /// The parsed plan to render.
  final WorkoutPlan plan;

  /// The calculator targets to compare the food plan against, when the
  /// athlete applied them before generating.
  final MacroTargets? targets;

  @override
  State<PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  /// The rest timer's regex: `rest 90s`, `rest 75 s`, ...
  static final _restPattern = RegExp(r'rest\s*(\d+)\s*s', caseSensitive: false);

  int _day = 0;
  final _done = <String>{};

  Timer? _restTimer;
  int _restRemaining = 0;
  String? _restFor;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  /// The rest duration a prescription asks for; 90 s when it does not say.
  static int restSecondsFor(String prescription) =>
      int.tryParse(_restPattern.firstMatch(prescription)?.group(1) ?? '') ?? 90;

  void _toggle(int dayIndex, int exerciseIndex) {
    final key = '$dayIndex:$exerciseIndex';
    setState(() {
      if (!_done.add(key)) _done.remove(key);
    });
  }

  void _startRest(Exercise exercise) {
    _restTimer?.cancel();
    setState(() {
      _restRemaining = restSecondsFor(exercise.prescription);
      _restFor = exercise.name;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _restRemaining--;
        if (_restRemaining <= 0) {
          _restTimer?.cancel();
          _restTimer = null;
          _restFor = null;
        }
      });
    });
  }

  void _stopRest() {
    _restTimer?.cancel();
    _restTimer = null;
    setState(() {
      _restRemaining = 0;
      _restFor = null;
    });
  }

  static String formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${rest.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = widget.plan;
    final days = plan.days;
    final selected = days.isEmpty ? -1 : _day.clamp(0, days.length - 1);
    final meals = plan.meals ?? const <FoodMeal>[];
    final safety = plan.safetyNotes;
    final totalCalories = meals.fold<int>(
      0,
      (sum, meal) => sum + (meal.calories ?? 0),
    );
    final totalProtein = meals.fold<int>(
      0,
      (sum, meal) => sum + (meal.proteinG ?? 0),
    );
    final targets = widget.targets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Section('Overview'),
        AppCard(child: Text(plan.overview, style: _body(theme))),
        if (days.isNotEmpty) ...[
          const SizedBox(height: Insets.xl),
          const _Section('Weekly split'),
          Wrap(
            spacing: Insets.sm,
            runSpacing: Insets.sm,
            children: [
              for (var index = 0; index < days.length; index++)
                ChoiceChip(
                  label: Text(days[index].name),
                  selected: index == selected,
                  onSelected: (_) => setState(() => _day = index),
                ),
            ],
          ),
          const SizedBox(height: Insets.md),
          _DayCard(
            theme: theme,
            day: days[selected],
            dayIndex: selected,
            done: _done,
            restRemaining: _restRemaining,
            restFor: _restFor,
            onToggle: _toggle,
            onStartRest: _startRest,
            onStopRest: _stopRest,
          ),
        ],
        if (targets != null && meals.isNotEmpty) ...[
          const SizedBox(height: Insets.xl),
          const _Section('Targets vs plan'),
          AppCard(
            child: _TargetsComparison(
              targets: targets,
              calories: totalCalories,
              protein: totalProtein,
            ),
          ),
        ],
        const SizedBox(height: Insets.xl),
        const _Section('Progression'),
        AppCard(child: Text(plan.progression, style: _body(theme))),
        if (meals.isNotEmpty) ...[
          const SizedBox(height: Insets.xl),
          Row(
            children: [
              const Expanded(child: _Section('Food plan')),
              if (totalCalories > 0)
                StatChip(
                  label: '$totalCalories kcal · $totalProtein g protein',
                ),
            ],
          ),
          for (final meal in meals)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: _MealCard(theme: theme, meal: meal),
            ),
        ],
        if (safety != null && safety.isNotEmpty) ...[
          const SizedBox(height: Insets.md),
          const _Section('Safety notes'),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: Insets.sm),
                Expanded(
                  child: Text(
                    safety,
                    style: _body(theme).copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Insets.xs),
      ],
    );
  }

  TextStyle _body(ThemeData theme) =>
      theme.textTheme.bodyMedium!.copyWith(height: 1.45);
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.theme,
    required this.day,
    required this.dayIndex,
    required this.done,
    required this.restRemaining,
    required this.restFor,
    required this.onToggle,
    required this.onStartRest,
    required this.onStopRest,
  });

  final ThemeData theme;
  final TrainingDay day;
  final int dayIndex;
  final Set<String> done;
  final int restRemaining;
  final String? restFor;
  final void Function(int dayIndex, int exerciseIndex) onToggle;
  final void Function(Exercise exercise) onStartRest;
  final VoidCallback onStopRest;

  @override
  Widget build(BuildContext context) {
    final warmup = day.warmup;
    final cooldown = day.cooldown;
    final total = day.exercises.length;
    final completed = [
      for (var index = 0; index < total; index++)
        if (done.contains('$dayIndex:$index')) index,
    ].length;
    final ratio = total == 0 ? 0.0 : completed / total;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.focus,
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (restRemaining > 0) ...[
                const SizedBox(width: Insets.sm),
                Tooltip(
                  message: restFor == null ? 'Rest' : 'Rest after $restFor',
                  child: InputChip(
                    avatar: const Icon(Icons.timer_outlined, size: 14),
                    label: Text(_PlanViewState.formatSeconds(restRemaining)),
                    onDeleted: onStopRest,
                    deleteButtonTooltipMessage: 'Stop rest timer',
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Insets.sm),
          Row(
            children: [
              Text(
                '$completed/$total done',
                style: theme.textTheme.labelSmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  borderRadius: Radii.pillRadius,
                ),
              ),
            ],
          ),
          if (warmup != null && warmup.isNotEmpty) ...[
            const SizedBox(height: Insets.md),
            _NoteLine(
              theme: theme,
              icon: Icons.directions_walk,
              text: 'Warm-up: $warmup',
            ),
          ],
          const SizedBox(height: Insets.sm),
          for (var index = 0; index < total; index++)
            _ExerciseRow(
              theme: theme,
              exercise: day.exercises[index],
              completed: done.contains('$dayIndex:$index'),
              onToggle: () => onToggle(dayIndex, index),
              onStartRest: () => onStartRest(day.exercises[index]),
            ),
          if (cooldown != null && cooldown.isNotEmpty) ...[
            const SizedBox(height: Insets.xs),
            _NoteLine(
              theme: theme,
              icon: Icons.self_improvement,
              text: 'Cool-down: $cooldown',
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.theme,
    required this.exercise,
    required this.completed,
    required this.onToggle,
    required this.onStartRest,
  });

  final ThemeData theme;
  final Exercise exercise;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onStartRest;

  @override
  Widget build(BuildContext context) {
    final notes = exercise.notes;
    final nameStyle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w600,
      decoration: completed ? TextDecoration.lineThrough : null,
      color: completed
          ? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.onSurface,
    );
    return InkWell(
      borderRadius: Radii.control,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name, style: nameStyle),
                    Text(
                      exercise.prescription,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (notes != null && notes.isNotEmpty)
                      Text(
                        notes,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Rest timer',
              visualDensity: VisualDensity.compact,
              onPressed: onStartRest,
              icon: Icon(
                Icons.timer_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Checkbox(
              value: completed,
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two labeled progress rows comparing the food plan with the calculator.
class _TargetsComparison extends StatelessWidget {
  const _TargetsComparison({
    required this.targets,
    required this.calories,
    required this.protein,
  });

  final MacroTargets targets;
  final int calories;
  final int protein;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(theme, 'Calories', '$calories / ${targets.calories} kcal',
            calories / targets.calories),
        const SizedBox(height: Insets.md),
        _row(theme, 'Protein', '$protein / ${targets.proteinG} g',
            protein / targets.proteinG),
      ],
    );
  }

  Widget _row(ThemeData theme, String label, String value, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.xs),
        LinearProgressIndicator(
          value: ratio.isFinite ? ratio.clamp(0.0, 1.0) : 0.0,
          minHeight: 6,
          borderRadius: Radii.pillRadius,
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.theme, required this.meal});

  final ThemeData theme;
  final FoodMeal meal;

  @override
  Widget build(BuildContext context) {
    final macros = <String>[
      if (meal.calories != null) '${meal.calories} kcal',
      if (meal.proteinG != null) '${meal.proteinG} g protein',
    ];
    return AppCard(
      padding: const EdgeInsets.all(Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.meal,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final macro in macros)
                Padding(
                  padding: const EdgeInsets.only(left: Insets.xs),
                  child: StatChip(label: macro),
                ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          for (final item in meal.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '· $item',
                style: theme.textTheme.bodySmall!.copyWith(height: 1.35),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.theme, required this.icon, required this.text});

  final ThemeData theme;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: Insets.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Insets.sm),
    child: SectionLabel(text),
  );
}
