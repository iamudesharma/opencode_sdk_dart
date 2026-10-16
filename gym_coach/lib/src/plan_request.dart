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
    this.nutritionTargets,
  });

  final FitnessGoal goal;
  final ExperienceLevel level;
  final int daysPerWeek;
  final int sessionMinutes;
  final GymEquipment equipment;
  final String notes;
  final bool includeNutrition;

  /// Targets from the macro calculator, injected into the prompt verbatim.
  final String? nutritionTargets;

  PlanRequest copyWith({
    FitnessGoal? goal,
    ExperienceLevel? level,
    int? daysPerWeek,
    int? sessionMinutes,
    GymEquipment? equipment,
    String? notes,
    bool? includeNutrition,
    String? nutritionTargets,
  }) {
    return PlanRequest(
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      sessionMinutes: sessionMinutes ?? this.sessionMinutes,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
      includeNutrition: includeNutrition ?? this.includeNutrition,
      nutritionTargets: nutritionTargets ?? this.nutritionTargets,
    );
  }

  /// The user-turn prompt.
  ///
  /// [structured] asks for the JSON plan the typed view parses (the plugin
  /// appends the schema itself); the default spells out the section headers
  /// the text view styles while streaming.
  String toPrompt({bool structured = false}) {
    final trimmedNotes = notes.trim();
    final targets = nutritionTargets;
    final athlete = '''
Athlete
- Goal: ${goal.prompt}
- Experience: ${level.label.toLowerCase()} (${level.description})
- Training days: $daysPerWeek per week
- Session length: $sessionMinutes minutes
- Equipment: ${equipment.detail}
${trimmedNotes.isEmpty ? '' : '- Notes from the athlete: $trimmedNotes\n'}${targets == null ? '' : "- Nutrition targets from the athlete's calculator: $targets\n"}''';

    if (structured) {
      return '''
Create a personalized training plan.

$athlete
Return one JSON object matching the requested schema:
- overview: one short paragraph describing the plan and who it is for;
- days: exactly $daysPerWeek entries, each with a name, a one-line focus, an
  optional warmup line, 4-6 exercises (name, a prescription such as
  "3 x 8-12, rest 90s", and an optional note) and an optional cooldown line;
- progression: the exact rule for adding weight or reps in week 2 and beyond,
  plus when to deload;
- meals: ${includeNutrition ? 'the sample food day: breakfast, lunch, dinner and a snack, with rough portions in grams and per-meal calories and protein' : 'null (the athlete asked for no nutrition)'};
- safetyNotes: one short line respecting the athlete's notes.
Every day must fit the session length. Plain JSON only: no markdown, no code
fences, no commentary.''';
    }

    return '''
Create a personalized training plan.

$athlete
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
