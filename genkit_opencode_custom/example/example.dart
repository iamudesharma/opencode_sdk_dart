// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;
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

      // `webSearchTool: true` registers the server's web search as a Genkit
      // tool named `<name>/websearch` (here `opencode-search/websearch`).
      // It is usable from models of any plugin; the bridge's own models run
      // the server's agent loop instead.
      openCode(name: 'opencode-search', webSearchTool: true),
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

  // 7. Persistent session multi-turn through the bridge: both generations
  // share one server session, so the follow-up remembers the first turn.
  final bridgeClient = await sdk.OpenCodeClient.connectLocal();
  final bridgeSession = await bridgeClient.session.create(
    title: 'genkit bridge example',
  );
  final sessionOptions = OpenCodeModelOptions(
    sessionID: bridgeSession.id.value,
  );
  final remembered = await ai.generate<String, OpenCodeModelOptions>(
    model: openCode.model('kimi-k2.6'),
    prompt: 'Remember the number 42. Reply with just "ok".',
    config: sessionOptions,
  );
  print('turn 1: ${remembered.text}');
  final recall = await ai.generate<String, OpenCodeModelOptions>(
    model: openCode.model('kimi-k2.6'),
    prompt: 'Which number did I ask you to remember? Reply with the number.',
    config: sessionOptions,
  );
  print('turn 2: ${recall.text}');
  bridgeClient.close();

  // 8. Structured output through the bridge: the schema travels as JSON
  // instructions and Genkit parses the response.
  final bridgeReview = await ai.generate<Review, OpenCodeModelOptions>(
    model: openCode.model('kimi-k2.6'),
    prompt: 'Review this code: int add(int a, int b) => a + b;',
    outputSchema: Review.$schema,
  );
  final bridgeOutput = bridgeReview.output;
  if (bridgeOutput != null) {
    print('bridge review: ${bridgeOutput.score}/10 — ${bridgeOutput.summary}');
  }

  // 9. Embeddings through the OpenAI handle. `document:` embeds one document;
  // the `documents:` form is the batch call (Genkit's `embedMany`).
  final vector = await ai.embed(
    embedder: openAI.embedder('text-embedding-3-small'),
    document: DocumentData(
      content: [TextPart(text: 'Genkit bridges OpenCode and OpenAI hosts.')],
    ),
  );
  print('embedding: ${vector.first.embedding.length} dimensions');

  final batch = await ai.embed(
    embedder: openAI.embedder('text-embedding-3-small'),
    documents: [
      DocumentData(content: [TextPart(text: 'first document')]),
      DocumentData(content: [TextPart(text: 'second document')]),
    ],
  );
  print('batch: ${batch.length} embeddings');

  // 10. Speech: `tts-1` returns one audio MediaPart as a base64 data URL.
  final speech = await ai.generate<String, OpenAISpeechOptions>(
    model: openAI.speechModel('tts-1'),
    prompt: 'OpenCode and Genkit, together on one phone.',
  );
  final audio = speech.media;
  final audioData = audio == null ? null : Uri.parse(audio.url).data;
  print(
    'speech: ${audioData?.contentAsBytes().length ?? 0} bytes '
    '(${audioData?.mimeType})',
  );

  // 11. Transcription (needs an audio file): `whisper-1` takes the audio as a
  // base64 data URL in a media part and answers with the transcript text.
  //
  //   final transcript = await ai.generate<String, OpenAITranscriptionOptions>(
  //     model: openAI.transcriptionModel('whisper-1'),
  //     messages: [
  //       Message(
  //         role: Role.user,
  //         content: [
  //           MediaPart(
  //             media: Media(
  //               contentType: 'audio/mpeg',
  //               url: 'data:audio/mpeg;base64,'
  //                   '${base64Encode(File('speech.mp3').readAsBytesSync())}',
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  //   print(transcript.text);

  // 12. Dialect presets for other OpenAI-compatible hosts — each registers
  // its own namespace and reads its own API key environment variable:
  //
  //   openAI(dialect: OpenAICompatDialect.groq)      // GROQ_API_KEY
  //   openAI(dialect: OpenAICompatDialect.together)  // TOGETHER_API_KEY
  //   openAI(dialect: OpenAICompatDialect.mistral)   // MISTRAL_API_KEY
  //   openAI(dialect: OpenAICompatDialect.lmStudio)  // local, no key needed
}
