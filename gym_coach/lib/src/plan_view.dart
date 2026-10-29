import 'dart:async';

import 'package:flutter/material.dart';

import 'macros.dart';
import 'plan.dart';
import 'style.dart';

/// Renders a typed [WorkoutPlan]: day tabs, an interactive day card with
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
    final tokens = context.fit;
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
        AppCard(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            Insets.xl,
            Insets.xl,
            Insets.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Overview'),
              const SizedBox(height: Insets.md),
              Text(
                plan.overview,
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontSize: 21,
                  height: 1.35,
                  letterSpacing: -0.2,
                  color: tokens.text,
                ),
              ),
              const SizedBox(height: Insets.lg),
              Wrap(
                spacing: Insets.sm,
                runSpacing: Insets.sm,
                children: [
                  if (days.isNotEmpty)
                    StatChip(
                      label:
                          '${days.length} '
                          'DAY${days.length == 1 ? '' : 'S'}',
                      dot: tokens.accent,
                    ),
                  if (meals.isNotEmpty)
                    StatChip(
                      label:
                          '${meals.length} '
                          'MEAL${meals.length == 1 ? '' : 'S'}',
                      dot: tokens.ember,
                    ),
                  if (targets != null)
                    StatChip(label: 'MACROS TRACKED', dot: tokens.sage),
                ],
              ),
            ],
          ),
        ),
        if (days.isNotEmpty) ...[
          const SizedBox(height: Insets.xxl),
          const SectionLabel('Weekly split'),
          const SizedBox(height: Insets.md),
          _DayTabs(
            days: days,
            selected: selected,
            onSelected: (index) => setState(() => _day = index),
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
          const SizedBox(height: Insets.xxl),
          const SectionLabel('Targets vs plan'),
          const SizedBox(height: Insets.md),
          AppCard(
            child: _TargetsComparison(
              targets: targets,
              calories: totalCalories,
              protein: totalProtein,
            ),
          ),
        ],
        const SizedBox(height: Insets.xxl),
        const SectionLabel('Progression'),
        const SizedBox(height: Insets.md),
        AppCard(
          child: Text(
            plan.progression,
            style: theme.textTheme.bodyMedium!.copyWith(
              height: 1.6,
              color: tokens.muted,
            ),
          ),
        ),
        if (meals.isNotEmpty) ...[
          const SizedBox(height: Insets.xxl),
          SectionLabel(
            'Food plan',
            trailing: totalCalories > 0
                ? StatChip(
                    label: '$totalCalories KCAL · $totalProtein G',
                    dot: tokens.ember,
                  )
                : null,
          ),
          const SizedBox(height: Insets.md),
          for (var index = 0; index < meals.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.sm),
              child: _MealCard(theme: theme, meal: meals[index], index: index),
            ),
        ],
        if (safety != null && safety.isNotEmpty) ...[
          const SizedBox(height: Insets.xxl),
          const SectionLabel('Safety notes'),
          const SizedBox(height: Insets.md),
          Container(
            padding: const EdgeInsets.all(Insets.lg),
            decoration: BoxDecoration(
              color: tokens.danger.withValues(alpha: 0.06),
              borderRadius: Radii.card,
              border: Border.all(color: tokens.danger.withValues(alpha: 0.28)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  size: 17,
                  color: tokens.danger,
                ),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: Text(
                    safety,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: tokens.danger,
                      height: 1.5,
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
}

/// The horizontal day selector: a number, a name and an active underline.
class _DayTabs extends StatelessWidget {
  const _DayTabs({
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  final List<TrainingDay> days;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    return Container(
      decoration: BoxDecoration(
        color: tokens.raised,
        borderRadius: Radii.card,
        border: Border.all(color: tokens.line),
      ),
      padding: const EdgeInsets.all(Insets.xs),
      child: Row(
        children: [
          for (var index = 0; index < days.length; index++)
            Expanded(
              child: InkWell(
                borderRadius: Radii.control,
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Insets.sm,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: index == selected
                        ? tokens.accent.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: Radii.control,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY ${index + 1}',
                        style: kFitMonoStyle.copyWith(
                          fontSize: 8.5,
                          letterSpacing: 1.1,
                          color: index == selected ? tokens.accent : tokens.dim,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        days[index].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kFitMonoStyle.copyWith(
                          fontSize: 10.5,
                          color: index == selected ? tokens.text : tokens.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
    final tokens = context.fit;
    final warmup = day.warmup;
    final cooldown = day.cooldown;
    final total = day.exercises.length;
    final completed = [
      for (var index = 0; index < total; index++)
        if (done.contains('$dayIndex:$index')) index,
    ].length;
    final ratio = total == 0 ? 0.0 : completed / total;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.xl,
              Insets.xl,
              Insets.xl,
              Insets.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.focus.toUpperCase(),
                        style: theme.textTheme.labelSmall!.copyWith(
                          fontSize: 8.5,
                          letterSpacing: 1.6,
                          color: tokens.accent,
                        ),
                      ),
                      const SizedBox(height: Insets.sm),
                      Text(
                        '$completed/$total done',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontSize: 26,
                          color: tokens.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'exercises complete',
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: 11,
                          color: tokens.dim,
                        ),
                      ),
                    ],
                  ),
                ),
                if (restRemaining > 0) ...[
                  const SizedBox(width: Insets.sm),
                  Tooltip(
                    message: restFor == null ? 'Rest' : 'Rest after $restFor',
                    child: InputChip(
                      avatar: Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: tokens.accent,
                      ),
                      label: Text(
                        _PlanViewState.formatSeconds(restRemaining),
                        style: kFitMonoStyle.copyWith(
                          fontSize: 11,
                          color: tokens.accent,
                        ),
                      ),
                      onDeleted: onStopRest,
                      deleteButtonTooltipMessage: 'Stop rest timer',
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: tokens.accent.withValues(alpha: 0.35),
                      ),
                      backgroundColor: tokens.accent.withValues(alpha: 0.08),
                    ),
                  ),
                  const SizedBox(width: Insets.sm),
                ],
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 58,
                        height: 58,
                        child: CircularProgressIndicator(
                          value: ratio,
                          strokeWidth: 3,
                          backgroundColor: tokens.line,
                          color: tokens.accent,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: kFitMonoStyle.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: tokens.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
            child: ClipRRect(
              borderRadius: Radii.pillRadius,
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 3,
                backgroundColor: tokens.line,
                color: tokens.accent,
              ),
            ),
          ),
          if (warmup != null && warmup.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                Insets.md,
                Insets.xl,
                0,
              ),
              child: _NoteLine(
                theme: theme,
                icon: Icons.directions_walk,
                text: 'Warm-up · $warmup',
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.md,
              Insets.md,
              Insets.md,
              Insets.xs,
            ),
            child: Column(
              children: [
                for (var index = 0; index < total; index++)
                  _ExerciseRow(
                    theme: theme,
                    index: index,
                    exercise: day.exercises[index],
                    completed: done.contains('$dayIndex:$index'),
                    onToggle: () => onToggle(dayIndex, index),
                    onStartRest: () => onStartRest(day.exercises[index]),
                  ),
              ],
            ),
          ),
          if (cooldown != null && cooldown.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.xl,
                Insets.xs,
                Insets.xl,
                Insets.lg,
              ),
              child: _NoteLine(
                theme: theme,
                icon: Icons.self_improvement,
                text: 'Cool-down · $cooldown',
              ),
            )
          else
            const SizedBox(height: Insets.sm),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.theme,
    required this.index,
    required this.exercise,
    required this.completed,
    required this.onToggle,
    required this.onStartRest,
  });

  final ThemeData theme;
  final int index;
  final Exercise exercise;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onStartRest;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    final notes = exercise.notes;
    final nameStyle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w600,
      decoration: completed ? TextDecoration.lineThrough : null,
      decorationColor: tokens.dim,
      color: completed ? tokens.dim : tokens.text,
    );
    return InkWell(
      borderRadius: Radii.control,
      onTap: onToggle,
      hoverColor: tokens.accent.withValues(alpha: 0.035),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Insets.sm,
          Insets.sm,
          Insets.xs,
          Insets.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: kFitMonoStyle.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.4,
                    color: completed ? tokens.dim : tokens.lineStrong,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name, style: nameStyle),
                  const SizedBox(height: 1),
                  Text(
                    exercise.prescription,
                    style: kFitMonoStyle.copyWith(
                      fontSize: 10.5,
                      height: 1.4,
                      color: completed ? tokens.dim : tokens.muted,
                    ),
                  ),
                  if (notes != null && notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        notes,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: tokens.dim,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Insets.xs),
            IconButton(
              tooltip: 'Rest timer',
              visualDensity: VisualDensity.compact,
              onPressed: onStartRest,
              icon: Icon(Icons.timer_outlined, size: 17, color: tokens.dim),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: completed,
                onChanged: (_) => onToggle(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
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
    final tokens = context.fit;
    final calorieRatio = targets.calories <= 0
        ? 0.0
        : calories / targets.calories;
    final proteinRatio = targets.proteinG <= 0
        ? 0.0
        : protein / targets.proteinG;
    final onTarget =
        calorieRatio >= 0.9 && calorieRatio <= 1.1 && proteinRatio >= 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              onTarget ? 'On target' : 'Away from target',
              style: theme.textTheme.labelSmall!.copyWith(
                fontSize: 9,
                letterSpacing: 1.2,
                color: onTarget ? tokens.accent : tokens.ember,
              ),
            ),
            const Spacer(),
            StatChip(
              label: onTarget ? 'ON TRACK' : 'ADJUST',
              dot: onTarget ? tokens.accent : tokens.ember,
            ),
          ],
        ),
        const SizedBox(height: Insets.lg),
        _row(
          context,
          theme,
          'Calories',
          '$calories / ${targets.calories} kcal',
          calorieRatio,
          tokens.ember,
        ),
        const SizedBox(height: Insets.lg),
        _row(
          context,
          theme,
          'Protein',
          '$protein / ${targets.proteinG} g',
          proteinRatio,
          tokens.sage,
        ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    double ratio,
    Color color,
  ) {
    final tokens = context.fit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.text,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: kFitMonoStyle.copyWith(
                fontSize: 10.5,
                color: tokens.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.sm),
        ClipRRect(
          borderRadius: Radii.pillRadius,
          child: LinearProgressIndicator(
            value: ratio.isFinite ? ratio.clamp(0.0, 1.0) : 0.0,
            minHeight: 4,
            backgroundColor: tokens.line,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.theme,
    required this.meal,
    required this.index,
  });

  final ThemeData theme;
  final FoodMeal meal;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    final macros = <String>[
      if (meal.calories != null) '${meal.calories} kcal',
      if (meal.proteinG != null) '${meal.proteinG} g protein',
    ];
    return AppCard(
      padding: const EdgeInsets.all(Insets.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${index + 1}'.padLeft(2, '0'),
                style: kFitMonoStyle.copyWith(fontSize: 9, color: tokens.dim),
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Text(
                  meal.meal,
                  style: theme.textTheme.titleSmall!.copyWith(
                    color: tokens.text,
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
          const SizedBox(height: Insets.md),
          Container(height: 1, color: tokens.line),
          const SizedBox(height: Insets.md),
          for (final item in meal.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: tokens.dim,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: tokens.muted,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({
    required this.theme,
    required this.icon,
    required this.text,
  });

  final ThemeData theme;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.fit;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: tokens.dim),
        const SizedBox(width: Insets.sm),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall!.copyWith(
              fontSize: 11,
              color: tokens.muted,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
