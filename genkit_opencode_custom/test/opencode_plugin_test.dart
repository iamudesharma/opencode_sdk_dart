// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:genkit/genkit.dart';
import 'package:genkit_opencode_custom/genkit_opencode_custom.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;
import 'package:schemantic/schemantic.dart';
import 'package:test/test.dart';

import 'support/fake_opencode_host.dart';

part 'opencode_plugin_test.g.dart';

@Schema()
abstract class $Answer {
  String get answer;
}

void main() {
  group('registration', () {
    test('constructs offline and registers nothing eagerly', () async {
      final plugin = openCode();
      expect(plugin.name, 'opencode');
      expect(await plugin.init(), isEmpty);
      // No connection was attempted: invalid base URLs only fail on use.
      final lazy = openCode(name: 'remote', baseUrl: 'http://127.0.0.1:1');
      expect(await lazy.init(), isEmpty);
    });

    test('resolve builds a model without contacting the server', () {
      final plugin = openCode();
      final model = plugin.resolve(ActionType.model, 'kimi-k2.6');
      expect(model, isA<Model<OpenCodeModelOptions>>());
      expect(plugin.resolve(ActionType.tool, 'x'), isNull);
    });
  });

  group('with a fake server', () {
    late FakeOpenCodeHost host;
    late sdk.OpenCodeClient client;
    late Genkit ai;

    setUp(() {
      host = FakeOpenCodeHost();
      // `clientFactory` matters: requests carrying a cancellation token use a
      // dedicated client, which must also be the fake one in tests.
      client = sdk.OpenCodeClient(
        baseUrl: Uri.parse('http://fake.opencode'),
        httpClient: host.client,
        clientFactory: () => host.client,
      );
      ai = Genkit(plugins: [openCode(client: client)]);
    });

    test('list reports enabled server models with capabilities', () async {
      final actions = await (openCode(client: client)).list();
      final names = actions.map((a) => a.name).toList();
      expect(names, contains('kimi-k2.6'));
      // Disabled models are hidden from the Dev UI.
      expect(names, isNot(contains('disabled-model')));

      final kimi = actions.firstWhere((a) => a.name == 'kimi-k2.6');
      final model = (kimi.metadata['model'] as Map).cast<String, dynamic>();
      expect(model['label'], 'Kimi K2.6');
      final supports = (model['supports'] as Map).cast<String, dynamic>();
      expect(supports['media'], isTrue);
      // Genkit tools are not routed through the bridge.
      expect(supports['tools'], isFalse);
    });

    test('generates text through the stateless endpoint', () async {
      final result = await ai.generate<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'Say hi',
      );

      expect(result.text, 'Hello from the OpenCode server!');
      expect(result.finishReason, FinishReason.stop);

      final generate = host.requests.firstWhere(
        (r) => r.url.path == '/api/experimental/generate',
      );
      expect(generate.method, 'POST');
      final body = host.bodies[host.requests.indexOf(generate)];
      expect(body['model'], {'id': 'kimi-k2.6', 'providerID': 'opencode-go'});
      expect(body['prompt'], 'User: Say hi');
    });

    test('renders multi-turn history into the prompt', () async {
      await ai.generate<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        messages: [
          Message(
            role: Role.system,
            content: [TextPart(text: 'Be terse.')],
          ),
          Message(
            role: Role.user,
            content: [TextPart(text: 'Hello')],
          ),
          Message(
            role: Role.model,
            content: [TextPart(text: 'Hi!')],
          ),
          Message(
            role: Role.user,
            content: [TextPart(text: 'Who are you?')],
          ),
        ],
      );
      final generate = host.requests.firstWhere(
        (r) => r.url.path == '/api/experimental/generate',
      );
      final prompt =
          (host.bodies[host.requests.indexOf(generate)]['prompt'] as String);
      expect(prompt, contains('Be terse.'));
      expect(prompt, contains('User: Hello'));
      expect(prompt, contains('Assistant: Hi!'));
      expect(prompt.endsWith('User: Who are you?'), isTrue);
    });

    test('streams through an ephemeral session and cleans it up', () async {
      host.eventFrames = [
        FakeOpenCodeHost.textDelta('ses_fake1', 'Hello'),
        FakeOpenCodeHost.reasoningDelta('ses_fake1', 'thinking'),
        FakeOpenCodeHost.textDelta('ses_fake1', ' OpenCode'),
        FakeOpenCodeHost.stepEnded('ses_fake1'),
        FakeOpenCodeHost.executionSucceeded('ses_fake1'),
      ];

      final stream = ai.generateStream<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'Stream please',
      );
      final text = <String>[];
      final reasoning = <String>[];
      await for (final chunk in stream) {
        for (final part in chunk.content) {
          if (part.isReasoning) reasoning.add(part.reasoning!);
          if (part.isText) text.add(part.text!);
        }
      }
      final result = await stream.onResult;

      expect(text, ['Hello', ' OpenCode']);
      expect(reasoning, ['thinking']);
      expect(result.text, 'Hello OpenCode');
      expect(
        result.usage!.inputTokens,
        13,
      ); // 10 input + 2 cache read + 1 write
      expect(result.usage!.outputTokens, 8); // 5 output + 3 reasoning
      expect(result.usage!.cachedContentTokens, 2);
      expect(host.removedSessions, ['ses_fake1']);

      // The session was created with the resolved model ref.
      final create = host.requests.firstWhere(
        (r) => r.url.path == '/api/session' && r.method == 'POST',
      );
      final createBody = host.bodies[host.requests.indexOf(create)];
      expect(createBody['model'], {
        'id': 'kimi-k2.6',
        'providerID': 'opencode-go',
      });
    });

    test('reconciles text and reasoning that only arrive as *.ended', () async {
      host.eventFrames = [
        FakeOpenCodeHost.textDelta('ses_fake1', 'Hello'),
        FakeOpenCodeHost.textEnded('ses_fake1', 'Hello world'),
        FakeOpenCodeHost.reasoningEnded('ses_fake1', 'because'),
        FakeOpenCodeHost.executionSucceeded('ses_fake1'),
      ];

      final stream = ai.generateStream<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'Stream please',
      );
      final text = <String>[];
      final reasoning = <String>[];
      await for (final chunk in stream) {
        for (final part in chunk.content) {
          if (part.isReasoning) reasoning.add(part.reasoning!);
          if (part.isText) text.add(part.text!);
        }
      }
      final result = await stream.onResult;

      // The ended event's suffix was emitted, not the whole text again.
      expect(text, ['Hello', ' world']);
      expect(reasoning, ['because']);
      expect(result.text, 'Hello world');
    });

    test('completes from session state when the event stream ends early', () async {
      // The stream carries one delta and then *ends* without an execution
      // event; the bridge must fall back to polling the session.
      host.eventFrames = [FakeOpenCodeHost.textDelta('ses_fake1', 'Hello')];
      host.assistantMessageText = 'Hello from the session record';
      host.assistantMessageReasoning = 'thought about it';

      final stream = ai.generateStream<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'Stream please',
      );
      final text = <String>[];
      await for (final chunk in stream) {
        for (final part in chunk.content) {
          if (part.isText) text.add(part.text!);
        }
      }
      final result = await stream.onResult;

      // The delta arrived as a chunk, and the final response carries the
      // server's reconciled text (not just the delta).
      expect(text, ['Hello']);
      expect(result.text, 'Hello from the session record');
      expect(result.finishReason, FinishReason.stop);
      expect(
        result.message!.content
            .where((Part part) => part.isReasoning)
            .single
            .reasoning,
        'thought about it',
      );
      expect(host.removedSessions, ['ses_fake1']);
    });

    test('fails fast when the request carries Genkit tools', () async {
      ai.defineTool(
        name: 'someTool',
        description: 'Does nothing',
        inputSchema: SchemanticType.dynamicSchema(),
        fn: (input, ctx) async => .response('ok'),
      );
      final result = await ai.generate<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'Use a tool',
        toolNames: ['someTool'],
      );
      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.status, StatusCode.unimplemented.wireName);
      expect(result.error!.message, contains('openAI()'));
    });

    test('fails with notFound for unknown model ids', () async {
      final result = await ai.generate<String, OpenCodeModelOptions>(
        model: openCode.model('missing-model'),
        prompt: 'Hi',
      );
      expect(result.finishReason, FinishReason.failed);
      expect(result.error!.status, StatusCode.notFound.wireName);
    });

    test('structured output injects schema instructions and parses JSON', () async {
      host.generateText = '{"answer": "42"}';

      final result = await ai.generate<Answer, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'What is the answer?',
        outputSchema: Answer.$schema,
      );

      expect(result.output?.answer, '42');

      final generate = host.requests.firstWhere(
        (r) => r.url.path == '/api/experimental/generate',
      );
      final prompt =
          host.bodies[host.requests.indexOf(generate)]['prompt'] as String;
      expect(prompt, contains('Output should be in JSON format'));
      expect(prompt, contains('"answer"'));
    });

    test('forwards media parts as session prompt attachments', () async {
      host.assistantMessageText = 'I see a cat.';

      final result = await ai.generate<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        messages: [
          Message(
            role: Role.user,
            content: [
              TextPart(text: 'What is in this image?'),
              MediaPart(
                media: Media(
                  contentType: 'image/png',
                  url: 'data:image/png;base64,AAAA',
                ),
              ),
            ],
          ),
        ],
      );

      expect(result.text, 'I see a cat.');

      // The request ran through a session (the stateless endpoint takes text
      // only) and the attachment rode along on the prompt.
      final prompt = host.requests.firstWhere(
        (r) => RegExp(r'^/api/session/[^/]+/prompt$').hasMatch(r.url.path),
      );
      final body = host.bodies[host.requests.indexOf(prompt)];
      expect(body['files'], [
        {'uri': 'data:image/png;base64,AAAA'},
      ]);
      expect(host.removedSessions, ['ses_fake1']);
    });

    test('reuses a server session when sessionID is set', () async {
      host.eventFrames = [FakeOpenCodeHost.executionSucceeded('ses_reuse')];
      host.assistantMessageText = 'continued';

      final result = await ai.generate<String, OpenCodeModelOptions>(
        model: openCode.model('kimi-k2.6'),
        prompt: 'Continue',
        config: OpenCodeModelOptions(sessionID: 'ses_reuse'),
      );

      expect(result.text, 'continued');

      // No ephemeral session was created, and none was deleted.
      expect(
        host.requests.where(
          (r) => r.url.path == '/api/session' && r.method == 'POST',
        ),
        isEmpty,
      );
      expect(host.removedSessions, isEmpty);

      // The requested model was switched on the reused session.
      final switchModel = host.requests.firstWhere(
        (r) => r.url.path == '/api/session/ses_reuse/model',
      );
      final body = host.bodies[host.requests.indexOf(switchModel)];
      expect(body['model'], {'id': 'kimi-k2.6', 'providerID': 'opencode-go'});
    });

    test('registers the websearch tool only when enabled', () async {
      expect(await openCode(client: client).init(), isEmpty);

      final plugin = openCode(client: client, webSearchTool: true);
      final actions = await plugin.init();
      expect(actions, hasLength(1));
      expect(actions.single.name, 'opencode/websearch');
    });

    test('websearch tool resolves under its namespaced name', () async {
      final ai = Genkit(
        plugins: [openCode(client: client, webSearchTool: true)],
      );
      final tool = await ai.registry.lookupAction(
        ActionType.tool,
        'opencode/websearch',
      );
      expect(tool, isA<Tool<WebSearchToolInput, WebSearchToolOutput>>());
    });

    test('websearch tool queries the server', () async {
      final plugin = openCode(client: client, webSearchTool: true);
      final tool = (await plugin.init()).single
          as Tool<WebSearchToolInput, WebSearchToolOutput>;

      final result = await tool.call(WebSearchToolInput(query: 'dart'));

      expect(result.output.provider, 'exa');
      final hit = result.output.results.single;
      expect(hit.title, 'Dart');
      expect(hit.url, 'https://example.com/dart');
      expect(hit.content, 'Dart is a language.');

      final search = host.requests.firstWhere(
        (r) => r.url.path == '/api/websearch',
      );
      final body = host.bodies[host.requests.indexOf(search)];
      expect(body['query'], 'dart');
    });
  });
}
