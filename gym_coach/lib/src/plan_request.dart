/// The inputs the coach form collects and turns into a model prompt.
library;

enum FitnessGoal {
  buildMuscle('Build muscle', 'build muscle and size'),
  getStronger('Get stronger', 'increase maximal strength on the big lifts'),
  loseFat('Lose fat', 'lose body fat while keeping muscle'),
  endurance('Endurance', 'improve cardiovascular endurance'),
  mobility('Mobility', 'improve mobility, posture and joint health');

  const FitnessGoal(this.label, this.prompt);

  final String label;
  final String prompt;
}

enum ExperienceLevel {
  beginner('Beginner', 'You have never trained consistently.'),
  intermediate('Intermediate', 'You have trained for 6+ months.'),
  advanced('Advanced', 'You have trained for years.');

  const ExperienceLevel(this.label, this.description);

  final String label;
  final String description;
}

enum GymEquipment {
  fullGym('Full gym', 'barbells, dumbbells, machines, cables'),
  dumbbells('Dumbbells', 'a pair of adjustable dumbbells and a bench'),
  bands('Bands', 'resistance bands and a pull-up bar'),
  bodyweight('Bodyweight only', 'no equipment at all');

  const GymEquipment(this.label, this.detail);

  final String label;
  final String detail;
}

/// Everything the user can configure before generating a plan.
final class PlanRequest {
  const PlanRequest({
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.sessionMinutes,
    required this.equipment,
    this.notes = '',
    this.includeNutrition = true,
  });

  final FitnessGoal goal;
  final ExperienceLevel level;
  final int daysPerWeek;
  final int sessionMinutes;
  final GymEquipment equipment;
  final String notes;
  final bool includeNutrition;

  PlanRequest copyWith({
    FitnessGoal? goal,
    ExperienceLevel? level,
    int? daysPerWeek,
    int? sessionMinutes,
    GymEquipment? equipment,
    String? notes,
    bool? includeNutrition,
  }) {
    return PlanRequest(
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
      includeNutrition: includeNutrition ?? this.includeNutrition,
    );
  }

  /// The user-turn prompt. The section headers are spelled out so the model
  /// produces the structure the UI styles while streaming.
  String toPrompt() {
    final trimmedNotes = notes.trim();
    return '''
Create a personalized training plan.

Athlete
- Goal: ${goal.prompt}
- Experience: ${level.label.toLowerCase()} (${level.description})
- Training days: $daysPerWeek per week
- Session length: $sessionMinutes minutes
- Equipment: ${equipment.detail}
${trimmedNotes.isEmpty ? '' : '- Notes from the athlete: $trimmedNotes\n'}
Requirements
- Use these section headers exactly, in capitals on their own line:
${[
      'PLAN OVERVIEW',
      'WEEKLY SPLIT',
      for (var day = 1; day <= daysPerWeek; day++) 'DAY $day',
      'PROGRESSION',
      if (includeNutrition) 'FOOD PLAN',
      'SAFETY NOTES',
    ].map((header) => '  $header').join('\n')}
- Each DAY section: one line naming the focus, a 5-minute warm-up, then 4-6
  exercises written as "- Exercise name — 3 x 8-12, rest 90s", and a closing
  cooldown line.
- PROGRESSION: the exact rule for adding weight or reps in week 2 and beyond,
  plus when to deload.
- Every day must fit the session length; say what to drop if time runs out.
${includeNutrition ? '''
Food plan requirements
- Daily calorie and protein targets, with the calculation in one short line.
- One sample day with breakfast, lunch, dinner and a snack, including rough
  portions in grams.
- Hydration target and one practical tip for the chosen goal.
''' : ''}
- Plain text only: no tables, no code fences, no emoji. Keep it under 700
  words and skip disclaimers beyond one short safety line.''';
  }
}
