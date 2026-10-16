// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:genkit/plugin.dart';

/// Capability flags for a chat model.
///
/// These drive two things: the metadata the Genkit Dev UI shows for a model,
/// and the pre-flight checks the plugin runs before a request leaves the
/// process. They are advisory for unknown models — a name outside the catalog
/// is assumed to support everything except reasoning parameters.
final class ModelCapabilities {
  const ModelCapabilities({
    this.multiturn = true,
    this.systemRole = true,
    this.tools = true,
    this.toolChoice = true,
    this.media = true,
    this.jsonOutput = true,
    this.constrainedOutput = true,
    this.reasoning = false,
  });

  /// The model can be used in multi-turn conversations.
  final bool multiturn;

  /// The model accepts `system` messages. Reasoning models take `developer`
  /// instead, and the converter rewrites them.
  final bool systemRole;

  /// The model can be offered tools.
  final bool tools;

  /// The model honors `tool_choice`.
  final bool toolChoice;

  /// The model accepts image inputs.
  final bool media;

  /// The model can be asked for JSON output (`json_object`).
  final bool jsonOutput;

  /// The model accepts `json_schema` structured outputs.
  final bool constrainedOutput;

  /// The model accepts `reasoning_effort`.
  final bool reasoning;

  /// The `supports` map Genkit uses in model metadata.
  Map<String, dynamic> toSupports() => {
    'multiturn': multiturn,
    'systemRole': systemRole,
    'tools': tools,
    'toolChoice': toolChoice,
    'media': media,
    'output': jsonOutput ? const ['text', 'json'] : const ['text'],
    if (constrainedOutput) 'constrained': true,
    if (reasoning) 'reasoning': true,
  };

  /// The `ModelInfo` Genkit uses in model metadata.
  ModelInfo toModelInfo({String? label}) =>
      ModelInfo(label: label, supports: toSupports());

  @override
  String toString() =>
      'ModelCapabilities(tools: $tools, media: $media, json: $jsonOutput, '
      'constrained: $constrainedOutput, reasoning: $reasoning)';
}

// Common presets ------------------------------------------------------------

/// Current multimodal chat models: tools, images, JSON, and native
/// constrained generation.
const ModelCapabilities multimodalCapabilities = ModelCapabilities();

/// Multimodal chat models that predate structured outputs.
const ModelCapabilities multimodalLegacyCapabilities = ModelCapabilities(
  constrainedOutput: false,
);

/// Text-only chat models without image input.
const ModelCapabilities textOnlyCapabilities = ModelCapabilities(
  media: false,
  constrainedOutput: false,
);

/// Reasoning models that reject `system` messages.
const ModelCapabilities reasoningCapabilities = ModelCapabilities(
  systemRole: false,
  reasoning: true,
);

/// Reasoning models without image input.
const ModelCapabilities reasoningTextOnlyCapabilities = ModelCapabilities(
  systemRole: false,
  media: false,
  reasoning: true,
  constrainedOutput: false,
);

// Catalog -------------------------------------------------------------------

/// Strips snapshot/date suffixes (`-2024-08-06`, `-0613`, `-20250219`) so
/// aliases and dated snapshots share one entry.
String _normalize(String modelName) {
  var name = modelName.toLowerCase();
  final slash = name.lastIndexOf('/');
  if (slash >= 0) name = name.substring(slash + 1);
  name = name.replaceAll(RegExp(r'-\d{4}(-\d{2}){0,2}$'), '');
  name = name.replaceAll(RegExp(r'-\d{4}$'), '');
  return name;
}

/// Curated capabilities for [modelName], or `null` when the name is unknown.
///
/// The catalog is intentionally small: it exists to catch the cases where
/// sending a request would fail (tools to `o1-preview`, images to `gpt-3.5`,
/// `reasoning_effort` to a non-reasoning model), not to be an exhaustive
/// model list. Unknown names are assumed capable and pass through.
ModelCapabilities? curatedCapabilities(String modelName) {
  final name = _normalize(modelName);

  // OpenAI o-series previews: no tools, no images, no system role.
  if (name.startsWith('o1-preview') || name.startsWith('o1-mini')) {
    return ModelCapabilities(
      systemRole: false,
      tools: false,
      toolChoice: false,
      media: false,
      jsonOutput: false,
      constrainedOutput: false,
      reasoning: true,
    );
  }

  // OpenAI o-series (o1, o3, o4-mini, ...): reasoning, tools, and vision from
  // o3 onwards.
  if (RegExp(r'^o\d').hasMatch(name)) {
    return ModelCapabilities(
      systemRole: false,
      media: !name.startsWith('o1'),
      reasoning: true,
    );
  }

  // GPT-5 family: reasoning with the full modern surface.
  if (name.startsWith('gpt-5')) {
    return ModelCapabilities(systemRole: false, reasoning: true);
  }

  // GPT-4.1 and GPT-4o families: multimodal, tools, structured outputs.
  if (name.startsWith('gpt-4.1') ||
      name.startsWith('gpt-4o') ||
      name.startsWith('chatgpt-4o')) {
    return multimodalCapabilities;
  }

  // Legacy GPT-4 aliases and snapshots: no native structured outputs.
  if (name == 'gpt-4' ||
      name.startsWith('gpt-4-turbo') ||
      name.startsWith('gpt-4-')) {
    return multimodalLegacyCapabilities;
  }

  // GPT-3.5: text-only.
  if (name.startsWith('gpt-3.5')) {
    return ModelCapabilities(media: false, constrainedOutput: false);
  }

  // DeepSeek.
  if (name.startsWith('deepseek-reasoner') || name.startsWith('deepseek-r1')) {
    return const ModelCapabilities(
      media: false,
      jsonOutput: false,
      constrainedOutput: false,
      reasoning: true,
    );
  }
  if (name.startsWith('deepseek')) {
    return const ModelCapabilities(media: false, constrainedOutput: false);
  }

  // xAI Grok.
  if (name.startsWith('grok')) {
    return const ModelCapabilities(media: true, constrainedOutput: false);
  }

  return null;
}
