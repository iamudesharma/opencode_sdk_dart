// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

/// A complete training plan, parsed from the model's JSON answer.
base class WorkoutPlan {
  /// Creates a [WorkoutPlan] from a JSON map.
  factory WorkoutPlan.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  WorkoutPlan._(this._json);

  WorkoutPlan({
    required String overview,
    required List<TrainingDay> days,
    required String progression,
    List<FoodMeal>? meals,
    String? safetyNotes,
  }) {
    _json = {
      'overview': overview,
      'days': days.map((e) => e.toJson()).toList(),
      'progression': progression,
      'meals': ?meals?.map((e) => e.toJson()).toList(),
      'safetyNotes': ?safetyNotes,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [WorkoutPlan].
  static const SchemanticType<WorkoutPlan> $schema = _WorkoutPlanTypeFactory();

  /// One short paragraph summarizing the plan and who it is for.
  String get overview {
    return _json['overview'] as String;
  }

  /// One short paragraph summarizing the plan and who it is for.
  set overview(String value) {
    _json['overview'] = value;
  }

  /// One entry per training day, in order.
  List<TrainingDay> get days {
    return (_json['days'] as List)
        .map((e) => TrainingDay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// One entry per training day, in order.
  set days(List<TrainingDay> value) {
    _json['days'] = value.map((e) => e.toJson()).toList();
  }

  /// The exact progression rule for weeks 2 and beyond, and when to deload.
  String get progression {
    return _json['progression'] as String;
  }

  /// The exact progression rule for weeks 2 and beyond, and when to deload.
  set progression(String value) {
    _json['progression'] = value;
  }

  /// The sample food day; null or empty when nutrition was not requested.
  List<FoodMeal>? get meals {
    return (_json['meals'] as List?)
        ?.map((e) => FoodMeal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The sample food day; null or empty when nutrition was not requested.
  set meals(List<FoodMeal>? value) {
    if (value == null) {
      _json.remove('meals');
    } else {
      _json['meals'] = value.map((e) => e.toJson()).toList();
    }
  }

  /// One short safety line: injuries to respect, when to stop.
  String? get safetyNotes {
    return _json['safetyNotes'] as String?;
  }

  /// One short safety line: injuries to respect, when to stop.
  set safetyNotes(String? value) {
    if (value == null) {
      _json.remove('safetyNotes');
    } else {
      _json['safetyNotes'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [WorkoutPlan] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _WorkoutPlanTypeFactory extends SchemanticType<WorkoutPlan> {
  const _WorkoutPlanTypeFactory();

  @override
  WorkoutPlan parse(Object? json) {
    return WorkoutPlan._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'WorkoutPlan',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'overview': <String, Object?>{'type': 'string'},
        'days': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{r'$ref': r'#/$defs/TrainingDay'},
        },
        'progression': <String, Object?>{'type': 'string'},
        'meals': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{r'$ref': r'#/$defs/FoodMeal'},
        },
        'safetyNotes': <String, Object?>{'type': 'string'},
      },
      'required': ['overview', 'days', 'progression'],
    },
    dependencies: [TrainingDay.$schema, FoodMeal.$schema],
  );
}

/// One training day.
base class TrainingDay {
  /// Creates a [TrainingDay] from a JSON map.
  factory TrainingDay.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  TrainingDay._(this._json);

  TrainingDay({
    required String name,
    required String focus,
    String? warmup,
    required List<Exercise> exercises,
    String? cooldown,
  }) {
    _json = {
      'name': name,
      'focus': focus,
      'warmup': ?warmup,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'cooldown': ?cooldown,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [TrainingDay].
  static const SchemanticType<TrainingDay> $schema = _TrainingDayTypeFactory();

  /// Short day label, e.g. `'Day 1 — Push'` or `'Full body A'`.
  String get name {
    return _json['name'] as String;
  }

  /// Short day label, e.g. `'Day 1 — Push'` or `'Full body A'`.
  set name(String value) {
    _json['name'] = value;
  }

  /// One line naming the focus of the day.
  String get focus {
    return _json['focus'] as String;
  }

  /// One line naming the focus of the day.
  set focus(String value) {
    _json['focus'] = value;
  }

  /// The warm-up line (mobility and ramp-up sets).
  String? get warmup {
    return _json['warmup'] as String?;
  }

  /// The warm-up line (mobility and ramp-up sets).
  set warmup(String? value) {
    if (value == null) {
      _json.remove('warmup');
    } else {
      _json['warmup'] = value;
    }
  }

  /// The working exercises, in order.
  List<Exercise> get exercises {
    return (_json['exercises'] as List)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The working exercises, in order.
  set exercises(List<Exercise> value) {
    _json['exercises'] = value.map((e) => e.toJson()).toList();
  }

  /// The cool-down line.
  String? get cooldown {
    return _json['cooldown'] as String?;
  }

  /// The cool-down line.
  set cooldown(String? value) {
    if (value == null) {
      _json.remove('cooldown');
    } else {
      _json['cooldown'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [TrainingDay] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _TrainingDayTypeFactory extends SchemanticType<TrainingDay> {
  const _TrainingDayTypeFactory();

  @override
  TrainingDay parse(Object? json) {
    return TrainingDay._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'TrainingDay',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'name': <String, Object?>{'type': 'string'},
        'focus': <String, Object?>{'type': 'string'},
        'warmup': <String, Object?>{'type': 'string'},
        'exercises': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{r'$ref': r'#/$defs/Exercise'},
        },
        'cooldown': <String, Object?>{'type': 'string'},
      },
      'required': ['name', 'focus', 'exercises'],
    },
    dependencies: [Exercise.$schema],
  );
}

/// One exercise prescription.
base class Exercise {
  /// Creates a [Exercise] from a JSON map.
  factory Exercise.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  Exercise._(this._json);

  Exercise({
    required String name,
    required String prescription,
    String? notes,
  }) {
    _json = {'name': name, 'prescription': prescription, 'notes': ?notes};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [Exercise].
  static const SchemanticType<Exercise> $schema = _ExerciseTypeFactory();

  /// Exercise name.
  String get name {
    return _json['name'] as String;
  }

  /// Exercise name.
  set name(String value) {
    _json['name'] = value;
  }

  /// Sets, reps and rest, e.g. `'3 x 8-12, rest 90s'`.
  String get prescription {
    return _json['prescription'] as String;
  }

  /// Sets, reps and rest, e.g. `'3 x 8-12, rest 90s'`.
  set prescription(String value) {
    _json['prescription'] = value;
  }

  /// Optional form cue or substitution.
  String? get notes {
    return _json['notes'] as String?;
  }

  /// Optional form cue or substitution.
  set notes(String? value) {
    if (value == null) {
      _json.remove('notes');
    } else {
      _json['notes'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [Exercise] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ExerciseTypeFactory extends SchemanticType<Exercise> {
  const _ExerciseTypeFactory();

  @override
  Exercise parse(Object? json) {
    return Exercise._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'Exercise',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'name': <String, Object?>{'type': 'string'},
        'prescription': <String, Object?>{'type': 'string'},
        'notes': <String, Object?>{'type': 'string'},
      },
      'required': ['name', 'prescription'],
    },
    dependencies: [],
  );
}

/// One meal of the sample day.
base class FoodMeal {
  /// Creates a [FoodMeal] from a JSON map.
  factory FoodMeal.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  FoodMeal._(this._json);

  FoodMeal({
    required String meal,
    required List<String> items,
    int? calories,
    int? proteinG,
  }) {
    _json = {
      'meal': meal,
      'items': items,
      'calories': ?calories,
      'proteinG': ?proteinG,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [FoodMeal].
  static const SchemanticType<FoodMeal> $schema = _FoodMealTypeFactory();

  /// Meal name, e.g. `'Breakfast'`.
  String get meal {
    return _json['meal'] as String;
  }

  /// Meal name, e.g. `'Breakfast'`.
  set meal(String value) {
    _json['meal'] = value;
  }

  /// The foods with rough portions in grams.
  List<String> get items {
    return (_json['items'] as List).cast<String>();
  }

  /// The foods with rough portions in grams.
  set items(List<String> value) {
    _json['items'] = value;
  }

  /// Rough calories for the meal.
  int? get calories {
    return (_json['calories'] as num?)?.toInt();
  }

  /// Rough calories for the meal.
  set calories(int? value) {
    if (value == null) {
      _json.remove('calories');
    } else {
      _json['calories'] = value;
    }
  }

  /// Rough protein for the meal, in grams.
  int? get proteinG {
    return (_json['proteinG'] as num?)?.toInt();
  }

  /// Rough protein for the meal, in grams.
  set proteinG(int? value) {
    if (value == null) {
      _json.remove('proteinG');
    } else {
      _json['proteinG'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [FoodMeal] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _FoodMealTypeFactory extends SchemanticType<FoodMeal> {
  const _FoodMealTypeFactory();

  @override
  FoodMeal parse(Object? json) {
    return FoodMeal._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'FoodMeal',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'meal': <String, Object?>{'type': 'string'},
        'items': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string'},
        },
        'calories': <String, Object?>{'type': 'integer'},
        'proteinG': <String, Object?>{'type': 'integer'},
      },
      'required': ['meal', 'items'],
    },
    dependencies: [],
  );
}
