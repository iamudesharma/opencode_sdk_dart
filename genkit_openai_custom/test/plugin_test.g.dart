// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_test.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class Answer {
  /// Creates a [Answer] from a JSON map.
  factory Answer.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  Answer._(this._json);

  Answer({required String answer}) {
    _json = {'answer': answer};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [Answer].
  static const SchemanticType<Answer> $schema = _AnswerTypeFactory();

  String get answer {
    return _json['answer'] as String;
  }

  set answer(String value) {
    _json['answer'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [Answer] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _AnswerTypeFactory extends SchemanticType<Answer> {
  const _AnswerTypeFactory();

  @override
  Answer parse(Object? json) {
    return Answer._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'Answer',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'answer': <String, Object?>{'type': 'string'},
      },
      'required': ['answer'],
    },
    dependencies: [],
  );
}
