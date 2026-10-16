// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedders.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

/// Options for OpenAI embedding models (`POST /embeddings`).
///
/// `encoding_format` is deliberately absent: the only alternative to the
/// default is `base64`, which returns the vector as a string this client
/// cannot parse, so offering it would only let a caller break the call.
base class OpenAIEmbedderOptions {
  /// Creates a [OpenAIEmbedderOptions] from a JSON map.
  factory OpenAIEmbedderOptions.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  OpenAIEmbedderOptions._(this._json);

  OpenAIEmbedderOptions({int? dimensions, String? user}) {
    _json = {'dimensions': ?dimensions, 'user': ?user};
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [OpenAIEmbedderOptions].
  static const SchemanticType<OpenAIEmbedderOptions> $schema =
      _OpenAIEmbedderOptionsTypeFactory();

  /// Length of the returned vector.
  ///
  /// Only the `text-embedding-3-*` models accept this, and only to shorten:
  /// they are trained so that a prefix of the vector is still a usable
  /// embedding. Defaults to the model's full size.
  int? get dimensions {
    return (_json['dimensions'] as num?)?.toInt();
  }

  /// Length of the returned vector.
  ///
  /// Only the `text-embedding-3-*` models accept this, and only to shorten:
  /// they are trained so that a prefix of the vector is still a usable
  /// embedding. Defaults to the model's full size.
  set dimensions(int? value) {
    if (value == null) {
      _json.remove('dimensions');
    } else {
      _json['dimensions'] = value;
    }
  }

  /// User identifier for abuse detection.
  String? get user {
    return _json['user'] as String?;
  }

  /// User identifier for abuse detection.
  set user(String? value) {
    if (value == null) {
      _json.remove('user');
    } else {
      _json['user'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [OpenAIEmbedderOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _OpenAIEmbedderOptionsTypeFactory
    extends SchemanticType<OpenAIEmbedderOptions> {
  const _OpenAIEmbedderOptionsTypeFactory();

  @override
  OpenAIEmbedderOptions parse(Object? json) {
    return OpenAIEmbedderOptions._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'OpenAIEmbedderOptions',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'dimensions': <String, Object?>{'type': 'integer', 'minimum': 1},
        'user': <String, Object?>{'type': 'string'},
      },
    },
    dependencies: [],
  );
}
