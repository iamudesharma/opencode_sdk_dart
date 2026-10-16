// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

// A live smoke test for the `openCode` bridge.
//
// It connects to the local (or remote) OpenCode server through
// `opencode_sdk_dart` and exercises model discovery, unary generation,
// streaming, structured output, and persistent sessions. Run it with:
//
//     dart run tool/live_check.dart [model-id]
//
// With no argument it picks the first enabled model reported by the server.

import 'dart:io';

import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;
import 'package:schemantic/schemantic.dart';

part 'live_check.g.dart';

@Schema()
abstract class $LiveAnswer {
  String get greeting;
  int get number;
}

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

  // Structured output: the schema rides along as prompt instructions and
  // Genkit parses the response into the typed object.
  final structured = await ai.generate<LiveAnswer, OpenCodeModelOptions>(
    model: openCode.model(modelID),
    prompt: 'Answer with JSON only: greeting is "hello" and number is 7.',
    outputSchema: LiveAnswer.$schema,
  );
  stdout.writeln(
    'json    -> greeting=${structured.output?.greeting} '
    'number=${structured.output?.number}',
  );
  if (structured.output == null) {
    stdout.writeln('json raw -> ${structured.text.trim()}');
  }

  // Persistent session: two turns share one server session.
  final client = await sdk.OpenCodeClient.connectLocal();
  final session = await client.session.create(title: 'genkit live check');
  try {
    final first = await ai.generate<String, OpenCodeModelOptions>(
      model: openCode.model(modelID),
      prompt: 'Remember this number: 41.',
      config: OpenCodeModelOptions(sessionID: session.id.value),
    );
    final second = await ai.generate<String, OpenCodeModelOptions>(
      model: openCode.model(modelID),
      prompt: 'Which number did I ask you to remember? Reply with it only.',
      config: OpenCodeModelOptions(sessionID: session.id.value),
    );
    stdout.writeln('session -> first="${first.text.trim()}"');
    stdout.writeln('session -> second="${second.text.trim()}"');
  } finally {
    await client.session.remove(sessionID: session.id);
    client.close();
  }
}
