// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

/// Genkit Dart plugin for OpenCode and OpenAI-compatible Chat Completions.
///
/// [openCode] bridges models served by a local or remote OpenCode server
/// through `opencode_sdk_dart`: model discovery, unary generation, streaming,
/// and cancellation all run through the SDK.
///
/// [openAI] is the companion handle for OpenAI and OpenAI-compatible hosts —
/// a direct Chat Completions client that reuses the SDK's SSE framing and
/// cancellation primitives, and the handle to use when Genkit should own the
/// tool loop.
///
/// ```dart
/// import 'package:genkit/genkit.dart';
/// import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
///
/// void main() async {
///   final ai = Genkit(plugins: [openCode()]);
///   final response = await ai.generate<String, OpenCodeModelOptions>(
///     model: openCode.model('kimi-k2.6'),
///     prompt: 'Summarize what OpenCode is.',
///   );
///   print(response.text);
/// }
/// ```
library;

export 'src/capabilities.dart';
export 'src/catalog.dart';
export 'src/dialect.dart';
export 'src/opencode_plugin.dart';
export 'src/openai_plugin.dart';
export 'src/options.dart';
export 'src/tools.dart';
