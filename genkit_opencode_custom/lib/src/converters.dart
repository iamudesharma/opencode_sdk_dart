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

import 'dart:convert';

import 'package:genkit/plugin.dart';
import 'package:logging/logging.dart';
import 'package:schemantic/schemantic.dart';

import 'catalog.dart';
import 'dialect.dart';
import 'options.dart';

final _logger = Logger('genkit_opencode_custom.openai');

/// Translates between Genkit wire types and OpenAI Chat Completions JSON.
abstract final class OpenAIConverter {
  // Requests ----------------------------------------------------------------

  /// Builds the Chat Completions request body for [request].
  static Map<String, dynamic> buildChatBody({
    required ModelRequest request,
    required OpenAIChatOptions options,
    required OpenAICompatDialect dialect,
    required ModelCapabilities? capabilities,
    required String model,
    required bool streaming,
  }) {
    final includeUsage =
        streaming &&
        (options.includeUsageInStream ?? dialect.includeUsageInStream);

    final messages = _convertMessages(
      request.messages,
      systemSupported: capabilities?.systemRole ?? true,
      visualDetailLevel: options.visualDetailLevel,
    );

    final output = request.output;
    final wantsJson =
        output?.format == 'json' ||
        output?.schema != null ||
        options.jsonMode == true;

    Map<String, dynamic>? responseFormat;
    if (output?.schema != null && dialect.supportsJsonSchema) {
      var schema = output!.schema!;
      schema = _flattenSchema(schema);
      final strict = options.strictSchema ?? false;
      if (strict) schema = _strictify(schema);
      responseFormat = {
        'type': 'json_schema',
        'json_schema': {'name': 'response', 'strict': strict, 'schema': schema},
      };
    } else if (wantsJson) {
      responseFormat = {'type': 'json_object'};
      final schema = output?.schema;
      if (schema != null) {
        _insertSchemaInstruction(messages, schema, capabilities);
      }
    }

    final body = <String, dynamic>{
      'model': options.version ?? model,
      'messages': messages,
      if (request.tools != null && request.tools!.isNotEmpty)
        'tools': [for (final tool in request.tools!) _convertTool(tool, model)],
      if (request.toolChoice != null) 'tool_choice': request.toolChoice!.value,
      if (responseFormat != null) 'response_format': responseFormat,
      if (options.temperature != null) 'temperature': options.temperature,
      if (options.topP != null) 'top_p': options.topP,
      if (options.maxTokens != null)
        (dialect.useLegacyMaxTokens ? 'max_tokens' : 'max_completion_tokens'):
            options.maxTokens,
      if (options.stop != null && options.stop!.isNotEmpty)
        'stop': options.stop,
      if (options.presencePenalty != null)
        'presence_penalty': options.presencePenalty,
      if (options.frequencyPenalty != null)
        'frequency_penalty': options.frequencyPenalty,
      if (options.seed != null) 'seed': options.seed,
      if (options.user != null) 'user': options.user,
      if (options.reasoningEffort != null && dialect.supportsReasoningEffort)
        'reasoning_effort': options.reasoningEffort,
      if (options.verbosity != null && dialect.supportsReasoningEffort)
        'verbosity': options.verbosity,
      if (streaming) 'stream': true,
      if (includeUsage) 'stream_options': {'include_usage': true},
      ...dialect.extraBody,
      ...?options.extraBody,
    };
    return body;
  }

  static List<Map<String, dynamic>> _convertMessages(
    List<Message> messages, {
    required bool systemSupported,
    required String? visualDetailLevel,
  }) {
    final out = <Map<String, dynamic>>[];
    for (final message in messages) {
      if (message.role == Role.tool) {
        for (final part in message.content) {
          final response = part.toolResponse;
          if (response == null) continue;
          out.add({
            'role': 'tool',
            'tool_call_id': response.ref ?? response.name,
            'content': _toolResponseText(response),
          });
        }
        continue;
      }

      final text = <String>[];
      final media = <Map<String, dynamic>>[];
      final toolCalls = <Map<String, dynamic>>[];
      for (final part in message.content) {
        if (part.isText) {
          text.add(part.text!);
        } else if (part.isMedia) {
          media.add(_mediaPart(part.media!, visualDetailLevel));
        } else if (part.isToolRequest) {
          final toolRequest = part.toolRequest!;
          toolCalls.add({
            'id': toolRequest.ref ?? 'call_${toolCalls.length}',
            'type': 'function',
            'function': {
              'name': toolRequest.name,
              'arguments': jsonEncode(toolRequest.input ?? <String, dynamic>{}),
            },
          });
        } else if (part.isReasoning) {
          // Reasoning is output-only: replaying it is rejected by most hosts
          // (DeepSeek) or ignored, so it is intentionally dropped.
        } else {
          _logger.fine(
            'Dropping unsupported ${part.runtimeType} in a '
            '${message.role.value} message.',
          );
        }
      }

      final role = switch (message.role) {
        Role.system => systemSupported ? 'system' : 'developer',
        Role.model => 'assistant',
        _ => 'user',
      };

      if (media.isNotEmpty) {
        final content = <Map<String, dynamic>>[
          for (final chunk in text) {'type': 'text', 'text': chunk},
          ...media,
        ];
        out.add({'role': role, 'content': content});
        continue;
      }

      final joined = text.join('\n');
      if (joined.isEmpty && toolCalls.isEmpty) continue;
      out.add({
        'role': role,
        'content': joined.isEmpty ? (role == 'assistant' ? null : '') : joined,
        if (toolCalls.isNotEmpty) 'tool_calls': toolCalls,
      });
    }
    return out;
  }

  static String _toolResponseText(ToolResponse response) {
    final buffer = StringBuffer();
    final content = response.content;
    if (content is List) {
      for (final part in content) {
        if (part is Part && part.isText) {
          if (buffer.isNotEmpty) buffer.write('\n');
          buffer.write(part.text);
        }
      }
    }
    final output = response.output;
    if (buffer.isEmpty) {
      if (output is String) return output;
      return jsonEncode(output);
    }
    return buffer.toString();
  }

  static Map<String, dynamic> _mediaPart(Media media, String? detail) {
    final mimeType = (media.contentType ?? 'image/png')
        .split(';')
        .first
        .trim()
        .toLowerCase();
    final url = media.url;
    final isImage = mimeType.startsWith('image/');

    if (url.startsWith('data:')) {
      final comma = url.indexOf(',');
      if (comma < 0) {
        throw GenkitException(
          'Malformed data URL in a Media part.',
          status: StatusCode.invalidArgument,
        );
      }
      if (isImage) {
        return {
          'type': 'image_url',
          'image_url': {'url': url, if (detail != null) 'detail': detail},
        };
      }
      return {
        'type': 'file',
        'file': {
          'file_data': 'data:$mimeType;base64,${url.substring(comma + 1)}',
          'filename': _filenameFor(mimeType),
        },
      };
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (isImage) {
        return {
          'type': 'image_url',
          'image_url': {'url': url, if (detail != null) 'detail': detail},
        };
      }
      throw GenkitException(
        'Non-image media ($mimeType) must be provided as a data: URL so the '
        'content can be uploaded; remote document URLs are not supported by '
        'the Chat Completions API.',
        status: StatusCode.invalidArgument,
      );
    }

    throw GenkitException(
      'Media URLs must be http(s) or data: URLs; got "${media.url}". '
      'Read local files into a data: URL before generating.',
      status: StatusCode.invalidArgument,
    );
  }

  static Map<String, dynamic> _convertTool(ToolDefinition tool, String model) {
    final schema = tool.inputSchema;
    if (schema == null) {
      throw GenkitException(
        'Tool "${tool.name}" has no input schema; OpenAI requires one.',
        status: StatusCode.invalidArgument,
      );
    }
    final flattened = _flattenSchema(schema);
    if (flattened['type'] != 'object' && !flattened.containsKey(r'$ref')) {
      throw GenkitException(
        'Tool "${tool.name}" must have an object input schema for '
        '"$model"; got type "${flattened['type']}". Wrap the arguments in an '
        'object schema.',
        status: StatusCode.invalidArgument,
      );
    }
    // A bare `$ref` at the root is rejected by several hosts; the flattened
    // schema above resolves every reference, so re-check the root type.
    if (flattened['type'] != 'object') {
      throw GenkitException(
        'Tool "${tool.name}" must have an object input schema for '
        '"$model".',
        status: StatusCode.invalidArgument,
      );
    }
    return {
      'type': 'function',
      'function': {
        'name': tool.name,
        'description': tool.description,
        'parameters': flattened,
      },
    };
  }

  /// Inlines `$ref`/`$defs` so hosts that do not resolve references accept the
  /// schema. Recursive schemas are returned unchanged.
  static Map<String, dynamic> _flattenSchema(Map<String, dynamic> schema) {
    try {
      return schema.flatten();
    } on FormatException catch (error) {
      _logger.fine('Leaving schema references unresolved: $error');
      return schema;
    } on StateError catch (error) {
      _logger.fine('Leaving schema references unresolved: $error');
      return schema;
    }
  }

  /// Rewrites a schema for OpenAI strict mode: every object gains
  /// `additionalProperties: false` and all of its properties required.
  static Map<String, dynamic> _strictify(Map<String, dynamic> schema) {
    Map<String, dynamic> walk(Map<String, dynamic> node) {
      final result = <String, dynamic>{};
      for (final entry in node.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          result[entry.key] = walk(value);
        } else if (value is Map) {
          result[entry.key] = walk(value.cast<String, dynamic>());
        } else if (value is List) {
          result[entry.key] = [
            for (final item in value)
              if (item is Map) walk(item.cast<String, dynamic>()) else item,
          ];
        } else {
          result[entry.key] = value;
        }
      }
      if (result['type'] == 'object' || result.containsKey('properties')) {
        result['additionalProperties'] = false;
        final properties = result['properties'];
        if (properties is Map) {
          result['required'] = properties.keys.toList();
        }
      }
      return result;
    }

    return walk(schema);
  }

  /// Appends a schema instruction for hosts without `json_schema` support.
  static void _insertSchemaInstruction(
    List<Map<String, dynamic>> messages,
    Map<String, dynamic> schema,
    ModelCapabilities? capabilities,
  ) {
    final instruction =
        'Respond with a single JSON value that validates against this '
        'JSON Schema:\n${jsonEncode(_flattenSchema(schema))}';
    final role = (capabilities?.systemRole ?? true) ? 'system' : 'developer';
    final index = messages.isNotEmpty && messages.first['role'] == role ? 1 : 0;
    messages.insert(index, {'role': role, 'content': instruction});
  }

  static String _filenameFor(String mimeType) {
    final extension = switch (mimeType) {
      'application/pdf' => 'pdf',
      'text/plain' => 'txt',
      'text/csv' => 'csv',
      'application/json' => 'json',
      _ => mimeType.contains('/') ? mimeType.split('/').last : 'bin',
    };
    return 'document.$extension';
  }

  // Responses ---------------------------------------------------------------

  /// Converts a unary Chat Completions response.
  static ModelResponse toModelResponse(
    Map<String, dynamic> json, {
    required String model,
    double? latencyMs,
  }) {
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty) {
      final message = json['error'] is Map
          ? (json['error'] as Map)['message']?.toString()
          : 'The response contained no choices.';
      return ModelResponse(
        finishReason: FinishReason.failed,
        finishMessage: message,
        error: RuntimeError(
          status: StatusCode.internal.wireName,
          message: message ?? 'The response contained no choices.',
        ),
        latencyMs: latencyMs,
        raw: json,
      );
    }

    final choice = (choices.first as Map).cast<String, dynamic>();
    final rawMessage = choice['message'];
    final message = rawMessage is Map
        ? _messageFrom(rawMessage.cast<String, dynamic>())
        : null;
    return ModelResponse(
      message: message,
      finishReason: _finishReason(choice['finish_reason']?.toString()),
      latencyMs: latencyMs,
      usage: usageFrom(json['usage']),
      raw: json,
      custom: {
        if (choice['finish_reason'] != null)
          'finishReason': choice['finish_reason'],
        'model': json['model'] ?? model,
      },
    );
  }

  /// Converts a `usage` object, tolerating the OpenAI, DeepSeek and OpenRouter
  /// shapes.
  static GenerationUsage? usageFrom(Object? usage) {
    if (usage is! Map) return null;
    final promptDetails = usage['prompt_tokens_details'];
    final completionDetails = usage['completion_tokens_details'];
    return GenerationUsage(
      inputTokens: _int(usage['prompt_tokens']),
      outputTokens: _int(usage['completion_tokens']),
      totalTokens: _int(usage['total_tokens']),
      cachedContentTokens: promptDetails is Map
          ? _int(promptDetails['cached_tokens'])
          : null,
      thoughtsTokens: completionDetails is Map
          ? _int(completionDetails['reasoning_tokens'])
          : null,
    );
  }

  static FinishReason _finishReason(String? value) => switch (value) {
    null => FinishReason.unknown,
    'stop' || 'tool_calls' || 'function_call' => FinishReason.stop,
    'length' => FinishReason.length,
    'content_filter' => FinishReason.blocked,
    _ => FinishReason.other,
  };

  static Message? _messageFrom(Map<String, dynamic> message) {
    final parts = <Part>[];

    final reasoning = message['reasoning_content'] ?? message['reasoning'];
    if (reasoning is String && reasoning.isNotEmpty) {
      parts.add(ReasoningPart(reasoning: reasoning));
    }

    final content = message['content'];
    if (content is String && content.isNotEmpty) {
      parts.add(TextPart(text: content));
    } else if (content is List) {
      for (final item in content) {
        if (item is Map && item['type'] == 'text' && item['text'] is String) {
          parts.add(TextPart(text: item['text'] as String));
        }
      }
    }

    final toolCalls = message['tool_calls'];
    if (toolCalls is List) {
      for (final call in toolCalls) {
        if (call is! Map) continue;
        final function = call['function'];
        if (function is! Map) continue;
        parts.add(
          ToolRequestPart(
            toolRequest: ToolRequest(
              ref: call['id']?.toString(),
              name: function['name']?.toString() ?? '',
              input: _decodeArguments(function['arguments']),
            ),
          ),
        );
      }
    }

    if (parts.isEmpty) return null;
    return Message(role: Role.model, content: parts);
  }

  static Object? _decodeArguments(Object? arguments) {
    if (arguments == null) return null;
    if (arguments is! String) return arguments;
    if (arguments.isEmpty) return null;
    try {
      return jsonDecode(arguments);
    } on FormatException {
      return arguments;
    }
  }

  static int? _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value');
}

/// Assembles streamed Chat Completions deltas into Genkit chunks and a final
/// response.
final class ChatStreamAssembler {
  final StringBuffer _text = StringBuffer();
  final StringBuffer _reasoning = StringBuffer();
  final Map<int, _ToolCallBuilder> _toolCalls = {};
  final List<int> _toolCallOrder = [];
  String? _finishReason;
  GenerationUsage? _usage;

  /// Feeds one SSE frame. Returns the chunk to emit, or `null` when the frame
  /// carried no content (for example the usage-only final frame).
  ModelResponseChunk? add(Map<String, dynamic> frame) {
    final usage = frame['usage'];
    if (usage is Map) _usage = OpenAIConverter.usageFrom(usage);

    final choices = frame['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final choice = (choices.first as Map).cast<String, dynamic>();
    final finish = choice['finish_reason'];
    if (finish is String) _finishReason = finish;

    final delta = choice['delta'] ?? choice['message'];
    if (delta is! Map) return null;

    final parts = <Part>[];
    final reasoning = delta['reasoning_content'] ?? delta['reasoning'];
    if (reasoning is String && reasoning.isNotEmpty) {
      _reasoning.write(reasoning);
      parts.add(ReasoningPart(reasoning: reasoning));
    }

    final content = delta['content'];
    if (content is String && content.isNotEmpty) {
      _text.write(content);
      parts.add(TextPart(text: content));
    }

    final toolCalls = delta['tool_calls'];
    if (toolCalls is List) {
      for (final call in toolCalls) {
        if (call is! Map) continue;
        final index = _int(call['index']) ?? _toolCalls.length;
        final builder = _toolCalls.putIfAbsent(index, () {
          _toolCallOrder.add(index);
          return _ToolCallBuilder();
        });
        builder.accumulate(call.cast<String, dynamic>());
      }
    }

    if (parts.isEmpty) return null;
    return ModelResponseChunk(role: Role.model, index: 0, content: parts);
  }

  /// The final response assembled from every frame seen so far.
  ModelResponse finish({required String model, double? latencyMs}) {
    final parts = <Part>[];
    final reasoning = _reasoning.toString();
    if (reasoning.isNotEmpty) parts.add(ReasoningPart(reasoning: reasoning));
    final text = _text.toString();
    if (text.isNotEmpty) parts.add(TextPart(text: text));
    for (final index in _toolCallOrder) {
      final builder = _toolCalls[index]!;
      parts.add(
        ToolRequestPart(
          toolRequest: ToolRequest(
            ref: builder.id,
            name: builder.name ?? '',
            input: OpenAIConverter._decodeArguments(builder.arguments),
          ),
        ),
      );
    }

    return ModelResponse(
      message: parts.isEmpty ? null : Message(role: Role.model, content: parts),
      finishReason: OpenAIConverter._finishReason(_finishReason),
      latencyMs: latencyMs,
      usage: _usage,
      custom: {
        'model': model,
        if (_finishReason != null) 'finishReason': _finishReason,
      },
    );
  }

  static int? _int(Object? value) => value is num ? value.toInt() : null;
}

final class _ToolCallBuilder {
  String? id;
  String? name;
  String arguments = '';

  void accumulate(Map<String, dynamic> delta) {
    if (delta['id'] is String) id = delta['id'] as String;
    final function = delta['function'];
    if (function is! Map) return;
    if (function['name'] is String) name = function['name'] as String;
    final args = function['arguments'];
    if (args is String) arguments += args;
  }
}
