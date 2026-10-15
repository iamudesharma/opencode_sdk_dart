// Copyright 2026 The genkit_openai_custom authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:genkit/plugin.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'capabilities.dart';
import 'catalog.dart';
import 'chat_client.dart';
import 'converters.dart';
import 'dialect.dart';
import 'errors.dart';
import 'genkit_aliases.dart';
import 'options.dart';

final _logger = Logger('genkit_openai_custom');

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
  });

  /// The model id sent to the host.
  final String name;

  /// What the model can do.
  final ModelCapabilities capabilities;

  /// Human-readable label for the Dev UI. Defaults to [name].
  final String? label;
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
    final qualified = (namespace ?? 'openai').isEmpty
        ? modelName
        : '${namespace ?? 'openai'}/$modelName';
    return modelRef<OpenAIChatOptions>(
      qualified,
      customOptions: OpenAIChatOptions.$schema,
    );
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

  /// Best-effort model listing: declared custom models plus `GET /models`
  /// discovery when a key is available. Never throws.
  @override
  Future<List<AnyActionMetadata>> list() async {
    final result = <AnyActionMetadata>[];
    final seen = <String>{};
    for (final model in _models.values) {
      if (seen.add(model.name)) {
        result.add(_metadataFor(model.name));
      }
    }
    if (listModels) {
      final key = _keyFromSources();
      if (key != null && key.isNotEmpty || !dialect.apiKeyRequired) {
        try {
          final ids = await _discoverModels();
          for (final id in ids) {
            if (seen.add(id)) result.add(_metadataFor(id));
          }
        } catch (error) {
          _logger.fine('Model discovery for "$name" was skipped: $error');
        }
      }
    }
    return result;
  }

  @override
  AnyAction? resolve(ActionType actionType, String name) {
    if (actionType != ActionType.model) return null;
    return _model(name);
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

  static double _elapsedMs(DateTime started) =>
      DateTime.now().difference(started).inMicroseconds / 1000;

  /// Closes the underlying HTTP client.
  void close() => _client?.close();
}
