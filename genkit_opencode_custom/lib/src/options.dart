// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:schemantic/schemantic.dart';

part 'options.g.dart';

/// Chat options for OpenAI and OpenAI-compatible chat models.
///
/// Pass an instance to `ai.generate(config: ...)` (or
/// `ai.generateStream(config: ...)`) together with a model reference from
/// [OpenAICompatPluginHandle.model]. Every field is optional; null fields are
/// omitted from the request.
@Schema()
abstract class $OpenAIChatOptions {
  /// Model snapshot override, e.g. `'gpt-4o-2024-08-06'`.
  String? get version;

  /// Sampling temperature (0.0 - 2.0).
  @DoubleField(minimum: 0, maximum: 2)
  double? get temperature;

  /// Nucleus sampling (0.0 - 1.0).
  @DoubleField(minimum: 0, maximum: 1)
  double? get topP;

  /// Maximum number of tokens to generate. Sent as `max_completion_tokens`
  /// for OpenAI models and as `max_tokens` when the dialect says so.
  int? get maxTokens;

  /// Up to 4 sequences where the model stops generating.
  List<String>? get stop;

  /// Penalty applied to tokens already present in the text (-2.0 - 2.0).
  @DoubleField(minimum: -2, maximum: 2)
  double? get presencePenalty;

  /// Penalty applied to tokens based on their frequency (-2.0 - 2.0).
  @DoubleField(minimum: -2, maximum: 2)
  double? get frequencyPenalty;

  /// Best-effort determinism seed.
  int? get seed;

  /// Stable end-user identifier for abuse monitoring.
  String? get user;

  /// Requests `{"type": "json_object"}` when the request carries no output
  /// configuration. Ignored when Genkit already asked for structured output.
  bool? get jsonMode;

  /// Strictness for `json_schema` structured outputs. Defaults to `false`
  /// because OpenAI's strict mode rejects schemas with optional fields.
  bool? get strictSchema;

  /// Per-request override for `stream_options: {"include_usage": true}`.
  /// Defaults to the dialect's [OpenAICompatDialect.includeUsageInStream].
  bool? get includeUsageInStream;

  /// Reasoning effort for models that support it.
  @StringField(enumValues: ['low', 'medium', 'high'])
  String? get reasoningEffort;

  /// Output verbosity for models that support it.
  @StringField(enumValues: ['low', 'medium', 'high'])
  String? get verbosity;

  /// Image detail override applied to media parts.
  @StringField(enumValues: ['auto', 'low', 'high'])
  String? get visualDetailLevel;

  /// Extra fields merged verbatim into the chat completion body. Use this for
  /// host-specific switches (for example DeepSeek's `thinking`).
  Map<String, dynamic>? get extraBody;
}

/// Options for models served by an OpenCode server through the `openCode`
/// plugin.
///
/// The server runs its own agent, so these options select which agent and
/// which model variant (thinking level, reasoning mode, ...) answer; sampling
/// parameters belong to the server's own model configuration.
@Schema()
abstract class $OpenCodeModelOptions {
  /// Model variant id as reported by the server, for example `'low'`,
  /// `'medium'` or `'high'` for models with thinking levels.
  String? get variant;

  /// Agent id used for the session, for example `'build'` or `'plan'`.
  String? get agent;

  /// Reuse an existing server session instead of creating an ephemeral one.
  ///
  /// The session is left in place afterwards, so the model keeps its
  /// server-side memory across calls. The requested model (and [agent], when
  /// set) are switched on the session before the prompt is sent.
  String? get sessionID;

  /// Metadata attached to the prompt sent to the server.
  Map<String, dynamic>? get metadata;
}
