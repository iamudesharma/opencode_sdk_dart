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
