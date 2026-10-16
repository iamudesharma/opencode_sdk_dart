// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:genkit/plugin.dart';
import 'package:schemantic/schemantic.dart';

part 'audio.g.dart';

/// Options for OpenAI text-to-speech models (`POST /audio/speech`).
@Schema()
abstract class $OpenAISpeechOptions {
  /// Model snapshot override, e.g. `'tts-1-1106'`.
  String? get version;

  /// Voice used to render the audio (e.g. `'alloy'`, `'sage'`, `'coral'`).
  ///
  /// Left free-form on purpose: hosts add voices without warning, and an enum
  /// here would reject them until this package shipped a new release.
  /// Defaults to `'alloy'`.
  String? get voice;

  /// Tone and delivery guidance, e.g. `'Speak in a calm, warm tone.'`
  ///
  /// Only honored by `gpt-4o-mini-tts`; the `tts-1` family ignores it.
  String? get instructions;

  /// Playback speed multiplier (0.25 - 4.0).
  @DoubleField(minimum: 0.25, maximum: 4.0)
  double? get speed;

  /// Audio container for the generated speech. Defaults to `'mp3'`.
  @StringField(enumValues: ['mp3', 'opus', 'aac', 'flac', 'wav', 'pcm'])
  String? get responseFormat;
}

/// Options for OpenAI speech-to-text models (`POST /audio/transcriptions`).
@Schema()
abstract class $OpenAITranscriptionOptions {
  /// Model snapshot override, e.g. `'whisper-1'`.
  String? get version;

  /// ISO-639-1 code of the spoken language, e.g. `'en'`, `'es'`.
  ///
  /// Supplying it improves accuracy and latency. Not accepted by the
  /// translation endpoint, which always outputs English.
  String? get language;

  /// Decoding hint: vocabulary, names, or the expected style.
  ///
  /// Distinct from the Genkit prompt. When unset, the text content of the
  /// request message is used instead.
  String? get prompt;

  /// Sampling temperature (0.0 - 1.0).
  @DoubleField(minimum: 0.0, maximum: 1.0)
  double? get temperature;

  /// Transcript format. Defaults to `'json'`.
  ///
  /// `'srt'` and `'vtt'` return subtitle markup, `'verbose_json'` adds timing
  /// metadata. Whatever the format, the transcript is returned as a single
  /// text part; the untouched payload is available on `ModelResponse.raw`.
  @StringField(enumValues: ['json', 'text', 'srt', 'verbose_json', 'vtt'])
  String? get responseFormat;

  /// Timestamp detail to include: `'word'` and/or `'segment'`.
  ///
  /// Requires `responseFormat: 'verbose_json'`, and is only supported by
  /// `whisper-1`.
  List<String>? get timestampGranularities;

  /// How to split long audio: the string `'auto'`, or a map such as
  /// `{'type': 'server_vad', 'prefix_padding_ms': 300}`.
  ///
  /// Only supported by the `gpt-4o-transcribe` family.
  Object? get chunkingStrategy;

  /// Extra fields to include in the response, e.g. `['logprobs']`.
  List<String>? get include;

  /// Translate the audio into English instead of transcribing it verbatim.
  ///
  /// Routes to `/audio/translations`, which only `whisper-1` supports.
  bool? get translate;
}

/// Maps a speech `response_format` to the MIME type of the returned audio.
///
/// `opus` is Ogg-encapsulated and `audio/ogg` is the registered type for that
/// (`audio/opus` is unregistered and browsers refuse to play it). `pcm` is
/// deliberately not `audio/L16`, which is defined big-endian at 8 kHz while
/// the API returns little-endian 24 kHz samples.
const Map<String, String> speechResponseFormatMediaTypes = {
  'mp3': 'audio/mpeg',
  'opus': 'audio/ogg',
  'aac': 'audio/aac',
  'flac': 'audio/flac',
  'wav': 'audio/wav',
  'pcm': 'audio/pcm',
};

/// Default audio container when the caller does not pick one.
const String defaultSpeechResponseFormat = 'mp3';

/// Default voice when the caller does not pick one.
const String defaultSpeechVoice = 'alloy';

/// Transcript format used when the caller does not pick one.
const String defaultTranscriptionResponseFormat = 'json';

/// Whether [modelName] names a text-to-speech model.
bool isSpeechModelName(String modelName) =>
    modelName.toLowerCase().contains('tts');

/// Whether [modelName] names a speech-to-text model.
bool isTranscriptionModelName(String modelName) {
  final name = modelName.toLowerCase();
  return name.contains('whisper') || name.contains('transcribe');
}

/// Whether [modelName] can translate audio to English (whisper family only).
bool supportsTranslation(String modelName) =>
    modelName.toLowerCase().contains('whisper');

/// Audio MIME type to the filename extension used for the multipart upload.
///
/// The host infers the codec from the filename, so it has to be a real audio
/// extension; a generic `type/subtype` split is not good enough (`audio/x-m4a`
/// would yield `x-m4a`, which the API rejects).
const Map<String, String> _audioMimeExtensions = {
  'audio/flac': 'flac',
  'audio/mp4': 'mp4',
  'audio/mpeg': 'mp3',
  'audio/mpga': 'mpga',
  'audio/m4a': 'm4a',
  'audio/x-m4a': 'm4a',
  'audio/oga': 'oga',
  'audio/ogg': 'ogg',
  'audio/wav': 'wav',
  'audio/x-wav': 'wav',
  'audio/webm': 'webm',
};

/// Filename to upload audio of [mimeType] under.
String audioFilenameFor(String mimeType) {
  final extension = _audioMimeExtensions[mimeType.toLowerCase()];
  return extension == null ? 'input' : 'input.$extension';
}

/// Validates the speech options that schema annotations only document.
void validateSpeechOptions(OpenAISpeechOptions options) {
  final format = options.responseFormat;
  if (format != null && !speechResponseFormatMediaTypes.containsKey(format)) {
    throw GenkitException(
      'Unknown responseFormat "$format". Accepted formats: '
      '${speechResponseFormatMediaTypes.keys.join(', ')}.',
      status: StatusCode.invalidArgument,
    );
  }

  final speed = options.speed;
  if (speed != null && (speed < 0.25 || speed > 4.0)) {
    throw GenkitException(
      'speed must be between 0.25 and 4.0; got $speed.',
      status: StatusCode.invalidArgument,
    );
  }
}

/// Capability metadata for a text-to-speech model.
///
/// Speech models take text in and hand back a single audio [MediaPart], so
/// they advertise `output: ['media']` and opt out of everything conversational.
ModelInfo speechModelInfo(String modelName) => ModelInfo(
  label: modelName,
  supports: const {
    'media': false,
    'output': ['media'],
    'multiturn': false,
    'systemRole': false,
    'tools': false,
  },
);

/// Capability metadata for a transcription model.
ModelInfo transcriptionModelInfo(String modelName) => ModelInfo(
  label: modelName,
  supports: const {
    'media': true,
    'output': ['text', 'json'],
    'multiturn': false,
    'systemRole': false,
    'tools': false,
  },
);
