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

import 'package:genkit/plugin.dart';
import 'package:genkit_openai_custom/genkit_openai_custom.dart';
import 'package:genkit_openai_custom/src/converters.dart';
import 'package:test/test.dart';

Map<String, dynamic> userRequest({
  Map<String, dynamic>? config,
  List<ToolDefinition>? tools,
  ToolChoice? toolChoice,
  OutputConfig? output,
  List<Message>? messages,
}) {
  return OpenAIConverter.buildChatBody(
    request: ModelRequest(
      messages:
          messages ??
          [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
      config: config,
      tools: tools,
      toolChoice: toolChoice,
      output: output,
    ),
    options: config == null
        ? OpenAIChatOptions()
        : OpenAIChatOptions.fromJson(config),
    dialect: OpenAICompatDialect.openAI,
    capabilities: const ModelCapabilities(),
    model: 'gpt-4o',
    streaming: false,
  );
}

void main() {
  group('buildChatBody messages', () {
    test('maps roles and text parts', () {
      final body = userRequest(
        messages: [
          Message(
            role: Role.system,
            content: [TextPart(text: 'Be brief.')],
          ),
          Message(
            role: Role.user,
            content: [TextPart(text: 'Hi')],
          ),
          Message(
            role: Role.model,
            content: [TextPart(text: 'Hello!')],
          ),
        ],
      );
      final messages = body['messages'] as List;
      expect(messages, hasLength(3));
      expect((messages[0] as Map<String, dynamic>)['role'], 'system');
      expect((messages[1] as Map<String, dynamic>)['role'], 'user');
      expect((messages[2] as Map<String, dynamic>)['role'], 'assistant');
    });

    test('rewrites system to developer for reasoning models', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.system,
              content: [TextPart(text: 'Be brief.')],
            ),
          ],
        ),
        options: OpenAIChatOptions(),
        dialect: OpenAICompatDialect.openAI,
        capabilities: reasoningCapabilities,
        model: 'o3',
        streaming: false,
      );
      final messages = body['messages'] as List;
      expect((messages.single as Map<String, dynamic>)['role'], 'developer');
    });

    test('converts tool requests and tool responses', () {
      final body = userRequest(
        messages: [
          Message(
            role: Role.user,
            content: [TextPart(text: 'Weather?')],
          ),
          Message(
            role: Role.model,
            content: [
              ToolRequestPart(
                toolRequest: ToolRequest(
                  ref: 'call_1',
                  name: 'weather',
                  input: {'city': 'Paris'},
                ),
              ),
            ],
          ),
          Message(
            role: Role.tool,
            content: [
              ToolResponsePart(
                toolResponse: ToolResponse(
                  ref: 'call_1',
                  name: 'weather',
                  output: {'temp': 21},
                ),
              ),
            ],
          ),
        ],
      );
      final messages = (body['messages'] as List).cast<Map<String, dynamic>>();
      final assistant = messages[1];
      expect(assistant['content'], isNull);
      final call =
          (assistant['tool_calls'] as List).single as Map<String, dynamic>;
      expect(call['id'], 'call_1');
      expect((call['function'] as Map<String, dynamic>)['name'], 'weather');
      expect(
        (call['function'] as Map<String, dynamic>)['arguments'],
        '{"city":"Paris"}',
      );
      final tool = messages[2];
      expect(tool['role'], 'tool');
      expect(tool['tool_call_id'], 'call_1');
      expect(tool['content'], '{"temp":21}');
    });

    test('drops reasoning parts from replayed history', () {
      final body = userRequest(
        messages: [
          Message(
            role: Role.model,
            content: [ReasoningPart(reasoning: 'thinking...')],
          ),
        ],
      );
      expect(body['messages'], isEmpty);
    });

    test('sends images as content arrays', () {
      final body = userRequest(
        messages: [
          Message(
            role: Role.user,
            content: [
              TextPart(text: 'What is this?'),
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
      final message = (body['messages'] as List).single as Map<String, dynamic>;
      final content = (message['content'] as List).cast<Map<String, dynamic>>();
      expect(content.first['type'], 'text');
      expect(content.last['type'], 'image_url');
      expect(
        (content.last['image_url'] as Map<String, dynamic>)['url'],
        'data:image/png;base64,AAAA',
      );
    });

    test('rejects local file paths for media', () {
      expect(
        () => userRequest(
          messages: [
            Message(
              role: Role.user,
              content: [
                MediaPart(
                  media: Media(contentType: 'image/png', url: '/tmp/a.png'),
                ),
              ],
            ),
          ],
        ),
        throwsA(
          isA<GenkitException>()
              .having((e) => e.status, 'status', StatusCode.invalidArgument)
              .having((e) => e.message, 'message', contains('data:')),
        ),
      );
    });
  });

  group('buildChatBody parameters', () {
    test('sends max_completion_tokens by default', () {
      final body = userRequest(config: {'maxTokens': 64});
      expect(body['max_completion_tokens'], 64);
      expect(body.containsKey('max_tokens'), isFalse);
    });

    test('sends max_tokens for dialects with legacy fields', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
          config: {'maxTokens': 64},
        ),
        options: OpenAIChatOptions(maxTokens: 64),
        dialect: OpenAICompatDialect.deepSeek,
        capabilities: null,
        model: 'deepseek-chat',
        streaming: false,
      );
      expect(body['max_tokens'], 64);
      expect(body.containsKey('max_completion_tokens'), isFalse);
    });

    test('merges dialect and per-request extra body fields', () {
      const dialect = OpenAICompatDialect(
        extraBody: {
          'thinking': {'type': 'enabled'},
          'shared': 'dialect',
        },
      );
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
        ),
        options: OpenAIChatOptions(
          extraBody: const {'shared': 'request', 'topK': 40},
        ),
        dialect: dialect,
        capabilities: null,
        model: 'deepseek-reasoner',
        streaming: false,
      );
      expect(body['thinking'], {'type': 'enabled'});
      expect(body['shared'], 'request');
      expect(body['topK'], 40);
    });

    test('adds stream_options when streaming and configured', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
        ),
        options: OpenAIChatOptions(),
        dialect: OpenAICompatDialect.openAI,
        capabilities: null,
        model: 'gpt-4o',
        streaming: true,
      );
      expect(body['stream'], isTrue);
      expect(body['stream_options'], {'include_usage': true});
    });

    test('omits stream_options when the dialect says so', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
        ),
        options: OpenAIChatOptions(),
        dialect: OpenAICompatDialect.ollama,
        capabilities: null,
        model: 'qwen',
        streaming: true,
      );
      expect(body.containsKey('stream_options'), isFalse);
    });

    test('per-request includeUsageInStream overrides the dialect', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(messages: const []),
        options: OpenAIChatOptions(includeUsageInStream: true),
        dialect: OpenAICompatDialect.ollama,
        capabilities: null,
        model: 'qwen',
        streaming: true,
      );
      expect(body['stream_options'], {'include_usage': true});
    });
  });

  group('tools and structured output', () {
    test('flattens tool input schema references', () {
      final body = userRequest(
        tools: [
          ToolDefinition(
            name: 'weather',
            description: 'Gets the weather',
            inputSchema: {
              'type': 'object',
              'properties': {
                'city': {r'$ref': r'#/$defs/City'},
              },
              r'$defs': {
                'City': {'type': 'string', 'description': 'City name'},
              },
            },
          ),
        ],
        toolChoice: ToolChoice.auto,
      );
      final tool = (body['tools'] as List).single as Map<String, dynamic>;
      expect(tool['type'], 'function');
      final function = tool['function'] as Map<String, dynamic>;
      expect(function['name'], 'weather');
      final parameters = function['parameters'] as Map<String, dynamic>;
      expect(parameters.containsKey(r'$defs'), isFalse);
      expect((parameters['properties'] as Map<String, dynamic>)['city'], {
        'type': 'string',
        'description': 'City name',
      });
      expect(body['tool_choice'], 'auto');
    });

    test('rejects non-object tool schemas', () {
      expect(
        () => userRequest(
          tools: [
            ToolDefinition(
              name: 'bad',
              description: 'Bad tool',
              inputSchema: {'type': 'string'},
            ),
          ],
        ),
        throwsA(
          isA<GenkitException>().having(
            (e) => e.status,
            'status',
            StatusCode.invalidArgument,
          ),
        ),
      );
    });

    test('emits json_schema response_format when supported', () {
      final body = userRequest(
        output: OutputConfig(
          format: 'json',
          schema: {
            'type': 'object',
            'properties': {
              'answer': {'type': 'string'},
            },
          },
        ),
      );
      final format = body['response_format'] as Map<String, dynamic>;
      expect(format['type'], 'json_schema');
      final jsonSchema = format['json_schema'] as Map<String, dynamic>;
      expect(jsonSchema['strict'], isFalse);
      expect((jsonSchema['schema'] as Map<String, dynamic>)['type'], 'object');
    });

    test('strict mode requires every property', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
          output: OutputConfig(
            format: 'json',
            schema: {
              'type': 'object',
              'properties': {
                'answer': {'type': 'string'},
                'extra': {'type': 'integer'},
              },
            },
          ),
        ),
        options: OpenAIChatOptions(strictSchema: true),
        dialect: OpenAICompatDialect.openAI,
        capabilities: null,
        model: 'gpt-4o',
        streaming: false,
      );
      final schema =
          (body['response_format'] as Map<String, dynamic>)['json_schema']
              as Map<String, dynamic>;
      expect(schema['strict'], isTrue);
      final definition = schema['schema'] as Map<String, dynamic>;
      expect(definition['additionalProperties'], isFalse);
      expect(definition['required'], ['answer', 'extra']);
    });

    test('falls back to json_object with an instruction when unsupported', () {
      final body = OpenAIConverter.buildChatBody(
        request: ModelRequest(
          messages: [
            Message(
              role: Role.user,
              content: [TextPart(text: 'Hi')],
            ),
          ],
          output: OutputConfig(
            format: 'json',
            schema: {
              'type': 'object',
              'properties': {
                'answer': {'type': 'string'},
              },
            },
          ),
        ),
        options: OpenAIChatOptions(),
        dialect: OpenAICompatDialect.deepSeek,
        capabilities: null,
        model: 'deepseek-chat',
        streaming: false,
      );
      expect(
        (body['response_format'] as Map<String, dynamic>)['type'],
        'json_object',
      );
      final first = ((body['messages'] as List).first as Map<String, dynamic>);
      expect(first['role'], 'system');
      expect(first['content'], contains('JSON Schema'));
    });

    test('sends json_object for jsonMode without an output schema', () {
      final body = userRequest(config: {'jsonMode': true});
      expect(body['response_format'], {'type': 'json_object'});
    });
  });

  group('responses', () {
    test('maps a unary completion to a ModelResponse', () {
      final response = OpenAIConverter.toModelResponse({
        'model': 'gpt-4o',
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': 'Hi there',
              'reasoning_content': 'because',
            },
            'finish_reason': 'stop',
          },
        ],
        'usage': {
          'prompt_tokens': 4,
          'completion_tokens': 5,
          'total_tokens': 9,
          'completion_tokens_details': {'reasoning_tokens': 2},
        },
      }, model: 'gpt-4o');
      expect(response.text, 'Hi there');
      expect(response.finishReason, FinishReason.stop);
      expect(response.usage!.inputTokens, 4);
      expect(response.usage!.thoughtsTokens, 2);
      final parts = response.message!.content;
      expect(parts.any((Part p) => p.isReasoning), isTrue);
    });

    test('maps tool calls to ToolRequestParts', () {
      final response = OpenAIConverter.toModelResponse({
        'choices': [
          {
            'message': {
              'role': 'assistant',
              'content': null,
              'tool_calls': [
                {
                  'id': 'call_9',
                  'type': 'function',
                  'function': {
                    'name': 'weather',
                    'arguments': '{"city":"Paris"}',
                  },
                },
              ],
            },
            'finish_reason': 'tool_calls',
          },
        ],
      }, model: 'gpt-4o');
      expect(response.finishReason, FinishReason.stop);
      final request = response.message!.content.single.toolRequest!;
      expect(request.ref, 'call_9');
      expect(request.name, 'weather');
      expect(request.input, {'city': 'Paris'});
    });

    test('maps content_filter to blocked', () {
      final response = OpenAIConverter.toModelResponse({
        'choices': [
          {
            'message': {'role': 'assistant', 'content': ''},
            'finish_reason': 'content_filter',
          },
        ],
      }, model: 'gpt-4o');
      expect(response.finishReason, FinishReason.blocked);
    });
  });

  group('ChatStreamAssembler', () {
    test('assembles text, reasoning, usage and finish reason', () {
      final assembler = ChatStreamAssembler();
      final chunks = <ModelResponseChunk>[];
      for (final frame in [
        {
          'choices': [
            {
              'delta': {'reasoning_content': 'hmm'},
            },
          ],
        },
        {
          'choices': [
            {
              'delta': {'content': 'Hel'},
            },
          ],
        },
        {
          'choices': [
            {
              'delta': {'content': 'lo'},
              'finish_reason': 'stop',
            },
          ],
        },
        {
          'choices': <dynamic>[],
          'usage': {
            'prompt_tokens': 1,
            'completion_tokens': 2,
            'total_tokens': 3,
          },
        },
      ]) {
        final chunk = assembler.add(frame);
        if (chunk != null) chunks.add(chunk);
      }
      final response = assembler.finish(model: 'gpt-4o');
      expect(chunks, hasLength(3));
      expect(chunks.first.content.single.isReasoning, isTrue);
      expect(response.text, 'Hello');
      expect(response.finishReason, FinishReason.stop);
      expect(response.usage!.totalTokens, 3);
      expect(
        response.message!.content
            .where((Part p) => p.isReasoning)
            .single
            .reasoning,
        'hmm',
      );
    });

    test('accumulates tool call deltas across frames', () {
      final assembler = ChatStreamAssembler();
      for (final frame in [
        {
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'id': 'call_1',
                    'type': 'function',
                    'function': {'name': 'weather', 'arguments': '{"ci'},
                  },
                ],
              },
            },
          ],
        },
        {
          'choices': [
            {
              'delta': {
                'tool_calls': [
                  {
                    'index': 0,
                    'function': {'arguments': 'ty":"Paris"}'},
                  },
                ],
              },
              'finish_reason': 'tool_calls',
            },
          ],
        },
      ]) {
        assembler.add(frame);
      }
      final response = assembler.finish(model: 'gpt-4o');
      final request = response.message!.content.single.toolRequest!;
      expect(request.name, 'weather');
      expect(request.input, {'city': 'Paris'});
    });
  });

  group('capability catalog', () {
    test('knows gpt-3.5 has no vision', () {
      expect(curatedCapabilities('gpt-3.5-turbo')!.media, isFalse);
    });

    test('knows o1-preview has no tools', () {
      expect(curatedCapabilities('o1-preview')!.tools, isFalse);
    });

    test('knows reasoning models', () {
      expect(curatedCapabilities('o3-mini')!.reasoning, isTrue);
      expect(curatedCapabilities('gpt-5.2')!.reasoning, isTrue);
      expect(curatedCapabilities('gpt-4o-2024-08-06')!.reasoning, isFalse);
    });

    test('normalizes date suffixes', () {
      expect(curatedCapabilities('gpt-4o-2024-08-06'), isNotNull);
      expect(curatedCapabilities('gpt-4-0613'), isNotNull);
    });

    test('returns null for unknown names', () {
      expect(curatedCapabilities('my-custom-model'), isNull);
    });
  });
}
