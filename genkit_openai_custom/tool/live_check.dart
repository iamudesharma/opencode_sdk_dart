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

// A live smoke test for the `openCode` bridge.
//
// It connects to the local (or remote) OpenCode server through
// `opencode_sdk_dart` and exercises model discovery, unary generation, and
// streaming. Run it with:
//
//     dart run tool/live_check.dart [model-id]
//
// With no argument it picks the first enabled model reported by the server.

import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:genkit_openai_custom/genkit_openai_custom.dart';

Future<void> main(List<String> args) async {
  final plugin = openCode();
  final actions = await plugin.list();
  if (actions.isEmpty) {
    stderr.writeln('No models were reported by the OpenCode server.');
    exitCode = 1;
    return;
  }
  final modelID = args.isNotEmpty ? args.first : actions.first.name;
  stdout.writeln('Models reported: ${actions.length}');
  stdout.writeln('Using model: $modelID');

  final ai = Genkit(plugins: [openCode()]);

  final result = await ai.generate<String, OpenCodeModelOptions>(
    model: openCode.model(modelID),
    prompt: 'Reply with exactly the two words: bridge works.',
  );
  stdout.writeln('unary   -> ${result.text.trim()}');
  if (result.usage != null) {
    stdout.writeln('usage   -> ${result.usage!.totalTokens} tokens');
  }

  final stream = ai.generateStream<String, OpenCodeModelOptions>(
    model: openCode.model(modelID),
    prompt: 'Count from 1 to 5, separated by spaces.',
  );
  var chunks = 0;
  var reasoningChunks = 0;
  final buffer = StringBuffer();
  await for (final chunk in stream) {
    for (final part in chunk.content) {
      if (part.isReasoning) reasoningChunks++;
      if (part.isText) {
        chunks++;
        buffer.write(part.text);
      }
    }
  }
  final finalResult = await stream.onResult;
  stdout.writeln(
    'stream  -> $chunks text chunk(s), $reasoningChunks reasoning chunk(s): '
    '${buffer.toString().trim()}',
  );
  stdout.writeln('final   -> ${finalResult.text.trim()}');
}
