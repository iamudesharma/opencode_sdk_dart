// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'dart:convert';

import 'package:genkit/plugin.dart';
import 'package:logging/logging.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;

import 'errors.dart';
import 'genkit_aliases.dart';
import 'options.dart';
import 'tools.dart';

final _logger = Logger('genkit_opencode_custom');

/// The handle used to register the OpenCode plugin and reference its models.
///
/// ```dart
/// final ai = Genkit(plugins: [openCode()]);
/// final response = await ai.generate(
///   model: openCode.model('kimi-k2.6'),
///   prompt: 'Hello!',
/// );
/// ```
final class OpenCodePluginHandle {
  const OpenCodePluginHandle();

  /// Creates a plugin that serves models from an OpenCode server.
  ///
  /// With no [client] and no [baseUrl], the plugin connects to the local
  /// background service with [sdk.OpenCodeClient.connectLocal] on first use —
  /// no configuration or API key required.
  OpenCodePlugin call({
    String name = 'opencode',
    sdk.OpenCodeClient? client,
    String? baseUrl,
    Map<String, String>? headers,
    bool discover = true,
    bool listModels = true,
    bool webSearchTool = false,
  }) {
    return OpenCodePlugin(
      name: name,
      client: client,
      baseUrl: baseUrl,
      headers: headers,
      discover: discover,
      listModels: listModels,
      webSearchTool: webSearchTool,
    );
  }

  /// References `<namespace>/<model>` (for example `opencode/kimi-k2.6`).
  ModelRef<OpenCodeModelOptions> model(String modelName, {String? namespace}) {
    final qualified = '${namespace ?? 'opencode'}/$modelName';
    return modelRef<OpenCodeModelOptions>(
      qualified,
      customOptions: OpenCodeModelOptions.$schema,
    );
  }
}

/// The default handle: `Genkit(plugins: [openCode()])`.
const OpenCodePluginHandle openCode = OpenCodePluginHandle();

/// Serves OpenCode server models to Genkit.
///
/// The plugin is a bridge, not a reimplementation: model discovery comes from
/// the server's own catalog, and generation runs through the server (unary
/// through the stateless generate endpoint, streaming through a session plus
/// the shared event stream).
///
/// Supported on top of the bridge:
/// * structured outputs — the output schema is appended to the prompt as JSON
///   instructions and Genkit parses the response, so
///   `ai.generate(outputSchema: ...)` works on any server model;
/// * media inputs — images and files ride along as session prompt attachments;
/// * persistent sessions — `OpenCodeModelOptions(sessionID: ...)` reuses a
///   server session instead of an ephemeral one;
/// * an opt-in `websearch` tool (`webSearchTool: true`) usable by models from
///   any plugin.
///
/// Limitations (documented, by design):
/// * Genkit tools are not routed through this bridge — the server's agent
///   executes its own tools. Tool requests fail fast with a clear error.
/// * Sampling parameters are the server's; use [OpenCodeModelOptions] to pick
///   an agent or a model variant instead.
final class OpenCodePlugin extends GenkitPlugin {
  OpenCodePlugin({
    this.name = 'opencode',
    this.client,
    this.baseUrl,
    this.headers,
    this.discover = true,
    this.listModels = true,
    this.webSearchTool = false,
  });

  @override
  final String name;

  /// A pre-built client. When null the plugin builds one on first use.
  final sdk.OpenCodeClient? client;

  /// Base URL of a remote server. Ignored when [client] is given.
  final String? baseUrl;

  /// Headers for a remote server built from [baseUrl].
  final Map<String, String>? headers;

  /// Whether to fall back to local service discovery when no client or
  /// [baseUrl] is configured.
  final bool discover;

  /// Whether [list] reports the server's model catalog.
  final bool listModels;

  /// Whether [init] registers the `<name>/websearch` tool.
  ///
  /// Opt-in: the tool only works when the server has a web search provider
  /// configured, and registering it eagerly could collide with a
  /// caller-defined tool of the same name.
  final bool webSearchTool;

  sdk.OpenCodeClient? _resolved;
  Future<sdk.OpenCodeClient>? _connecting;
  Future<List<sdk.ModelInfo>>? _models;

  Future<sdk.OpenCodeClient> _client() {
    final existing = client ?? _resolved;
    if (existing != null) return Future.value(existing);
    return _connecting ??= _connect();
  }

  Future<sdk.OpenCodeClient> _connect() async {
    if (baseUrl != null) {
      final created = sdk.OpenCodeClient.make(
        baseUrl: Uri.parse(baseUrl!),
        headers: headers,
      );
      _resolved = created;
      return created;
    }
    if (!discover) {
      throw GenkitException(
        'The "$name" plugin has no client, baseUrl, or discovery enabled.',
        status: StatusCode.failedPrecondition,
      );
    }
    final created = await sdk.OpenCodeClient.connectLocal();
    _resolved = created;
    return created;
  }

  Future<List<sdk.ModelInfo>> _catalog({bool refresh = false}) {
    if (refresh) _models = null;
    return _models ??= () async {
      final client = await _client();
      final response = await client.model.list();
      return response.data;
    }();
  }

  Future<sdk.ModelInfo?> _findModel(String modelName) async {
    List<sdk.ModelInfo> models;
    try {
      models = await _catalog();
    } catch (error, stackTrace) {
      _models = null;
      throw openCodeError(error, stackTrace: stackTrace);
    }
    for (final model in models) {
      if (model.id == modelName) return model;
    }
    for (final model in models) {
      if (model.modelID == modelName) return model;
    }
    return null;
  }

  // Plugin lifecycle --------------------------------------------------------

  /// Registers the opt-in `websearch` tool; no server connection is made
  /// until a tool call or a generation runs.
  @override
  Future<List<AnyAction>> init() async =>
      [if (webSearchTool) _webSearchTool()];

  @override
  Future<List<AnyActionMetadata>> list() async {
    if (!listModels) return const [];
    try {
      final models = await _catalog(refresh: true);
      return [
        for (final model in models)
          if (model.enabled) _metadataFor(model),
      ];
    } catch (error) {
      _logger.fine('OpenCode model discovery failed: $error');
      return const [];
    }
  }

  @override
  AnyAction? resolve(ActionType actionType, String name) {
    if (actionType != ActionType.model) return null;
    return _model(name);
  }

  AnyActionMetadata _metadataFor(sdk.ModelInfo model) {
    return ActionMetadata(
      name: model.id,
      actionType: ActionType.model,
      description: model.name,
      metadata: {
        'label': model.name,
        'description': model.name,
        'model': {
          'label': model.name,
          'stage': model.status.wire,
          'supports': {
            'multiturn': true,
            'systemRole': true,
            // The server's agent owns tool execution; Genkit tools are not
            // routed through this bridge.
            'tools': false,
            'toolChoice': false,
            'media': model.capabilities.input.any((kind) => kind == 'image'),
            // Structured output is simulated with schema instructions, so
            // every model can be asked for JSON.
            'output': const ['text', 'json'],
            'constrained': false,
          },
        },
      },
    );
  }

  Model<OpenCodeModelOptions> _model(String modelName) {
    return Model(
      name: modelName,
      customOptions: OpenCodeModelOptions.$schema,
      metadata: {
        'label': modelName,
        'description': modelName,
        'model': {
          'label': modelName,
          'supports': {
            'multiturn': true,
            'systemRole': true,
            'tools': false,
            'toolChoice': false,
          },
        },
      },
      fn: (request, ctx) => _generate(modelName, request, ctx),
    );
  }

  /// The opt-in tool that runs web searches through the server.
  ///
  /// Named `<plugin name>/websearch`; Genkit presents the short name
  /// (`websearch`) to models. It works with models from any plugin (for
  /// example `openAI()`), since the bridge's own models reject Genkit tools —
  /// the server's agent owns its tool loop.
  Tool<WebSearchToolInput, WebSearchToolOutput> _webSearchTool() {
    return Tool<WebSearchToolInput, WebSearchToolOutput>(
      name: '$name/websearch',
      description:
          'Search the web through the "$name" OpenCode server and return the '
          'top results.',
      inputSchema: WebSearchToolInput.$schema,
      outputSchema: WebSearchToolOutput.$schema,
      fn: (input, ctx) async {
        final client = await _client();
        final response = await client.websearch.query(
          query: input.query,
          providerID: input.providerID == null
              ? null
              : sdk.WebSearchID(input.providerID!),
          options: sdk.RequestOptions(cancelToken: _bridgeCancel(ctx.cancel)),
        );
        final data = response.data;
        return ToolResult.response(
          WebSearchToolOutput(
            provider: data.providerID.value,
            results: [
              for (final result in data.results)
                WebSearchToolResult(
                  title: result.title ?? result.url,
                  url: result.url,
                  content: result.content,
                ),
            ],
          ),
        );
      },
    );
  }

  // Generation --------------------------------------------------------------

  Future<ModelResponse> _generate(
    String modelName,
    ModelRequest request,
    ActionFnArg<ModelResponseChunk, ModelRequest, void> ctx,
  ) async {
    if (request.tools != null && request.tools!.isNotEmpty) {
      throw GenkitException(
        'OpenCode models run the server\'s agent tools, so Genkit tools '
        '(`toolNames`) cannot be routed through the "$name" backend. Use the '
        '`openAI()` handle when Genkit should own the tool loop.',
        status: StatusCode.unimplemented,
      );
    }

    final config = request.config;
    final options = config == null
        ? OpenCodeModelOptions()
        : OpenCodeModelOptions.fromJson(config);
    final info = await _findModel(modelName);
    if (info == null) {
      throw GenkitException(
        'Model "$modelName" was not reported by the OpenCode server. Use the '
        'exact id from `ai.listActions()`, or check that the model is enabled '
        'in the server configuration.',
        status: StatusCode.notFound,
      );
    }

    ctx.cancel?.throwIfCancelled();
    final started = DateTime.now();
    final modelRef = sdk.ModelRef(
      id: info.modelID,
      providerID: info.providerID,
      variant: options.variant,
    );
    final prompt = _withOutputInstructions(
      _renderPrompt(request),
      request.output?.schema,
    );
    final attachments = _attachments(request);

    try {
      // Streaming, media, and reused sessions all run through a session: the
      // stateless generate endpoint takes text only.
      if (ctx.streamingRequested ||
          options.sessionID != null ||
          attachments.isNotEmpty) {
        return await _generateViaSession(
          info: info,
          modelRef: modelRef,
          prompt: prompt,
          options: options,
          modelName: modelName,
          attachments: attachments,
          ctx: ctx,
          started: started,
        );
      }
      return await _generateUnary(
        modelRef: modelRef,
        prompt: prompt,
        modelName: modelName,
        started: started,
        ctx: ctx,
      );
    } on GenkitException {
      rethrow;
    } catch (error, stackTrace) {
      throw openCodeError(error, stackTrace: stackTrace);
    }
  }

  Future<ModelResponse> _generateUnary({
    required sdk.ModelRef modelRef,
    required String prompt,
    required String modelName,
    required DateTime started,
    required ActionFnArg<ModelResponseChunk, ModelRequest, void> ctx,
  }) async {
    final client = await _client();
    final result = await client.generate.text(
      prompt: prompt,
      model: modelRef,
      options: sdk.RequestOptions(cancelToken: _bridgeCancel(ctx.cancel)),
    );
    final text = result.data.text;
    return ModelResponse(
      message: Message(
        role: Role.model,
        content: [TextPart(text: text)],
      ),
      finishReason: FinishReason.stop,
      latencyMs: _elapsedMs(started),
      custom: {'model': modelName},
    );
  }

  Future<ModelResponse> _generateViaSession({
    required sdk.ModelInfo info,
    required sdk.ModelRef modelRef,
    required String prompt,
    required OpenCodeModelOptions options,
    required String modelName,
    required List<sdk.PromptInputFileAttachment> attachments,
    required ActionFnArg<ModelResponseChunk, ModelRequest, void> ctx,
    required DateTime started,
  }) async {
    final client = await _client();
    final cancel = _bridgeCancel(ctx.cancel);
    final requestOptions = sdk.RequestOptions(cancelToken: cancel);

    sdk.SessionInfo? createdSession;
    final sdk.SessionID sessionID;
    final reuseID = options.sessionID;
    if (reuseID != null) {
      // Reuse the server session the caller named: switch it to the model
      // (and agent) this request asked for, and leave it in place.
      sessionID = sdk.SessionID(reuseID);
      await client.session.switchModel(
        sessionID: sessionID,
        model: modelRef,
        options: requestOptions,
      );
      if (options.agent != null) {
        await client.session.switchAgent(
          sessionID: sessionID,
          agent: sdk.AgentID(options.agent!),
          options: requestOptions,
        );
      }
    } else {
      final created = await client.session.create(
        title: 'genkit generate',
        model: modelRef,
        agent: options.agent == null ? null : sdk.AgentID(options.agent!),
        options: requestOptions,
      );
      createdSession = created;
      sessionID = created.id;
    }

    try {
      // The SDK runs the turn: it streams deltas from the shared event
      // connection, falls back to `session.wait` polling when the live-only
      // stream drops, and reconciles the final text with the server's own
      // record of the message.
      final turn = client.streamPrompt(
        sessionID: sessionID,
        text: prompt,
        files: attachments.isEmpty ? null : attachments,
        metadata: options.metadata,
        options: requestOptions,
      );
      await for (final event in turn) {
        switch (event) {
          case sdk.SessionTurnTextDelta(:final delta):
            ctx.sendChunk(
              ModelResponseChunk(
                role: Role.model,
                index: 0,
                content: [TextPart(text: delta)],
              ),
            );
          case sdk.SessionTurnReasoningDelta(:final delta):
            ctx.sendChunk(
              ModelResponseChunk(
                role: Role.model,
                index: 0,
                content: [ReasoningPart(reasoning: delta)],
              ),
            );
          case sdk.SessionTurnStepUsage():
          case sdk.SessionTurnCompleted():
            break;
        }
      }
      final turnResult = await turn.result;
      ctx.cancel?.throwIfCancelled();

      final turnUsage = turnResult.usage;
      final parts = <Part>[
        if (turnResult.reasoning.isNotEmpty)
          ReasoningPart(reasoning: turnResult.reasoning),
        if (turnResult.text.isNotEmpty) TextPart(text: turnResult.text),
      ];
      return ModelResponse(
        message: parts.isEmpty
            ? null
            : Message(role: Role.model, content: parts),
        finishReason: FinishReason.stop,
        latencyMs: _elapsedMs(started),
        usage: turnUsage.totalTokens > 0 || turnUsage.cost > 0
            ? GenerationUsage(
                inputTokens: turnUsage.inputTokens +
                    turnUsage.cacheReadTokens +
                    turnUsage.cacheWriteTokens,
                outputTokens:
                    turnUsage.outputTokens + turnUsage.reasoningTokens,
                totalTokens: turnUsage.totalTokens,
                cachedContentTokens: turnUsage.cacheReadTokens,
                thoughtsTokens: turnUsage.reasoningTokens,
              )
            : null,
        custom: {'model': modelName, 'sessionID': sessionID.value},
      );
    } on GenkitException {
      rethrow;
    } catch (error, stackTrace) {
      throw openCodeError(error, stackTrace: stackTrace);
    } finally {
      final created = createdSession;
      if (created != null) {
        try {
          await client.session.remove(
            sessionID: created.id,
            options: const sdk.RequestOptions(),
          );
        } catch (error) {
          _logger.fine('Failed to remove the ephemeral session: $error');
        }
      }
    }
  }

  /// Renders Genkit messages as the plain prompt the server accepts.
  static String _renderPrompt(ModelRequest request) {
    final buffer = StringBuffer();
    for (final message in request.messages) {
      final text = message.text;
      if (text.isEmpty) continue;
      switch (message.role) {
        case Role.system:
          buffer.writeln(text);
        case Role.model:
          buffer.writeln('Assistant: $text');
        case Role.tool:
          buffer.writeln('Tool result: $text');
        default:
          buffer.writeln('User: $text');
      }
    }
    return buffer.toString().trim();
  }

  /// Appends JSON-schema instructions when Genkit asked for structured output.
  ///
  /// The bridge has no native `response_format` — the server takes a prompt —
  /// so the schema travels as instructions and Genkit parses the response.
  /// The text matches Genkit core's `jsonSchemaInstructions`, so a model reads
  /// the same instructions the built-in `simulateConstrainedGeneration`
  /// middleware would have appended; when that middleware is in use it clears
  /// `output.schema`, so nothing is duplicated.
  static String _withOutputInstructions(
    String prompt,
    Map<String, dynamic>? schema,
  ) {
    if (schema == null) return prompt;
    final rendered = const JsonEncoder.withIndent('  ').convert(schema);
    return '$prompt\n\nOutput should be in JSON format and conform to the '
        'following schema:\n\n```\n$rendered\n```\n';
  }

  /// File attachments for the server prompt, collected from media parts.
  ///
  /// `file://` URLs are sent as local paths; everything else (`http(s)`,
  /// `data:`) goes through verbatim.
  static List<sdk.PromptInputFileAttachment> _attachments(
    ModelRequest request,
  ) {
    final result = <sdk.PromptInputFileAttachment>[];
    for (final message in request.messages) {
      for (final part in message.content) {
        final media = part.media;
        if (media == null) continue;
        var uri = media.url;
        if (uri.startsWith('file://')) {
          uri = Uri.parse(uri).toFilePath();
        }
        result.add(sdk.PromptInputFileAttachment(uri: uri));
      }
    }
    return result;
  }

  static sdk.CancellationToken? _bridgeCancel(CancellationToken? cancel) {
    if (cancel == null) return null;
    final token = sdk.CancellationToken();
    if (cancel.isCancelled) {
      token.cancel();
    } else {
      cancel.onCancel(token.cancel);
    }
    return token;
  }

  static double _elapsedMs(DateTime started) =>
      DateTime.now().difference(started).inMicroseconds / 1000;
}
