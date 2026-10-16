// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_check.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

base class LiveAnswer {
  /// Creates a [LiveAnswer] from a JSON map.
  factory LiveAnswer.fromJson(Map<String, dynamic> json) => $schema.parse(json);

  LiveAnswer._(this._json);

  LiveAnswer({required String greeting, required int number}) {
    _json = {'greeting': greeting, 'number': number};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [LiveAnswer].
  static const SchemanticType<LiveAnswer> $schema = _LiveAnswerTypeFactory();

  String get greeting {
    return _json['greeting'] as String;
  }

  set greeting(String value) {
    _json['greeting'] = value;
  }

  int get number {
    return (_json['number'] as num).toInt();
  }

  set number(int value) {
    _json['number'] = value;
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [LiveAnswer] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _LiveAnswerTypeFactory extends SchemanticType<LiveAnswer> {
  const _LiveAnswerTypeFactory();

  @override
  LiveAnswer parse(Object? json) {
    return LiveAnswer._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'LiveAnswer',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'greeting': <String, Object?>{'type': 'string'},
        'number': <String, Object?>{'type': 'integer'},
      },
      'required': ['greeting', 'number'],
    },
    dependencies: [],
  );
}
