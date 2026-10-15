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

  /// Metadata attached to the prompt sent to the server.
  Map<String, dynamic>? get metadata;
}
