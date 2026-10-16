/// Deterministic nutrition math for the coach form.
///
/// The calculator is intentionally simple and explainable: Mifflin-St Jeor for
/// the basal rate, a standard activity multiplier, a goal adjustment, and a
/// protein target per kilogram of body weight. Everything the UI shows can be
/// checked by hand, and the numbers can be handed to the model as targets.
library;

/// Biological sex used by the Mifflin-St Jeor equation.
enum Sex {
  male('Male'),
  female('Female');

  const Sex(this.label);

  final String label;
}

/// Daily activity multiplier.
enum ActivityLevel {
  sedentary('Sedentary', 'Desk job, little movement', 1.2),
  light('Light', 'Walks or light activity 1-3 days', 1.375),
  moderate('Moderate', 'Trains 3-5 days a week', 1.55),
  high('High', 'Trains 6-7 days or an active job', 1.725),
  athlete('Athlete', 'Two sessions a day, physical job', 1.9);

  const ActivityLevel(this.label, this.description, this.factor);

  final String label;
  final String description;
  final double factor;
}

/// Calorie adjustment and protein target for the training goal.
enum NutritionGoal {
  cut('Lose fat', 'Cut', -0.2, 2.2),
  maintain('Maintain', 'Maintain', 0, 1.8),
  bulk('Build muscle', 'Bulk', 0.12, 1.6);

  const NutritionGoal(
    this.label,
    this.shortLabel,
    this.calorieAdjustment,
    this.proteinPerKg,
  );

  final String label;

  /// Short label for compact controls.
  final String shortLabel;

  /// Fraction applied to the TDEE (`-0.2` is a 20% deficit).
  final double calorieAdjustment;

  /// Grams of protein per kilogram of body weight.
  final double proteinPerKg;
}

/// The computed daily targets.
final class MacroTargets {
  /// Creates a targets snapshot.
  const MacroTargets({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });

  /// Mifflin-St Jeor basal metabolic rate, kcal/day.
  final int bmr;

  /// Total daily energy expenditure, kcal/day.
  final int tdee;

  /// Goal-adjusted daily calorie target, rounded to 10 kcal.
  final int calories;

  /// Daily protein target, grams.
  final int proteinG;

  /// Daily fat target (25% of calories), grams.
  final int fatG;

  /// Remaining calories as carbohydrates, grams.
  final int carbsG;

  /// One line for the plan prompt.
  String get promptLine =>
      '~$calories kcal/day, $proteinG g protein, $fatG g fat, '
      '$carbsG g carbs (TDEE $tdee kcal).';

  /// One line for the calculator card.
  String get summary =>
      '$calories kcal · ${proteinG}P / ${fatG}F / ${carbsG}C  (TDEE $tdee)';

  @override
  String toString() => 'MacroTargets($summary)';
}

/// Computes daily targets with the Mifflin-St Jeor equation.
MacroTargets computeMacros({
  required double weightKg,
  required double heightCm,
  required int age,
  required Sex sex,
  required ActivityLevel activity,
  required NutritionGoal goal,
}) {
  final bmr =
      10 * weightKg + 6.25 * heightCm - 5 * age + (sex == Sex.male ? 5 : -161);
  final tdee = bmr * activity.factor;
  final calories =
      ((tdee * (1 + goal.calorieAdjustment)) / 10).round() * 10;
  final proteinG = (goal.proteinPerKg * weightKg).round();
  final fatG = ((calories * 0.25) / 9).round();
  final carbCalories = (calories - proteinG * 4 - fatG * 9).clamp(0, calories);
  final carbsG = (carbCalories / 4).round();

  return MacroTargets(
    bmr: bmr.round(),
    tdee: tdee.round(),
    calories: calories,
    proteinG: proteinG,
    fatG: fatG,
    carbsG: carbsG,
  );
}
