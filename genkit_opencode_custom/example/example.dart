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

import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
import 'package:schemantic/schemantic.dart';

part 'example.g.dart';

@Schema()
abstract class $LookupInput {
  /// Package name to look up.
  String get packageName;
}

@Schema()
abstract class $Review {
  /// One-sentence summary.
  String get summary;

  /// Score from 1 to 10.
  @IntegerField(minimum: 1, maximum: 10)
  int get score;

  /// Concrete issues found, if any.
  List<String> get issues;
}

void main() async {
  final ai = Genkit(
    plugins: [
      // Standard OpenAI; reads OPENAI_API_KEY at request time.
      openAI(),

      // Any OpenAI-compatible host gets its own namespace.
      openAI(
        name: 'ollama',
        dialect: OpenAICompatDialect.ollama,
        baseUrl: 'http://localhost:11434/v1',
        models: const [
          CustomModelDefinition(
            name: 'qwen3:32b',
            capabilities: ModelCapabilities(media: false),
          ),
        ],
      ),

      // Models from the local (or remote) OpenCode server.
      openCode(),
    ],
  );

  // 1. Simple generation.
  final greeting = await ai.generate<String, OpenAIChatOptions>(
    model: openAI.model('gpt-4o-mini'),
    prompt: 'Say hello in one short sentence.',
  );
  print(greeting.text);

  // 2. Streaming.
  final stream = ai.generateStream<String, OpenAIChatOptions>(
    model: openAI.model('gpt-4o'),
    prompt: 'Write a haiku about Dart.',
    config: OpenAIChatOptions(temperature: 0.7, maxTokens: 100),
  );
  await for (final chunk in stream) {
    stdout.write(chunk.text);
  }
  print('\n');

  // 3. Multi-turn conversation.
  final followUp = await ai.generate<String, OpenAIChatOptions>(
    model: openAI.model('gpt-4o'),
    messages: [
      Message(
        role: Role.system,
        content: [TextPart(text: 'You are a concise Dart expert.')],
      ),
      Message(
        role: Role.user,
        content: [TextPart(text: 'What is Genkit?')],
      ),
      Message(
        role: Role.model,
        content: [TextPart(text: 'A framework for building AI features.')],
      ),
      Message(
        role: Role.user,
        content: [TextPart(text: 'Who makes it?')],
      ),
    ],
  );
  print(followUp.text);

  // 4. Tool calling: Genkit owns the loop.
  ai.defineTool(
    name: 'lookupPackage',
    description: 'Looks up a package version on pub.dev.',
    inputSchema: LookupInput.$schema,
    outputSchema: SchemanticType.string(),
    fn: (input, ctx) async => .response('${input.packageName}: 1.0.0'),
  );
  final withTools = await ai.generate<String, OpenAIChatOptions>(
    model: openAI.model('gpt-4o'),
    prompt: 'What version is the genkit package?',
    toolNames: ['lookupPackage'],
  );
  print(withTools.text);

  // 5. Structured output.
  final review = await ai.generate<Review, OpenAIChatOptions>(
    model: openAI.model('gpt-4o'),
    prompt: 'Review this code: int add(int a, int b) => a + b;',
    outputSchema: Review.$schema,
  );
  final output = review.output;
  if (output != null) {
    print('${output.score}/10 — ${output.summary}');
  }

  // 6. Models from the OpenCode server.
  final openCodeResult = await ai.generate<String, OpenCodeModelOptions>(
    model: openCode.model('kimi-k2.6'),
    prompt: 'Summarize what OpenCode is in one sentence.',
  );
  print(openCodeResult.text);
}
