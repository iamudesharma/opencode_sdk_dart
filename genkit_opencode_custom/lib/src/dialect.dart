// Copyright 2026 The genkit_opencode_custom authors.
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

/// How a host deviates from OpenAI's Chat Completions API.
///
/// The plugin writes a single Chat Completions body for every host; a dialect
/// only flips the switches that break OpenAI-compatible servers in practice.
/// Start with [OpenAICompatDialect.openAI] and use a preset or the unnamed
/// constructor for other hosts.
final class OpenAICompatDialect {
  const OpenAICompatDialect({
    this.defaultNamespace = 'openai',
    this.defaultBaseUrl = 'https://api.openai.com/v1',
    this.apiKeyEnvVar = 'OPENAI_API_KEY',
    this.apiKeyRequired = true,
    this.useLegacyMaxTokens = false,
    this.supportsJsonSchema = true,
    this.includeUsageInStream = true,
    this.supportsReasoningEffort = true,
    this.extraBody = const {},
  });

  /// Default plugin namespace used to name models (`<namespace>/<model>`).
  final String defaultNamespace;

  /// Base URL used when the plugin is constructed without one.
  final String defaultBaseUrl;

  /// Environment variable consulted when no API key is supplied.
  final String apiKeyEnvVar;

  /// Whether a key (or key provider) is required to send requests. Local
  /// hosts such as Ollama accept none.
  final bool apiKeyRequired;

  /// Sends `max_tokens` instead of `max_completion_tokens`.
  final bool useLegacyMaxTokens;

  /// Whether `response_format: {"type": "json_schema"}` is accepted.
  ///
  /// When `false`, structured-output requests fall back to `json_object` plus
  /// a schema instruction appended to the conversation.
  final bool supportsJsonSchema;

  /// Whether `stream_options: {"include_usage": true}` is accepted.
  final bool includeUsageInStream;

  /// Whether `reasoning_effort` may be sent for reasoning models.
  final bool supportsReasoningEffort;

  /// Fields merged into every request body, beneath per-request `extraBody`.
  final Map<String, Object?> extraBody;

  /// OpenAI's own API.
  static const OpenAICompatDialect openAI = OpenAICompatDialect();

  /// DeepSeek: `max_tokens`, JSON object mode only, no `reasoning_effort`,
  /// and `reasoning_content` on reasoning responses.
  static const OpenAICompatDialect deepSeek = OpenAICompatDialect(
    defaultNamespace: 'deepseek',
    defaultBaseUrl: 'https://api.deepseek.com/v1',
    apiKeyEnvVar: 'DEEPSEEK_API_KEY',
    useLegacyMaxTokens: true,
    supportsJsonSchema: false,
    supportsReasoningEffort: false,
  );

  /// xAI (Grok models).
  static const OpenAICompatDialect xAI = OpenAICompatDialect(
    defaultNamespace: 'xai',
    defaultBaseUrl: 'https://api.x.ai/v1',
    apiKeyEnvVar: 'XAI_API_KEY',
    supportsJsonSchema: false,
    supportsReasoningEffort: false,
  );

  /// OpenRouter.
  static const OpenAICompatDialect openRouter = OpenAICompatDialect(
    defaultNamespace: 'openrouter',
    defaultBaseUrl: 'https://openrouter.ai/api/v1',
    apiKeyEnvVar: 'OPENROUTER_API_KEY',
    supportsReasoningEffort: false,
  );

  /// A local Ollama server's OpenAI-compatible endpoint.
  static const OpenAICompatDialect ollama = OpenAICompatDialect(
    defaultNamespace: 'ollama',
    defaultBaseUrl: 'http://localhost:11434/v1',
    apiKeyEnvVar: 'OLLAMA_API_KEY',
    apiKeyRequired: false,
    useLegacyMaxTokens: true,
    includeUsageInStream: false,
    supportsReasoningEffort: false,
  );
}
