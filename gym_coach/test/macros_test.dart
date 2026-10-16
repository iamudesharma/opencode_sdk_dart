import 'package:flutter_test/flutter_test.dart';
import 'package:gym_coach/src/macros.dart';

void main() {
  group('computeMacros', () {
    test('maintain: Mifflin-St Jeor with the moderate multiplier', () {
      final targets = computeMacros(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: Sex.male,
        activity: ActivityLevel.moderate,
        goal: NutritionGoal.maintain,
      );

      // BMR = 10*80 + 6.25*180 - 5*30 + 5 = 1780.
      expect(targets.bmr, 1780);
      expect(targets.tdee, 2759);
      expect(targets.calories, 2760); // rounded to 10 kcal
      expect(targets.proteinG, 144); // 1.8 g/kg
      expect(targets.fatG, 77); // 25% of calories
      expect(targets.carbsG, 373); // the rest
    });

    test('cut: 20% deficit and a higher protein target', () {
      final targets = computeMacros(
        weightKg: 60,
        heightCm: 165,
        age: 28,
        sex: Sex.female,
        activity: ActivityLevel.light,
        goal: NutritionGoal.cut,
      );

      // BMR = 10*60 + 6.25*165 - 5*28 - 161 = 1330.25.
      expect(targets.bmr, 1330);
      expect(targets.tdee, 1829);
      expect(targets.calories, 1460);
      expect(targets.proteinG, 132); // 2.2 g/kg
      expect(targets.fatG, 41);
      expect(targets.carbsG, 141);
    });

    test('bulk: surplus calories and the lowest protein factor', () {
      final targets = computeMacros(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: Sex.male,
        activity: ActivityLevel.moderate,
        goal: NutritionGoal.bulk,
      );

      expect(targets.calories, 3090); // 2759 * 1.12, rounded
      expect(targets.proteinG, 128); // 1.6 g/kg
      expect(targets.promptLine, contains('~3090 kcal/day'));
      expect(targets.promptLine, contains('128 g protein'));
    });

    test('never produces negative carbohydrates', () {
      final targets = computeMacros(
        weightKg: 140,
        heightCm: 150,
        age: 60,
        sex: Sex.female,
        activity: ActivityLevel.sedentary,
        goal: NutritionGoal.cut,
      );
      expect(targets.carbsG, greaterThanOrEqualTo(0));
      expect(targets.calories, greaterThan(0));
    });

    test('summary and promptLine carry the headline numbers', () {
      final targets = computeMacros(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: Sex.male,
        activity: ActivityLevel.moderate,
        goal: NutritionGoal.maintain,
      );
      expect(targets.summary, contains('2760 kcal'));
      expect(targets.summary, contains('144P'));
      expect(targets.summary, contains('TDEE 2759'));
    });
  });
}
