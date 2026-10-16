// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'options.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

/// Chat options for OpenAI and OpenAI-compatible chat models.
///
/// Pass an instance to `ai.generate(config: ...)` (or
/// `ai.generateStream(config: ...)`) together with a model reference from
/// [OpenAICompatPluginHandle.model]. Every field is optional; null fields are
/// omitted from the request.
base class OpenAIChatOptions {
  /// Creates a [OpenAIChatOptions] from a JSON map.
  factory OpenAIChatOptions.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  OpenAIChatOptions._(this._json);

  OpenAIChatOptions({
    String? version,
    double? temperature,
    double? topP,
    int? maxTokens,
    List<String>? stop,
    double? presencePenalty,
    double? frequencyPenalty,
    int? seed,
    String? user,
    bool? jsonMode,
    bool? strictSchema,
    bool? includeUsageInStream,
    String? reasoningEffort,
    String? verbosity,
    String? visualDetailLevel,
    Map<String, dynamic>? extraBody,
  }) {
    _json = {
      'version': ?version,
      'temperature': ?temperature,
      'topP': ?topP,
      'maxTokens': ?maxTokens,
      'stop': ?stop,
      'presencePenalty': ?presencePenalty,
      'frequencyPenalty': ?frequencyPenalty,
      'seed': ?seed,
      'user': ?user,
      'jsonMode': ?jsonMode,
      'strictSchema': ?strictSchema,
      'includeUsageInStream': ?includeUsageInStream,
      'reasoningEffort': ?reasoningEffort,
      'verbosity': ?verbosity,
      'visualDetailLevel': ?visualDetailLevel,
      'extraBody': ?extraBody,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [OpenAIChatOptions].
  static const SchemanticType<OpenAIChatOptions> $schema =
      _OpenAIChatOptionsTypeFactory();

  /// Model snapshot override, e.g. `'gpt-4o-2024-08-06'`.
  String? get version {
    return _json['version'] as String?;
  }

  /// Model snapshot override, e.g. `'gpt-4o-2024-08-06'`.
  set version(String? value) {
    if (value == null) {
      _json.remove('version');
    } else {
      _json['version'] = value;
    }
  }

  /// Sampling temperature (0.0 - 2.0).
  double? get temperature {
    return (_json['temperature'] as num?)?.toDouble();
  }

  /// Sampling temperature (0.0 - 2.0).
  set temperature(double? value) {
    if (value == null) {
      _json.remove('temperature');
    } else {
      _json['temperature'] = value;
    }
  }

  /// Nucleus sampling (0.0 - 1.0).
  double? get topP {
    return (_json['topP'] as num?)?.toDouble();
  }

  /// Nucleus sampling (0.0 - 1.0).
  set topP(double? value) {
    if (value == null) {
      _json.remove('topP');
    } else {
      _json['topP'] = value;
    }
  }

  /// Maximum number of tokens to generate. Sent as `max_completion_tokens`
  /// for OpenAI models and as `max_tokens` when the dialect says so.
  int? get maxTokens {
    return (_json['maxTokens'] as num?)?.toInt();
  }

  /// Maximum number of tokens to generate. Sent as `max_completion_tokens`
  /// for OpenAI models and as `max_tokens` when the dialect says so.
  set maxTokens(int? value) {
    if (value == null) {
      _json.remove('maxTokens');
    } else {
      _json['maxTokens'] = value;
    }
  }

  /// Up to 4 sequences where the model stops generating.
  List<String>? get stop {
    return (_json['stop'] as List?)?.cast<String>();
  }

  /// Up to 4 sequences where the model stops generating.
  set stop(List<String>? value) {
    if (value == null) {
      _json.remove('stop');
    } else {
      _json['stop'] = value;
    }
  }

  /// Penalty applied to tokens already present in the text (-2.0 - 2.0).
  double? get presencePenalty {
    return (_json['presencePenalty'] as num?)?.toDouble();
  }

  /// Penalty applied to tokens already present in the text (-2.0 - 2.0).
  set presencePenalty(double? value) {
    if (value == null) {
      _json.remove('presencePenalty');
    } else {
      _json['presencePenalty'] = value;
    }
  }

  /// Penalty applied to tokens based on their frequency (-2.0 - 2.0).
  double? get frequencyPenalty {
    return (_json['frequencyPenalty'] as num?)?.toDouble();
  }

  /// Penalty applied to tokens based on their frequency (-2.0 - 2.0).
  set frequencyPenalty(double? value) {
    if (value == null) {
      _json.remove('frequencyPenalty');
    } else {
      _json['frequencyPenalty'] = value;
    }
  }

  /// Best-effort determinism seed.
  int? get seed {
    return (_json['seed'] as num?)?.toInt();
  }

  /// Best-effort determinism seed.
  set seed(int? value) {
    if (value == null) {
      _json.remove('seed');
    } else {
      _json['seed'] = value;
    }
  }

  /// Stable end-user identifier for abuse monitoring.
  String? get user {
    return _json['user'] as String?;
  }

  /// Stable end-user identifier for abuse monitoring.
  set user(String? value) {
    if (value == null) {
      _json.remove('user');
    } else {
      _json['user'] = value;
    }
  }

  /// Requests `{"type": "json_object"}` when the request carries no output
  /// configuration. Ignored when Genkit already asked for structured output.
  bool? get jsonMode {
    return _json['jsonMode'] as bool?;
  }

  /// Requests `{"type": "json_object"}` when the request carries no output
  /// configuration. Ignored when Genkit already asked for structured output.
  set jsonMode(bool? value) {
    if (value == null) {
      _json.remove('jsonMode');
    } else {
      _json['jsonMode'] = value;
    }
  }

  /// Strictness for `json_schema` structured outputs. Defaults to `false`
  /// because OpenAI's strict mode rejects schemas with optional fields.
  bool? get strictSchema {
    return _json['strictSchema'] as bool?;
  }

  /// Strictness for `json_schema` structured outputs. Defaults to `false`
  /// because OpenAI's strict mode rejects schemas with optional fields.
  set strictSchema(bool? value) {
    if (value == null) {
      _json.remove('strictSchema');
    } else {
      _json['strictSchema'] = value;
    }
  }

  /// Per-request override for `stream_options: {"include_usage": true}`.
  /// Defaults to the dialect's [OpenAICompatDialect.includeUsageInStream].
  bool? get includeUsageInStream {
    return _json['includeUsageInStream'] as bool?;
  }

  /// Per-request override for `stream_options: {"include_usage": true}`.
  /// Defaults to the dialect's [OpenAICompatDialect.includeUsageInStream].
  set includeUsageInStream(bool? value) {
    if (value == null) {
      _json.remove('includeUsageInStream');
    } else {
      _json['includeUsageInStream'] = value;
    }
  }

  /// Reasoning effort for models that support it.
  String? get reasoningEffort {
    return _json['reasoningEffort'] as String?;
  }

  /// Reasoning effort for models that support it.
  set reasoningEffort(String? value) {
    if (value == null) {
      _json.remove('reasoningEffort');
    } else {
      _json['reasoningEffort'] = value;
    }
  }

  /// Output verbosity for models that support it.
  String? get verbosity {
    return _json['verbosity'] as String?;
  }

  /// Output verbosity for models that support it.
  set verbosity(String? value) {
    if (value == null) {
      _json.remove('verbosity');
    } else {
      _json['verbosity'] = value;
    }
  }

  /// Image detail override applied to media parts.
  String? get visualDetailLevel {
    return _json['visualDetailLevel'] as String?;
  }

  /// Image detail override applied to media parts.
  set visualDetailLevel(String? value) {
    if (value == null) {
      _json.remove('visualDetailLevel');
    } else {
      _json['visualDetailLevel'] = value;
    }
  }

  /// Extra fields merged verbatim into the chat completion body. Use this for
  /// host-specific switches (for example DeepSeek's `thinking`).
  Map<String, dynamic>? get extraBody {
    return (_json['extraBody'] as Map?)?.cast<String, dynamic>();
  }

  /// Extra fields merged verbatim into the chat completion body. Use this for
  /// host-specific switches (for example DeepSeek's `thinking`).
  set extraBody(Map<String, dynamic>? value) {
    if (value == null) {
      _json.remove('extraBody');
    } else {
      _json['extraBody'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [OpenAIChatOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _OpenAIChatOptionsTypeFactory
    extends SchemanticType<OpenAIChatOptions> {
  const _OpenAIChatOptionsTypeFactory();

  @override
  OpenAIChatOptions parse(Object? json) {
    return OpenAIChatOptions._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'OpenAIChatOptions',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'version': <String, Object?>{'type': 'string'},
        'temperature': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 2,
        },
        'topP': <String, Object?>{'type': 'number', 'minimum': 0, 'maximum': 1},
        'maxTokens': <String, Object?>{'type': 'integer'},
        'stop': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string'},
        },
        'presencePenalty': <String, Object?>{
          'type': 'number',
          'minimum': -2,
          'maximum': 2,
        },
        'frequencyPenalty': <String, Object?>{
          'type': 'number',
          'minimum': -2,
          'maximum': 2,
        },
        'seed': <String, Object?>{'type': 'integer'},
        'user': <String, Object?>{'type': 'string'},
        'jsonMode': <String, Object?>{'type': 'boolean'},
        'strictSchema': <String, Object?>{'type': 'boolean'},
        'includeUsageInStream': <String, Object?>{'type': 'boolean'},
        'reasoningEffort': <String, Object?>{
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
        },
        'verbosity': <String, Object?>{
          'type': 'string',
          'enum': ['low', 'medium', 'high'],
        },
        'visualDetailLevel': <String, Object?>{
          'type': 'string',
          'enum': ['auto', 'low', 'high'],
        },
        'extraBody': <String, Object?>{
          'type': 'object',
          'additionalProperties': <String, Object?>{},
        },
      },
    },
    dependencies: [],
  );
}

/// Options for models served by an OpenCode server through the `openCode`
/// plugin.
///
/// The server runs its own agent, so these options select which agent and
/// which model variant (thinking level, reasoning mode, ...) answer; sampling
/// parameters belong to the server's own model configuration.
base class OpenCodeModelOptions {
  /// Creates a [OpenCodeModelOptions] from a JSON map.
  factory OpenCodeModelOptions.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  OpenCodeModelOptions._(this._json);

  OpenCodeModelOptions({
    String? variant,
    String? agent,
    String? sessionID,
    Map<String, dynamic>? metadata,
  }) {
    _json = {
      'variant': ?variant,
      'agent': ?agent,
      'sessionID': ?sessionID,
      'metadata': ?metadata,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [OpenCodeModelOptions].
  static const SchemanticType<OpenCodeModelOptions> $schema =
      _OpenCodeModelOptionsTypeFactory();

  /// Model variant id as reported by the server, for example `'low'`,
  /// `'medium'` or `'high'` for models with thinking levels.
  String? get variant {
    return _json['variant'] as String?;
  }

  /// Model variant id as reported by the server, for example `'low'`,
  /// `'medium'` or `'high'` for models with thinking levels.
  set variant(String? value) {
    if (value == null) {
      _json.remove('variant');
    } else {
      _json['variant'] = value;
    }
  }

  /// Agent id used for the session, for example `'build'` or `'plan'`.
  String? get agent {
    return _json['agent'] as String?;
  }

  /// Agent id used for the session, for example `'build'` or `'plan'`.
  set agent(String? value) {
    if (value == null) {
      _json.remove('agent');
    } else {
      _json['agent'] = value;
    }
  }

  /// Reuse an existing server session instead of creating an ephemeral one.
  ///
  /// The session is left in place afterwards, so the model keeps its
  /// server-side memory across calls. The requested model (and [agent], when
  /// set) are switched on the session before the prompt is sent.
  String? get sessionID {
    return _json['sessionID'] as String?;
  }

  /// Reuse an existing server session instead of creating an ephemeral one.
  ///
  /// The session is left in place afterwards, so the model keeps its
  /// server-side memory across calls. The requested model (and [agent], when
  /// set) are switched on the session before the prompt is sent.
  set sessionID(String? value) {
    if (value == null) {
      _json.remove('sessionID');
    } else {
      _json['sessionID'] = value;
    }
  }

  /// Metadata attached to the prompt sent to the server.
  Map<String, dynamic>? get metadata {
    return (_json['metadata'] as Map?)?.cast<String, dynamic>();
  }

  /// Metadata attached to the prompt sent to the server.
  set metadata(Map<String, dynamic>? value) {
    if (value == null) {
      _json.remove('metadata');
    } else {
      _json['metadata'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [OpenCodeModelOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _OpenCodeModelOptionsTypeFactory
    extends SchemanticType<OpenCodeModelOptions> {
  const _OpenCodeModelOptionsTypeFactory();

  @override
  OpenCodeModelOptions parse(Object? json) {
    return OpenCodeModelOptions._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'OpenCodeModelOptions',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'variant': <String, Object?>{'type': 'string'},
        'agent': <String, Object?>{'type': 'string'},
        'sessionID': <String, Object?>{'type': 'string'},
        'metadata': <String, Object?>{
          'type': 'object',
          'additionalProperties': <String, Object?>{},
        },
      },
    },
    dependencies: [],
  );
}
