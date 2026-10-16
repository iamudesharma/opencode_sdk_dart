// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:genkit/plugin.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'audio.dart';
import 'capabilities.dart';
import 'catalog.dart';
import 'chat_client.dart';
import 'converters.dart';
import 'dialect.dart';
import 'embedders.dart';
import 'errors.dart';
import 'genkit_aliases.dart';
import 'options.dart';

final _logger = Logger('genkit_opencode_custom.openai');

/// Which OpenAI endpoint serves a model.
enum OpenAIModelKind {
  /// Chat Completions (`/chat/completions`).
  chat,

  /// Text-to-speech (`/audio/speech`).
  speech,

  /// Speech-to-text (`/audio/transcriptions`).
  transcription,

  /// Embeddings (`/embeddings`), resolved under `ActionType.embedder`.
  embedder,
}

/// Declares a model that is not part of any curated catalog.
///
/// Custom models are reported by [OpenAIPlugin.list] (so the Genkit Dev UI
/// shows them) and their [capabilities] become authoritative for pre-flight
/// checks.
final class CustomModelDefinition {
  const CustomModelDefinition({
    required this.name,
    this.capabilities = const ModelCapabilities(),
    this.label,
    this.kind,
  });

  /// The model id sent to the host.
  final String name;

  /// What the model can do.
  final ModelCapabilities capabilities;

  /// Human-readable label for the Dev UI. Defaults to [name].
  final String? label;

  /// Which API serves the model.
  ///
  /// When null the name is classified by heuristic (`tts` names are speech,
  /// `whisper`/`transcribe` names are transcription, `embedding` names are
  /// embedders), falling back to chat.
  final OpenAIModelKind? kind;
}

/// The handle used to register the plugin and reference its models.
///
/// ```dart
/// final ai = Genkit(plugins: [openAI()]);
/// final response = await ai.generate(
///   model: openAI.model('gpt-4o'),
///   prompt: 'Hello!',
/// );
/// ```
final class OpenAICompatPluginHandle {
  const OpenAICompatPluginHandle();

  /// Creates a plugin for an OpenAI or OpenAI-compatible host.
  OpenAIPlugin call({
    String? name,
    String? apiKey,
    String Function()? apiKeyProvider,
    String? baseUrl,
    OpenAICompatDialect dialect = OpenAICompatDialect.openAI,
    List<CustomModelDefinition> models = const [],
    bool listModels = true,
    bool checkCapabilities = true,
    Map<String, String>? headers,
    http.Client? httpClient,
    http.Client Function()? clientFactory,
  }) {
    return OpenAIPlugin(
      name: name ?? dialect.defaultNamespace,
      apiKey: apiKey,
      apiKeyProvider: apiKeyProvider,
      baseUrl: baseUrl ?? dialect.defaultBaseUrl,
      dialect: dialect,
      models: models,
      listModels: listModels,
      checkCapabilities: checkCapabilities,
      headers: headers,
      httpClient: httpClient,
      clientFactory: clientFactory,
    );
  }

  /// References `<namespace>/<model>` (for example `openai/gpt-4o`).
  ///
  /// [namespace] must match the plugin's `name`; it defaults to `openai`.
  ModelRef<OpenAIChatOptions> model(String modelName, {String? namespace}) {
    return modelRef<OpenAIChatOptions>(
      _qualify(modelName, namespace),
      customOptions: OpenAIChatOptions.$schema,
    );
  }

  /// References `<namespace>/<model>` for a text-to-speech model.
  ModelRef<OpenAISpeechOptions> speechModel(
    String modelName, {
    String? namespace,
  }) {
    return modelRef<OpenAISpeechOptions>(
      _qualify(modelName, namespace),
      customOptions: OpenAISpeechOptions.$schema,
    );
  }

  /// References `<namespace>/<model>` for a speech-to-text model.
  ModelRef<OpenAITranscriptionOptions> transcriptionModel(
    String modelName, {
    String? namespace,
  }) {
    return modelRef<OpenAITranscriptionOptions>(
      _qualify(modelName, namespace),
      customOptions: OpenAITranscriptionOptions.$schema,
    );
  }

  /// References `<namespace>/<embedder>` for an embedding model.
  EmbedderRef<OpenAIEmbedderOptions> embedder(
    String embedderName, {
    String? namespace,
  }) {
    return embedderRef<OpenAIEmbedderOptions>(
      _qualify(embedderName, namespace),
      customOptions: OpenAIEmbedderOptions.$schema,
    );
  }

  static String _qualify(String modelName, String? namespace) {
    final ns = namespace ?? 'openai';
    return ns.isEmpty ? modelName : '$ns/$modelName';
  }
}

/// The default handle: `Genkit(plugins: [openAI()])`.
const OpenAICompatPluginHandle openAI = OpenAICompatPluginHandle();

/// Registers OpenAI and OpenAI-compatible chat models with Genkit.
final class OpenAIPlugin extends GenkitPlugin {
  OpenAIPlugin({
    required this.name,
    this.apiKey,
    this.apiKeyProvider,
    String? baseUrl,
    this.dialect = OpenAICompatDialect.openAI,
    List<CustomModelDefinition> models = const [],
    this.listModels = true,
    this.checkCapabilities = true,
    this.headers,
    this.httpClient,
    this.clientFactory,
  }) : _models = {for (final model in models) model.name: model},
       _baseUrl = baseUrl ?? dialect.defaultBaseUrl;

  @override
  final String name;

  /// A static API key. When null, [apiKeyProvider] and then the dialect's
  /// environment variable are consulted, in that order, at request time.
  final String? apiKey;

  /// Supplies the API key lazily (for example from a secret manager).
  final String Function()? apiKeyProvider;

  /// How this host deviates from OpenAI's API.
  final OpenAICompatDialect dialect;

  /// Whether `GET /models` discovery contributes to [list].
  final bool listModels;

  /// Whether requests are validated against known model capabilities.
  final bool checkCapabilities;

  /// Static headers added to every request.
  final Map<String, String>? headers;

  /// An injected HTTP client (used as-is; never closed by the plugin).
  final http.Client? httpClient;

  /// Factory for dedicated clients used when a request is cancelled.
  final http.Client Function()? clientFactory;

  final Map<String, CustomModelDefinition> _models;
  final String _baseUrl;

  OpenAIChatClient? _client;

  OpenAIChatClient get _chatClient => _client ??= OpenAIChatClient(
    baseUrl: OpenAIChatClient.normalizeBaseUrl(_baseUrl),
    headers: _requestHeaders,
    httpClient: httpClient,
    clientFactory: clientFactory,
  );

  Map<String, String> _requestHeaders() {
    final result = <String, String>{...?headers};
    final key = _keyFromSources();
    if (key != null && key.isNotEmpty) {
      result['authorization'] = 'Bearer $key';
    }
    return result;
  }

  String? _keyFromSources() {
    final provided = apiKeyProvider?.call();
    if (provided != null && provided.isNotEmpty) return provided;
    if (apiKey != null && apiKey!.isNotEmpty) return apiKey;
    final fromEnv = getConfigVar(dialect.apiKeyEnvVar);
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
    return null;
  }

  String _requireKey() {
    final key = _keyFromSources();
    if (key != null && key.isNotEmpty) return key;
    if (!dialect.apiKeyRequired) return '';
    throw GenkitException(
      'No API key for the "$name" plugin. Set the '
      '${dialect.apiKeyEnvVar} environment variable, pass `apiKey:`, or '
      'supply an `apiKeyProvider:`.',
      status: StatusCode.failedPrecondition,
    );
  }

  // Plugin lifecycle --------------------------------------------------------

  /// Registers nothing eagerly: no network I/O and no key are needed to
  /// construct the plugin, so `Genkit(plugins: [openAI()])` always starts.
  @override
  Future<List<AnyAction>> init() async => const <AnyAction>[];

  /// Best-effort listing: declared custom models plus `GET /models`
  /// discovery when a key is available, classified by kind. Never throws.
  @override
  Future<List<AnyActionMetadata>> list() async {
    final chat = <String>[];
    final speech = <String>[];
    final transcription = <String>[];
    final embedders = <String>[];
    final seen = <String>{};

    void classify(String id) {
      if (!seen.add(id)) return;
      switch (_kindOf(id)) {
        case OpenAIModelKind.chat:
          chat.add(id);
        case OpenAIModelKind.speech:
          speech.add(id);
        case OpenAIModelKind.transcription:
          transcription.add(id);
        case OpenAIModelKind.embedder:
          embedders.add(id);
      }
    }

    for (final model in _models.values) {
      classify(model.name);
    }
    if (listModels) {
      final key = _keyFromSources();
      if (key != null && key.isNotEmpty || !dialect.apiKeyRequired) {
        try {
          for (final id in await _discoverModels()) {
            classify(id);
          }
        } catch (error) {
          _logger.fine('Model discovery for "$name" was skipped: $error');
        }
      }
    }
    return [
      for (final id in chat) _metadataFor(id),
      for (final id in speech) _speechMetadata(id),
      for (final id in transcription) _transcriptionMetadata(id),
      for (final id in embedders) _embedderMetadata(id),
    ];
  }

  @override
  AnyAction? resolve(ActionType actionType, String name) {
    if (actionType == ActionType.embedder) return _createEmbedder(name);
    if (actionType != ActionType.model) return null;
    return switch (_kindOf(name)) {
      OpenAIModelKind.speech => _createSpeechModel(name),
      OpenAIModelKind.transcription => _createTranscriptionModel(name),
      // Embedders resolve under their own action type.
      OpenAIModelKind.embedder => null,
      OpenAIModelKind.chat => _model(name),
    };
  }

  /// Which API serves [modelName]: an explicit declaration first, then the
  /// name heuristics, then chat.
  OpenAIModelKind _kindOf(String modelName) {
    final declared = _models[modelName]?.kind;
    if (declared != null) return declared;
    if (isSpeechModelName(modelName)) return OpenAIModelKind.speech;
    if (isTranscriptionModelName(modelName)) {
      return OpenAIModelKind.transcription;
    }
    if (isEmbedderName(modelName)) return OpenAIModelKind.embedder;
    return OpenAIModelKind.chat;
  }

  Future<List<String>> _discoverModels() => _chatClient.listModels();

  ModelCapabilities? _capabilitiesFor(String modelName) {
    final custom = _models[modelName];
    if (custom != null) return custom.capabilities;
    return curatedCapabilities(modelName);
  }

  ModelInfo _infoFor(String modelName) {
    final custom = _models[modelName];
    if (custom != null) {
      return custom.capabilities.toModelInfo(label: custom.label ?? modelName);
    }
    final curated = curatedCapabilities(modelName);
    if (curated != null) return curated.toModelInfo(label: modelName);
    return const ModelCapabilities().toModelInfo(label: modelName);
  }

  AnyActionMetadata _metadataFor(String modelName) {
    final custom = _models[modelName];
    final label = custom?.label ?? modelName;
    return ActionMetadata(
      name: modelName,
      actionType: ActionType.model,
      description: label,
      metadata: {
        'label': label,
        'description': label,
        'model': _infoFor(modelName).toJson(),
        'customOptions': OpenAIChatOptions.$schema.jsonSchema(useRefs: false),
      },
    );
  }

  Model<OpenAIChatOptions> _model(String modelName) {
    final label = _models[modelName]?.label ?? modelName;
    return Model(
      name: modelName,
      customOptions: OpenAIChatOptions.$schema,
      metadata: {
        'label': label,
        'description': label,
        'model': _infoFor(modelName).toJson(),
      },
      fn: (request, ctx) => _generate(modelName, request, ctx),
    );
  }

  AnyActionMetadata _speechMetadata(String modelName) {
    final label = _models[modelName]?.label ?? modelName;
    return ActionMetadata(
      name: modelName,
      actionType: ActionType.model,
      description: label,
      metadata: {
        'label': label,
        'description': label,
        'model': speechModelInfo(label).toJson(),
        'customOptions': OpenAISpeechOptions.$schema.jsonSchema(useRefs: false),
      },
    );
  }

  AnyActionMetadata _transcriptionMetadata(String modelName) {
    final label = _models[modelName]?.label ?? modelName;
    return ActionMetadata(
      name: modelName,
      actionType: ActionType.model,
      description: label,
      metadata: {
        'label': label,
        'description': label,
        'model': transcriptionModelInfo(label).toJson(),
        'customOptions': OpenAITranscriptionOptions.$schema.jsonSchema(
          useRefs: false,
        ),
      },
    );
  }

  AnyActionMetadata _embedderMetadata(String embedderName) {
    final label = _models[embedderName]?.label ?? embedderName;
    return ActionMetadata(
      name: embedderName,
      actionType: ActionType.embedder,
      description: label,
      metadata: {
        'label': label,
        'description': label,
        'model': {
          'label': label,
          'customOptions': OpenAIEmbedderOptions.$schema.jsonSchema(
            useRefs: false,
          ),
        },
      },
    );
  }

  /// Whether the plugin dials the dialect's own host, where the curated
  /// catalog is authoritative.
  bool get _ownHost {
    final dialled = Uri.tryParse(_baseUrl)?.host;
    if (dialled == null || dialled.isEmpty) return false;
    return dialled == Uri.tryParse(dialect.defaultBaseUrl)?.host;
  }

  /// Builds a text-to-speech model (`POST /audio/speech`).
  ///
  /// Speech models take the prompt text and return a single audio
  /// [MediaPart] holding a base64 data URL. The endpoint is not streaming, so
  /// streamed requests are served unary.
  Model<OpenAISpeechOptions> _createSpeechModel(String modelName) {
    final label = _models[modelName]?.label ?? modelName;
    return Model(
      name: modelName,
      customOptions: OpenAISpeechOptions.$schema,
      metadata: {'model': speechModelInfo(label).toJson()},
      fn: (request, ctx) async {
        final options = request.config == null
            ? OpenAISpeechOptions()
            : OpenAISpeechOptions.fromJson(request.config!);
        validateSpeechOptions(options);
        final input = _speechInputText(request);
        _requireKey();
        ctx.cancel?.throwIfCancelled();

        final format = options.responseFormat ?? defaultSpeechResponseFormat;
        final bytes = await _chatClient.createSpeech(
          <String, dynamic>{
            'model': options.version ?? modelName,
            'input': input,
            'voice': options.voice ?? defaultSpeechVoice,
            if (options.instructions != null)
              'instructions': options.instructions,
            if (options.responseFormat != null)
              'response_format': options.responseFormat,
            if (options.speed != null) 'speed': options.speed,
          },
          cancel: ctx.cancel,
        );
        if (bytes.isEmpty) {
          throw GenkitException(
            'The speech endpoint returned no audio.',
            status: StatusCode.internal,
          );
        }

        final contentType =
            speechResponseFormatMediaTypes[format] ?? 'audio/mpeg';
        return ModelResponse(
          finishReason: FinishReason.stop,
          message: Message(
            role: Role.model,
            content: [
              MediaPart(
                media: Media(
                  contentType: contentType,
                  url: 'data:$contentType;base64,${base64Encode(bytes)}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a speech-to-text model (`POST /audio/transcriptions`, or
  /// `/audio/translations` for whisper translate requests).
  Model<OpenAITranscriptionOptions> _createTranscriptionModel(
    String modelName,
  ) {
    final label = _models[modelName]?.label ?? modelName;
    return Model(
      name: modelName,
      customOptions: OpenAITranscriptionOptions.$schema,
      metadata: {'model': transcriptionModelInfo(label).toJson()},
      fn: (request, ctx) async {
        final options = request.config == null
            ? OpenAITranscriptionOptions()
            : OpenAITranscriptionOptions.fromJson(request.config!);

        if (request.output?.format == 'media') {
          throw GenkitException(
            'Transcription models return text; output format "media" is not '
            'supported.',
            status: StatusCode.invalidArgument,
          );
        }

        final audio = _transcriptionAudio(request);
        _requireKey();
        ctx.cancel?.throwIfCancelled();

        final resolvedModel = options.version ?? modelName;
        final format =
            options.responseFormat ?? defaultTranscriptionResponseFormat;
        final translate =
            options.translate == true && supportsTranslation(resolvedModel);

        final fields = <String, String>{
          'model': resolvedModel,
          'response_format': format,
        };
        final prompt = options.prompt ?? request.messages.first.text;
        if (prompt.trim().isNotEmpty) fields['prompt'] = prompt;
        if (options.temperature != null) {
          fields['temperature'] = '${options.temperature}';
        }

        final repeated = <String, List<String>>{};
        // The translations endpoint only accepts file, model, prompt,
        // response_format and temperature.
        if (!translate) {
          if (options.language != null) fields['language'] = options.language!;
          final chunking = options.chunkingStrategy;
          if (chunking != null) {
            fields['chunking_strategy'] =
                chunking is String ? chunking : jsonEncode(chunking);
          }
          final include = options.include;
          if (include != null && include.isNotEmpty) {
            repeated['include[]'] = include;
          }
          final granularities = options.timestampGranularities;
          if (granularities != null && granularities.isNotEmpty) {
            repeated['timestamp_granularities[]'] = granularities;
          }
        }

        final body = await _chatClient.createTranscription(
          endpoint: translate ? 'audio/translations' : 'audio/transcriptions',
          bytes: audio.bytes,
          filename: audioFilenameFor(audio.mimeType),
          fields: fields,
          repeatedFields: repeated,
          cancel: ctx.cancel,
        );

        final decoded = _decodedTranscript(body, format);
        return ModelResponse(
          finishReason: FinishReason.stop,
          message: Message(
            role: Role.model,
            content: [
              TextPart(
                text: _transcriptText(
                  body,
                  format,
                  decoded,
                  wantsJson: request.output?.format == 'json',
                ),
              ),
            ],
          ),
          // Timestamps, segments and logprobs only exist here; the text part
          // carries the transcript, `raw` is where a caller reaches for
          // everything `verbose_json` and `include` were asked for.
          raw: decoded is Map<String, dynamic> ? decoded : null,
        );
      },
    );
  }

  /// Builds an embedder (`POST /embeddings`).
  ///
  /// Like [_model], this resolves any name: an embedder released after this
  /// version of the plugin, or one a compatible host serves under a name
  /// OpenAI never used, works as soon as it is named.
  Embedder<OpenAIEmbedderOptions> _createEmbedder(String embedderName) {
    final label = _models[embedderName]?.label ?? embedderName;
    return Embedder(
      name: embedderName,
      customOptions: OpenAIEmbedderOptions.$schema,
      metadata: {
        'model': {'label': label},
      },
      fn: (request, ctx) async {
        if (request.input.isEmpty) {
          // An empty `input` is a 400; answering directly keeps
          // `embed(documents: [])` from costing a request.
          return EmbedResponse(embeddings: []);
        }

        final options = request.options == null
            ? OpenAIEmbedderOptions()
            : OpenAIEmbedderOptions.fromJson(request.options!);
        if (_ownHost) {
          // Only the dialect's own host is held to the curated catalog; a
          // compatible host serving the same name may not share its limits.
          validateEmbedderDimensions(embedderName, options.dimensions);
        }
        final inputs = embeddingInputs(request.input);
        _requireKey();
        ctx.cancel?.throwIfCancelled();

        // Batches go out one at a time rather than in parallel: a corpus
        // large enough to need splitting is also large enough for a fan-out
        // to trip the account's rate limit.
        final embeddings = <Embedding>[];
        for (final batch in embeddingBatches(inputs)) {
          final response = await _chatClient.createEmbedding(
            <String, dynamic>{
              'model': embedderName,
              'input': batch,
              if (options.dimensions != null) 'dimensions': options.dimensions,
              if (options.user != null) 'user': options.user,
            },
            cancel: ctx.cancel,
          );
          embeddings.addAll(
            toGenkitEmbeddings(response, expectedCount: batch.length),
          );
        }
        return EmbedResponse(embeddings: embeddings);
      },
    );
  }

  // Generation --------------------------------------------------------------

  Future<ModelResponse> _generate(
    String modelName,
    ModelRequest request,
    ActionFnArg<ModelResponseChunk, ModelRequest, void> ctx,
  ) async {
    final config = request.config;
    final options = config == null
        ? OpenAIChatOptions()
        : OpenAIChatOptions.fromJson(config);
    final capabilities = _capabilitiesFor(modelName);
    if (checkCapabilities && capabilities != null) {
      CapabilityChecker.check(
        modelName: modelName,
        capabilities: capabilities,
        request: request,
        options: options,
      );
    }
    _requireKey();
    ctx.cancel?.throwIfCancelled();

    final streaming = ctx.streamingRequested;
    final body = OpenAIConverter.buildChatBody(
      request: request,
      options: options,
      dialect: dialect,
      capabilities: capabilities,
      model: modelName,
      streaming: streaming,
    );
    final started = DateTime.now();

    try {
      if (!streaming) {
        final json = await _chatClient.createChatCompletion(
          body,
          cancel: ctx.cancel,
        );
        return OpenAIConverter.toModelResponse(
          json,
          model: modelName,
          latencyMs: _elapsedMs(started),
        );
      }

      final assembler = ChatStreamAssembler();
      await for (final frame in _chatClient.streamChatCompletion(
        body,
        cancel: ctx.cancel,
      )) {
        ctx.cancel?.throwIfCancelled();
        final chunk = assembler.add(frame);
        if (chunk != null) ctx.sendChunk(chunk);
      }
      return assembler.finish(model: modelName, latencyMs: _elapsedMs(started));
    } on GenkitException {
      rethrow;
    } catch (error, stackTrace) {
      throw chatTransportError(
        error,
        url: OpenAIChatClient.normalizeBaseUrl(
          _baseUrl,
        ).resolve('chat/completions'),
        stackTrace: stackTrace,
      );
    }
  }

  /// The text to synthesize: the newest non-system message.
  ///
  /// Core appends `system` ahead of the prompt, so the first message would
  /// read the instruction aloud and never see the prompt at all.
  static String _speechInputText(ModelRequest request) {
    if (request.messages.isEmpty) {
      throw GenkitException(
        'Speech models require a prompt, but no messages were provided.',
        status: StatusCode.invalidArgument,
      );
    }
    final spoken = request.messages.lastWhere(
      (message) => message.role != Role.system,
      orElse: () => throw GenkitException(
        'Speech models require a prompt, but only a system message was '
        'provided.',
        status: StatusCode.invalidArgument,
      ),
    );
    final text = spoken.text;
    if (text.trim().isEmpty) {
      throw GenkitException(
        'Speech models require non-empty prompt text.',
        status: StatusCode.invalidArgument,
      );
    }
    return text;
  }

  /// Extracts the audio to transcribe from the request's media parts.
  static ({Uint8List bytes, String mimeType}) _transcriptionAudio(
    ModelRequest request,
  ) {
    Media? media;
    for (final message in request.messages) {
      for (final part in message.content) {
        final candidate = part.media;
        if (candidate != null) {
          media = candidate;
          break;
        }
      }
      if (media != null) break;
    }
    if (media == null) {
      throw GenkitException(
        'Transcription models require an audio media part in the request.',
        status: StatusCode.invalidArgument,
      );
    }

    final data = Uri.tryParse(media.url)?.data;
    if (data == null) {
      throw GenkitException(
        'Transcription models require audio as a base64 data URL; got '
        '${media.url.split(':').first}.',
        status: StatusCode.invalidArgument,
      );
    }

    final mimeType = (media.contentType ?? data.mimeType)
        .split(';')
        .first
        .trim();
    return (bytes: data.contentAsBytes(), mimeType: mimeType);
  }

  /// The transcript response decoded, or null when it is not JSON.
  ///
  /// `text`, `srt` and `vtt` are transcripts, not documents; a `json` or
  /// `verbose_json` body that will not parse is left to the caller to see
  /// verbatim rather than failing the request.
  static Object? _decodedTranscript(String body, String format) {
    if (format != 'json' && format != 'verbose_json') return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  /// The text a transcription answers with.
  ///
  /// The transcript itself by default: a caller asking a transcription model
  /// for audio wants the words, not `{"text": "the words"}`. When the request
  /// asked for `json` output, the object goes through whole, so Genkit's own
  /// parsing has something to parse and `response.output` is not silently
  /// null.
  static String _transcriptText(
    String body,
    String format,
    Object? decoded, {
    required bool wantsJson,
  }) {
    if (decoded == null) return body;
    if (wantsJson) return body;
    if (decoded is Map && decoded['text'] is String) {
      return decoded['text'] as String;
    }
    return body;
  }

  static double _elapsedMs(DateTime started) =>
      DateTime.now().difference(started).inMicroseconds / 1000;

  /// Closes the underlying HTTP client.
  void close() => _client?.close();
}
