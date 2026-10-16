// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:genkit/plugin.dart';

import 'catalog.dart';
import 'options.dart';

/// Pre-flight capability checking for model requests.
///
/// The checks turn the most common provider 400s into actionable client-side
/// errors. They only run for models the curated catalog knows; unknown names
/// are passed through so a brand-new model is never blocked by stale metadata.
abstract final class CapabilityChecker {
  /// Throws a [GenkitException] when [request] or [options] ask [modelName]
  /// for something [capabilities] say it cannot do.
  static void check({
    required String modelName,
    required ModelCapabilities capabilities,
    required ModelRequest request,
    required OpenAIChatOptions options,
  }) {
    final tools = request.tools;
    if (tools != null && tools.isNotEmpty && !capabilities.tools) {
      throw _unsupported(
        modelName,
        'tool calling',
        'Remove `toolNames` or pick a tool-capable model.',
      );
    }

    if (request.toolChoice != null && !capabilities.toolChoice) {
      throw _unsupported(
        modelName,
        '`toolChoice`',
        'The model always decides whether to call a tool.',
      );
    }

    if (!capabilities.media &&
        request.messages.any(
          (message) => message.content.any((part) => part.isMedia),
        )) {
      throw _unsupported(
        modelName,
        'image/media input',
        'Use a multimodal model (for example `gpt-4o`) or remove the media '
            'parts.',
      );
    }

    if (!capabilities.jsonOutput && _wantsOutput(request)) {
      throw _unsupported(
        modelName,
        'structured output',
        'Use a model that supports JSON output, or drop `outputSchema` / '
            '`outputFormat`.',
      );
    }

    if (options.reasoningEffort != null && !capabilities.reasoning) {
      throw _unsupported(
        modelName,
        '`reasoningEffort`',
        'Only reasoning models accept `reasoningEffort`. Drop the option or '
            'switch to a reasoning model (for example `o3` or `gpt-5`).',
      );
    }
  }

  static bool _wantsOutput(ModelRequest request) {
    final output = request.output;
    if (output == null) return false;
    return output.format == 'json' || output.schema != null;
  }

  static GenkitException _unsupported(
    String modelName,
    String feature,
    String hint,
  ) {
    return GenkitException(
      'Model "$modelName" does not support $feature. $hint',
      status: StatusCode.invalidArgument,
    );
  }
}
