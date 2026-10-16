// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'dart:convert';

import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
import 'package:schemantic/schemantic.dart';
import 'package:test/test.dart';

import 'support/fake_openai_host.dart';

part 'plugin_test.g.dart';

@Schema()
abstract class $Answer {
  String get answer;
}

void main() {
  group('plugin registration', () {
    test('constructs without a key or network', () {
      final plugin = openAI(name: 'nokey');
      expect(plugin.name, 'nokey');
      expect(plugin.apiKey, isNull);
      // A Genkit instance accepts the plugin without contacting anything.
      final ai = Genkit(plugins: [OpenAIPlugin(name: 'offline-llm')]);
      expect(ai.registry.lookupValue<Object?>('model', 'missing'), isNull);
    });

    test('model refs are namespaced', () {
      expect(openAI.model('gpt-4o').name, 'openai/gpt-4o');
      expect(
        openAI.model('llama-3.3', namespace: 'groq').name,
        'groq/llama-3.3',
      );
      expect(openCode.model('kimi').name, 'opencode/kimi');
    });

    test('init registers nothing and resolve builds models lazily', () async {
      final plugin = openAI(
        name: 'lazy',
        dialect: const OpenAICompatDialect(
          defaultNamespace: 'lazy',
          defaultBaseUrl: 'http://localhost:1/v1',
          apiKeyEnvVar: 'LAZY_TEST_KEY_MISSING',
        ),
      );
      expect(await plugin.init(), isEmpty);
      final model = plugin.resolve(ActionType.model, 'some-model');
      expect(model, isA<Model<OpenAIChatOptions>>());
      expect(model!.name, 'some-model');
    });

    test('list reports custom models without a key', () async {
      final plugin = openAI(
        name: 'custom-host',
        dialect: const OpenAICompatDialect(
          defaultNamespace: 'custom-host',
          defaultBaseUrl: 'http://localhost:1/v1',
          apiKeyEnvVar: 'CUSTOM_HOST_KEY_MISSING',
          apiKeyRequired: false,
          supportsJsonSchema: false,
        ),
        models: const [
          CustomModelDefinition(
            name: 'qwen3-32b',
            label: 'Qwen 3 32B',
            capabilities: ModelCapabilities(media: false),
          ),
        ],
      );
      final actions = await plugin.list();
      final names = actions.map((a) => a.name).toList();
      expect(names, contains('qwen3-32b'));
    });

    test('resolves models and embedders by kind', () {
      final plugin = openAI(apiKey: 'test');
      expect(
        plugin.resolve(ActionType.model, 'gpt-4o'),
        isA<Model<OpenAIChatOptions>>(),
      );
      expect(
        plugin.resolve(ActionType.model, 'tts-1'),
        isA<Model<OpenAISpeechOptions>>(),
      );
      expect(
        plugin.resolve(ActionType.model, 'whisper-1'),
        isA<Model<OpenAITranscriptionOptions>>(),
      );
      // Embedders resolve under their own action type.
      expect(
        plugin.resolve(ActionType.model, 'text-embedding-3-small'),
        isNull,
      );
      expect(
        plugin.resolve(ActionType.embedder, 'text-embedding-3-small'),
        isA<Embedder<OpenAIEmbedderOptions>>(),
      );
    });

    test('ships presets for common compatible hosts', () {
      expect(OpenAICompatDialect.groq.defaultBaseUrl, contains('groq.com'));
      expect(OpenAICompatDialect.together.apiKeyEnvVar, 'TOGETHER_API_KEY');
      expect(OpenAICompatDialect.mistral.defaultNamespace, 'mistral');
      expect(OpenAICompatDialect.lmStudio.apiKeyRequired, isFalse);
    });
  });

  group('generation', () {
    test('runs a unary generate through Genkit', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('gpt-4o'),
        prompt: 'Hi',
      );

      expect(result.text, 'Hello from the fake host!');
      expect(result.finishReason, FinishReason.stop);
      expect(result.usage!.totalTokens, 11);
      expect(result.usage!.cachedContentTokens, 2);
      expect(result.usage!.thoughtsTokens, 3);

      final request = host.requests.single;
      expect(request.url.path, '/v1/chat/completions');
      expect(request.headers['authorization'], 'Bearer test-key');
      expect(host.lastBody['model'], 'gpt-4o');
      final messages = (host.lastBody['messages'] as List)
          .cast<Map<String, dynamic>>();
      expect(messages.single['role'], 'user');
      expect(messages.single['content'], 'Hi');
    });

    test('streams deltas and assembles the final response', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final stream = ai.generateStream<String, OpenAIChatOptions>(
        model: openAI.model('gpt-4o'),
        prompt: 'Hi',
      );
      final chunks = <String>[];
      await for (final chunk in stream) {
        chunks.add(chunk.text);
      }
      final result = await stream.onResult;

      expect(chunks, ['Hello', ' from', ' streaming!']);
      expect(result.text, 'Hello from streaming!');
      expect(result.finishReason, FinishReason.stop);
      expect(result.usage!.totalTokens, 7);
      expect(host.lastBody['stream'], isTrue);
      expect(host.lastBody['stream_options'], {'include_usage': true});
    });

    test('surfaces model tool calls and sends tool definitions', () async {
      final host = FakeOpenAIHost(
        unaryResponse: {
          'choices': [
            {
              'message': {
                'role': 'assistant',
                'content': null,
                'tool_calls': [
                  {
                    'id': 'call_1',
                    'type': 'function',
                    'function': {
                      'name': 'weather',
                      'arguments': '{"city":"Oslo"}',
                    },
                  },
                ],
              },
              'finish_reason': 'tool_calls',
            },
          ],
        },
      );
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );
      ai.defineTool(
        name: 'weather',
        description: 'Weather by city',
        inputSchema: SchemanticType.map(
          SchemanticType.string(),
          SchemanticType.dynamicSchema(),
        ),
        fn: (input, ctx) async => .response('rainy'),
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('gpt-4o'),
        prompt: 'Weather in Oslo?',
        toolNames: ['weather'],
        returnToolRequests: true,
      );

      expect(result.toolRequests, hasLength(1));
      expect(result.toolRequests.single.name, 'weather');
      final tools = (host.lastBody['tools'] as List)
          .cast<Map<String, dynamic>>();
      expect(
        ((tools.single['function']) as Map<String, dynamic>)['name'],
        'weather',
      );
    });

    test('parses structured output', () async {
      final host = FakeOpenAIHost(
        unaryResponse: {
          'choices': [
            {
              'message': {'role': 'assistant', 'content': '{"answer":"42"}'},
              'finish_reason': 'stop',
            },
          ],
        },
      );
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final result = await ai.generate<Answer, OpenAIChatOptions>(
        model: openAI.model('gpt-4o'),
        prompt: 'The answer?',
        outputSchema: Answer.$schema,
      );

      expect(result.output!.answer, '42');
      final format = host.lastBody['response_format'] as Map<String, dynamic>;
      expect(format['type'], 'json_schema');
    });
  });

  group('embeddings', () {
    test('embeds documents through Genkit', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final embeddings = await ai.embed<OpenAIEmbedderOptions>(
        embedder: openAI.embedder('text-embedding-3-small'),
        documents: [
          DocumentData(content: [TextPart(text: 'hello')]),
          DocumentData(content: [TextPart(text: 'world')]),
        ],
        options: OpenAIEmbedderOptions(dimensions: 256),
      );

      expect(embeddings, hasLength(2));
      expect(embeddings.first.embedding, [0.1, 0.2, 0.3]);
      expect(embeddings.last.embedding, [0.2, 0.2, 0.3]);

      final request = host.requests.single;
      expect(request.url.path, '/v1/embeddings');
      expect(host.lastBody['model'], 'text-embedding-3-small');
      expect(host.lastBody['input'], ['hello', 'world']);
      expect(host.lastBody['dimensions'], 256);
    });

    test('rejects documents without text before any request', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      await expectLater(
        ai.embed<OpenAIEmbedderOptions>(
          embedder: openAI.embedder('text-embedding-3-small'),
          documents: [
            DocumentData(
              content: [
                MediaPart(
                  media: Media(
                    contentType: 'image/png',
                    url: 'data:image/png;base64,AAAA',
                  ),
                ),
              ],
            ),
          ],
        ),
        throwsA(
          isA<GenkitException>().having(
            (error) => error.status,
            'status',
            StatusCode.invalidArgument,
          ),
        ),
      );
      expect(host.requests, isEmpty);
    });

    test('validates dimensions for curated models', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      await expectLater(
        ai.embed<OpenAIEmbedderOptions>(
          embedder: openAI.embedder('text-embedding-ada-002'),
          document: DocumentData(content: [TextPart(text: 'hello')]),
          options: OpenAIEmbedderOptions(dimensions: 256),
        ),
        throwsA(isA<GenkitException>()),
      );
      expect(host.requests, isEmpty);
    });
  });

  group('speech', () {
    test('synthesizes speech into a media part', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAISpeechOptions>(
        model: openAI.speechModel('tts-1'),
        prompt: 'Say hello.',
        config: OpenAISpeechOptions(voice: 'coral', responseFormat: 'wav'),
      );

      expect(result.finishReason, FinishReason.stop);
      final media = result.media;
      expect(media!.contentType, 'audio/wav');
      expect(media.url, 'data:audio/wav;base64,${base64Encode([1, 2, 3, 4])}');

      expect(host.requests.single.url.path, '/v1/audio/speech');
      expect(host.lastBody['model'], 'tts-1');
      expect(host.lastBody['input'], 'Say hello.');
      expect(host.lastBody['voice'], 'coral');
      expect(host.lastBody['response_format'], 'wav');
    });
  });

  group('transcription', () {
    test('uploads audio and returns the transcript', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final audioBytes = [1, 2, 3, 4];
      final result = await ai.generate<String, OpenAITranscriptionOptions>(
        model: openAI.transcriptionModel('whisper-1'),
        messages: [
          Message(
            role: Role.user,
            content: [
              MediaPart(
                media: Media(
                  contentType: 'audio/mpeg',
                  url: 'data:audio/mpeg;base64,${base64Encode(audioBytes)}',
                ),
              ),
            ],
          ),
        ],
      );

      expect(result.text, 'hello from audio');
      final request = host.requests.single;
      expect(request.url.path, '/v1/audio/transcriptions');
      expect(
        request.headers['content-type'],
        startsWith('multipart/form-data'),
      );
      final raw = utf8.decode(host.rawBodies.single);
      expect(raw, contains('name="file"'));
      expect(raw, contains('filename="input.mp3"'));
      expect(raw, contains('name="model"'));
      expect(raw, contains('whisper-1'));
      expect(raw, contains('name="response_format"'));
    });

    test('rejects audio that is not a data URL', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test-key', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAITranscriptionOptions>(
        model: openAI.transcriptionModel('whisper-1'),
        messages: [
          Message(
            role: Role.user,
            content: [
              MediaPart(
                media: Media(
                  contentType: 'audio/mpeg',
                  url: 'https://example.com/audio.mp3',
                ),
              ),
            ],
          ),
        ],
      );

      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.status, StatusCode.invalidArgument.wireName);
      expect(host.requests, isEmpty);
    });
  });

  group('api key handling', () {
    test('fails with an actionable message when no key is available', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [
          openAI(
            name: 'no-key',
            httpClient: host.client,
            dialect: const OpenAICompatDialect(
              defaultNamespace: 'no-key',
              defaultBaseUrl: 'https://example.test/v1',
              apiKeyEnvVar: 'GENKIT_OPENAI_TEST_MISSING_KEY',
            ),
          ),
        ],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('gpt-4o', namespace: 'no-key'),
        prompt: 'Hi',
      );

      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.status, StatusCode.failedPrecondition.wireName);
      expect(result.error!.message, contains('GENKIT_OPENAI_TEST_MISSING_KEY'));
      expect(host.requests, isEmpty);
    });

    test('asks for no key when the dialect does not require one', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [
          openAI(
            name: 'local',
            dialect: const OpenAICompatDialect(
              defaultNamespace: 'local',
              defaultBaseUrl: 'http://localhost:11434/v1',
              apiKeyEnvVar: 'LOCAL_TEST_KEY_MISSING',
              apiKeyRequired: false,
              useLegacyMaxTokens: true,
            ),
            httpClient: host.client,
          ),
        ],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('qwen3', namespace: 'local'),
        prompt: 'Hi',
      );
      expect(result.text, isNotEmpty);
      expect(
        host.requests.single.headers.containsKey('authorization'),
        isFalse,
      );
    });
  });

  group('error handling', () {
    test('maps HTTP errors to GenkitException with a status', () async {
      final host = FakeOpenAIHost(
        statusCode: 401,
        errorBody: '{"error":{"message":"Invalid API key","type":"auth"}}',
      );
      final ai = Genkit(
        plugins: [openAI(apiKey: 'bad', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('gpt-4o'),
        prompt: 'Hi',
      );

      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.status, StatusCode.unauthenticated.wireName);
      expect(result.error!.message, contains('Invalid API key'));
    });
  });

  group('capability checks', () {
    test('rejects media for text-only models before any request', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('gpt-3.5-turbo'),
        promptParts: [
          TextPart(text: 'What is this?'),
          MediaPart(
            media: Media(
              contentType: 'image/png',
              url: 'data:image/png;base64,AAAA',
            ),
          ),
        ],
      );

      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.message, contains('image/media input'));
      expect(host.requests, isEmpty);
    });

    test('rejects reasoningEffort for non-reasoning models', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('gpt-4o'),
        prompt: 'Hi',
        config: OpenAIChatOptions(reasoningEffort: 'high'),
      );

      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.message, contains('reasoningEffort'));
      expect(host.requests, isEmpty);
    });

    test('lets unknown models through', () async {
      final host = FakeOpenAIHost();
      final ai = Genkit(
        plugins: [openAI(apiKey: 'test', httpClient: host.client)],
      );

      final result = await ai.generate<String, OpenAIChatOptions>(
        model: openAI.model('future-model-2027'),
        prompt: 'Hi',
        config: OpenAIChatOptions(reasoningEffort: 'low'),
      );

      expect(result.finishReason, FinishReason.stop);
      expect(host.lastBody['reasoning_effort'], 'low');
    });
  });

  group('model discovery', () {
    test('list merges discovered and custom models', () async {
      final host = FakeOpenAIHost(models: ['gpt-4o']);
      final plugin = openAI(
        apiKey: 'test',
        httpClient: host.client,
        models: const [CustomModelDefinition(name: 'private-llm')],
      );
      final actions = await plugin.list();
      expect(
        actions.map((a) => a.name),
        containsAll(['gpt-4o', 'private-llm']),
      );
    });

    test('list never throws when discovery fails', () async {
      final host = FakeOpenAIHost(statusCode: 500);
      final plugin = openAI(apiKey: 'test', httpClient: host.client);
      expect(await plugin.list(), isEmpty);
    });

    test('list classifies discovered models by kind', () async {
      final host = FakeOpenAIHost(
        models: ['gpt-4o', 'tts-1', 'whisper-1', 'text-embedding-3-small'],
      );
      final plugin = openAI(apiKey: 'test', httpClient: host.client);
      final actions = await plugin.list();
      final byName = {
        for (final action in actions) action.name: action.actionType,
      };
      expect(byName['gpt-4o'], ActionType.model);
      expect(byName['tts-1'], ActionType.model);
      expect(byName['whisper-1'], ActionType.model);
      expect(byName['text-embedding-3-small'], ActionType.embedder);
    });
  });
}
