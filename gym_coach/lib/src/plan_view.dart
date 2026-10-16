import 'package:flutter/material.dart';

import 'plan.dart';

/// Renders a typed [WorkoutPlan]: day tabs, exercise rows and meal cards.
class PlanView extends StatefulWidget {
  const PlanView({super.key, required this.plan});

  final WorkoutPlan plan;

  @override
  State<PlanView> createState() => _PlanViewState();
}

class _PlanViewState extends State<PlanView> {
  int _day = 0;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(theme, 'Overview'),
        _Card(theme, child: Text(plan.overview, style: _body(theme))),
        if (days.isNotEmpty) ...[
          const SizedBox(height: 18),
          _SectionTitle(theme, 'Weekly split'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var index = 0; index < days.length; index++)
                ChoiceChip(
                  label: Text(days[index].name),
                  selected: index == selected,
                  onSelected: (_) => setState(() => _day = index),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _DayCard(theme: theme, day: days[selected]),
        ],
        const SizedBox(height: 18),
        _SectionTitle(theme, 'Progression'),
        _Card(theme, child: Text(plan.progression, style: _body(theme))),
        if (meals.isNotEmpty) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _SectionTitle(theme, 'Food plan')),
              if (totalCalories > 0)
                Text(
                  '$totalCalories kcal · $totalProtein g protein',
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          for (final meal in meals)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MealCard(theme: theme, meal: meal),
            ),
        ],
        if (safety != null && safety.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionTitle(theme, 'Safety notes'),
          _Card(
            theme,
            child: Text(
              safety,
              style: _body(theme).copyWith(color: theme.colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }

  TextStyle _body(ThemeData theme) =>
      theme.textTheme.bodyMedium!.copyWith(height: 1.45);
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.theme, required this.day});

  final ThemeData theme;
  final TrainingDay day;

  @override
  Widget build(BuildContext context) {
    final warmup = day.warmup;
    final cooldown = day.cooldown;
    return _Card(
      theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            day.focus,
            style: theme.textTheme.titleSmall!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (warmup != null && warmup.isNotEmpty) ...[
            const SizedBox(height: 8),
            _NoteLine(theme: theme, icon: Icons.directions_walk, text: 'Warm-up: $warmup'),
          ],
          const SizedBox(height: 10),
          for (final exercise in day.exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          exercise.prescription,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (exercise.notes case final notes?
                            when notes.isNotEmpty)
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
                ],
              ),
            ),
          if (cooldown != null && cooldown.isNotEmpty)
            _NoteLine(theme: theme, icon: Icons.self_improvement, text: 'Cool-down: $cooldown'),
        ],
      ),
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
    return _Card(
      theme,
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
                  padding: const EdgeInsets.only(left: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      macro,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in meal.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('· $item', style: theme.textTheme.bodySmall),
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
        const SizedBox(width: 6),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.theme, this.text);

  final ThemeData theme;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall!.copyWith(
        letterSpacing: 0.8,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card(this.theme, {required this.child});

  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
      ),
    ),
    child: child,
  );
}
