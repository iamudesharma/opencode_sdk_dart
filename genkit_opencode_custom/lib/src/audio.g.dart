// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

/// Options for OpenAI text-to-speech models (`POST /audio/speech`).
base class OpenAISpeechOptions {
  /// Creates a [OpenAISpeechOptions] from a JSON map.
  factory OpenAISpeechOptions.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  OpenAISpeechOptions._(this._json);

  OpenAISpeechOptions({
    String? version,
    String? voice,
    String? instructions,
    double? speed,
    String? responseFormat,
  }) {
    _json = {
      'version': ?version,
      'voice': ?voice,
      'instructions': ?instructions,
      'speed': ?speed,
      'responseFormat': ?responseFormat,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [OpenAISpeechOptions].
  static const SchemanticType<OpenAISpeechOptions> $schema =
      _OpenAISpeechOptionsTypeFactory();

  /// Model snapshot override, e.g. `'tts-1-1106'`.
  String? get version {
    return _json['version'] as String?;
  }

  /// Model snapshot override, e.g. `'tts-1-1106'`.
  set version(String? value) {
    if (value == null) {
      _json.remove('version');
    } else {
      _json['version'] = value;
    }
  }

  /// Voice used to render the audio (e.g. `'alloy'`, `'sage'`, `'coral'`).
  ///
  /// Left free-form on purpose: hosts add voices without warning, and an enum
  /// here would reject them until this package shipped a new release.
  /// Defaults to `'alloy'`.
  String? get voice {
    return _json['voice'] as String?;
  }

  /// Voice used to render the audio (e.g. `'alloy'`, `'sage'`, `'coral'`).
  ///
  /// Left free-form on purpose: hosts add voices without warning, and an enum
  /// here would reject them until this package shipped a new release.
  /// Defaults to `'alloy'`.
  set voice(String? value) {
    if (value == null) {
      _json.remove('voice');
    } else {
      _json['voice'] = value;
    }
  }

  /// Tone and delivery guidance, e.g. `'Speak in a calm, warm tone.'`
  ///
  /// Only honored by `gpt-4o-mini-tts`; the `tts-1` family ignores it.
  String? get instructions {
    return _json['instructions'] as String?;
  }

  /// Tone and delivery guidance, e.g. `'Speak in a calm, warm tone.'`
  ///
  /// Only honored by `gpt-4o-mini-tts`; the `tts-1` family ignores it.
  set instructions(String? value) {
    if (value == null) {
      _json.remove('instructions');
    } else {
      _json['instructions'] = value;
    }
  }

  /// Playback speed multiplier (0.25 - 4.0).
  double? get speed {
    return (_json['speed'] as num?)?.toDouble();
  }

  /// Playback speed multiplier (0.25 - 4.0).
  set speed(double? value) {
    if (value == null) {
      _json.remove('speed');
    } else {
      _json['speed'] = value;
    }
  }

  /// Audio container for the generated speech. Defaults to `'mp3'`.
  String? get responseFormat {
    return _json['responseFormat'] as String?;
  }

  /// Audio container for the generated speech. Defaults to `'mp3'`.
  set responseFormat(String? value) {
    if (value == null) {
      _json.remove('responseFormat');
    } else {
      _json['responseFormat'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [OpenAISpeechOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _OpenAISpeechOptionsTypeFactory
    extends SchemanticType<OpenAISpeechOptions> {
  const _OpenAISpeechOptionsTypeFactory();

  @override
  OpenAISpeechOptions parse(Object? json) {
    return OpenAISpeechOptions._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'OpenAISpeechOptions',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'version': <String, Object?>{'type': 'string'},
        'voice': <String, Object?>{'type': 'string'},
        'instructions': <String, Object?>{'type': 'string'},
        'speed': <String, Object?>{
          'type': 'number',
          'minimum': 0.25,
          'maximum': 4.0,
        },
        'responseFormat': <String, Object?>{
          'type': 'string',
          'enum': ['mp3', 'opus', 'aac', 'flac', 'wav', 'pcm'],
        },
      },
    },
    dependencies: [],
  );
}

/// Options for OpenAI speech-to-text models (`POST /audio/transcriptions`).
base class OpenAITranscriptionOptions {
  /// Creates a [OpenAITranscriptionOptions] from a JSON map.
  factory OpenAITranscriptionOptions.fromJson(Map<String, dynamic> json) =>
      $schema.parse(json);

  OpenAITranscriptionOptions._(this._json);

  OpenAITranscriptionOptions({
    String? version,
    String? language,
    String? prompt,
    double? temperature,
    String? responseFormat,
    List<String>? timestampGranularities,
    Object? chunkingStrategy,
    List<String>? include,
    bool? translate,
  }) {
    _json = {
      'version': ?version,
      'language': ?language,
      'prompt': ?prompt,
      'temperature': ?temperature,
      'responseFormat': ?responseFormat,
      'timestampGranularities': ?timestampGranularities,
      'chunkingStrategy': ?chunkingStrategy,
      'include': ?include,
      'translate': ?translate,
    };
  }

  late final Map<String, dynamic> _json;

  /// The JSON schema and type descriptor for [OpenAITranscriptionOptions].
  static const SchemanticType<OpenAITranscriptionOptions> $schema =
      _OpenAITranscriptionOptionsTypeFactory();

  /// Model snapshot override, e.g. `'whisper-1'`.
  String? get version {
    return _json['version'] as String?;
  }

  /// Model snapshot override, e.g. `'whisper-1'`.
  set version(String? value) {
    if (value == null) {
      _json.remove('version');
    } else {
      _json['version'] = value;
    }
  }

  /// ISO-639-1 code of the spoken language, e.g. `'en'`, `'es'`.
  ///
  /// Supplying it improves accuracy and latency. Not accepted by the
  /// translation endpoint, which always outputs English.
  String? get language {
    return _json['language'] as String?;
  }

  /// ISO-639-1 code of the spoken language, e.g. `'en'`, `'es'`.
  ///
  /// Supplying it improves accuracy and latency. Not accepted by the
  /// translation endpoint, which always outputs English.
  set language(String? value) {
    if (value == null) {
      _json.remove('language');
    } else {
      _json['language'] = value;
    }
  }

  /// Decoding hint: vocabulary, names, or the expected style.
  ///
  /// Distinct from the Genkit prompt. When unset, the text content of the
  /// request message is used instead.
  String? get prompt {
    return _json['prompt'] as String?;
  }

  /// Decoding hint: vocabulary, names, or the expected style.
  ///
  /// Distinct from the Genkit prompt. When unset, the text content of the
  /// request message is used instead.
  set prompt(String? value) {
    if (value == null) {
      _json.remove('prompt');
    } else {
      _json['prompt'] = value;
    }
  }

  /// Sampling temperature (0.0 - 1.0).
  double? get temperature {
    return (_json['temperature'] as num?)?.toDouble();
  }

  /// Sampling temperature (0.0 - 1.0).
  set temperature(double? value) {
    if (value == null) {
      _json.remove('temperature');
    } else {
      _json['temperature'] = value;
    }
  }

  /// Transcript format. Defaults to `'json'`.
  ///
  /// `'srt'` and `'vtt'` return subtitle markup, `'verbose_json'` adds timing
  /// metadata. Whatever the format, the transcript is returned as a single
  /// text part; the untouched payload is available on `ModelResponse.raw`.
  String? get responseFormat {
    return _json['responseFormat'] as String?;
  }

  /// Transcript format. Defaults to `'json'`.
  ///
  /// `'srt'` and `'vtt'` return subtitle markup, `'verbose_json'` adds timing
  /// metadata. Whatever the format, the transcript is returned as a single
  /// text part; the untouched payload is available on `ModelResponse.raw`.
  set responseFormat(String? value) {
    if (value == null) {
      _json.remove('responseFormat');
    } else {
      _json['responseFormat'] = value;
    }
  }

  /// Timestamp detail to include: `'word'` and/or `'segment'`.
  ///
  /// Requires `responseFormat: 'verbose_json'`, and is only supported by
  /// `whisper-1`.
  List<String>? get timestampGranularities {
    return (_json['timestampGranularities'] as List?)?.cast<String>();
  }

  /// Timestamp detail to include: `'word'` and/or `'segment'`.
  ///
  /// Requires `responseFormat: 'verbose_json'`, and is only supported by
  /// `whisper-1`.
  set timestampGranularities(List<String>? value) {
    if (value == null) {
      _json.remove('timestampGranularities');
    } else {
      _json['timestampGranularities'] = value;
    }
  }

  /// How to split long audio: the string `'auto'`, or a map such as
  /// `{'type': 'server_vad', 'prefix_padding_ms': 300}`.
  ///
  /// Only supported by the `gpt-4o-transcribe` family.
  Object? get chunkingStrategy {
    return _json['chunkingStrategy'] as Object?;
  }

  /// How to split long audio: the string `'auto'`, or a map such as
  /// `{'type': 'server_vad', 'prefix_padding_ms': 300}`.
  ///
  /// Only supported by the `gpt-4o-transcribe` family.
  set chunkingStrategy(Object? value) {
    if (value == null) {
      _json.remove('chunkingStrategy');
    } else {
      _json['chunkingStrategy'] = value;
    }
  }

  /// Extra fields to include in the response, e.g. `['logprobs']`.
  List<String>? get include {
    return (_json['include'] as List?)?.cast<String>();
  }

  /// Extra fields to include in the response, e.g. `['logprobs']`.
  set include(List<String>? value) {
    if (value == null) {
      _json.remove('include');
    } else {
      _json['include'] = value;
    }
  }

  /// Translate the audio into English instead of transcribing it verbatim.
  ///
  /// Routes to `/audio/translations`, which only `whisper-1` supports.
  bool? get translate {
    return _json['translate'] as bool?;
  }

  /// Translate the audio into English instead of transcribing it verbatim.
  ///
  /// Routes to `/audio/translations`, which only `whisper-1` supports.
  set translate(bool? value) {
    if (value == null) {
      _json.remove('translate');
    } else {
      _json['translate'] = value;
    }
  }

  @override
  String toString() {
    return _json.toString();
  }

  /// Serializes this [OpenAITranscriptionOptions] to a JSON map.
  Map<String, dynamic> toJson() {
    return _json;
  }
}

base class _OpenAITranscriptionOptionsTypeFactory
    extends SchemanticType<OpenAITranscriptionOptions> {
  const _OpenAITranscriptionOptionsTypeFactory();

  @override
  OpenAITranscriptionOptions parse(Object? json) {
    return OpenAITranscriptionOptions._(json as Map<String, dynamic>);
  }

  @override
  JsonSchemaMetadata get schemaMetadata => JsonSchemaMetadata(
    name: 'OpenAITranscriptionOptions',
    definition: <String, Object?>{
      'type': 'object',
      'properties': <String, Object?>{
        'version': <String, Object?>{'type': 'string'},
        'language': <String, Object?>{'type': 'string'},
        'prompt': <String, Object?>{'type': 'string'},
        'temperature': <String, Object?>{
          'type': 'number',
          'minimum': 0.0,
          'maximum': 1.0,
        },
        'responseFormat': <String, Object?>{
          'type': 'string',
          'enum': ['json', 'text', 'srt', 'verbose_json', 'vtt'],
        },
        'timestampGranularities': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string'},
        },
        'chunkingStrategy': <String, Object?>{},
        'include': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{'type': 'string'},
        },
        'translate': <String, Object?>{'type': 'boolean'},
      },
    },
    dependencies: [],
  );
}
