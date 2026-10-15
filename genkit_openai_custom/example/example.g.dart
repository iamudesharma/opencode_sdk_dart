// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class LookupInput {
  /// Creates a [LookupInput] from a JSON map.
  factory LookupInput.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  LookupInput._(this._json);

  LookupInput({required String packageName}) {
    _json = {'packageName': packageName};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [LookupInput].
  static const SchemanticType<LookupInput> $schema = _LookupInputTypeFactory();

  /// Package name to look up.
  String get packageName {
    return _json['packageName'] as String;
  }

  /// Package name to look up.
  set packageName(String value) {
    _json['packageName'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [LookupInput] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _LookupInputTypeFactory extends SchemanticType<LookupInput> {
  const _LookupInputTypeFactory();

  @override
  LookupInput parse(Object? json) {
    return LookupInput._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'LookupInput',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'packageName': <String, Object?>{'type': 'string'},
      },
      'required': ['packageName'],
    },
    dependencies: [],
  );
}

base class Review {
  /// Creates a [Review] from a JSON map.
  factory Review.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  Review._(this._json);

  Review({
    required String summary,
    required int score,
    required List<String> issues,
  }) {
    _json = {'summary': summary, 'score': score, 'issues': issues};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [Review].
  static const SchemanticType<Review> $schema = _ReviewTypeFactory();

  /// One-sentence summary.
  String get summary {
    return _json['summary'] as String;
  }

  /// One-sentence summary.
  set summary(String value) {
    _json['summary'] = value;
  }

  /// Score from 1 to 10.
  int get score {
    return (_json['score'] as num).toInt();
  }

  /// Score from 1 to 10.
  set score(int value) {
    _json['score'] = value;
  }

  /// Concrete issues found, if any.
  List<String> get issues {
    return (_json['issues'] as List).cast<String>();
  }

  /// Concrete issues found, if any.
  set issues(List<String> value) {
    _json['issues'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [Review] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _ReviewTypeFactory extends SchemanticType<Review> {
  const _ReviewTypeFactory();

  @override
  Review parse(Object? json) {
    return Review._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'Review',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'summary': <String, Object?>{'type': 'string'},
        'score': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 10,
        },
        'issues': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string'},
        },
      },
      'required': ['summary', 'score', 'issues'],
    },
    dependencies: [],
  );
}
