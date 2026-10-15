import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Who authored a transcript entry.
enum ChatRole { user, assistant, notice }

/// One renderable piece of an assistant message.
sealed class ChatPart {
  const ChatPart();

  int get ordinal;
}

/// Streamed model text.
final class ChatTextPart extends ChatPart {
  ChatTextPart({this.text = '', this.done = false, this.ordinal = 0});

  String text;
  bool done;

  @override
  final int ordinal;
}

/// Streamed reasoning ("thinking") text.
final class ChatReasoningPart extends ChatPart {
  ChatReasoningPart({this.text = '', this.done = false, this.ordinal = 0});

  String text;
  bool done;

  @override
  final int ordinal;
}

/// Tool call lifecycle used by [ChatToolPart].
enum ChatToolStatus { streaming, running, completed, failed }

/// A tool invocation rendered as a card.
final class ChatToolPart extends ChatPart {
  ChatToolPart({
    required this.id,
    required this.name,
    this.status = ChatToolStatus.streaming,
    this.input = '',
    this.inputJson,
    this.output,
    this.error,
    this.metadata,
    this.ordinal = -1,
  });

  final String id;
  final String name;
  ChatToolStatus status;

  /// Raw JSON while the arguments stream.
  String input;

  /// Parsed arguments once the tool runs.
  Map<String, Object?>? inputJson;

  /// Human readable result preview.
  String? output;
  String? error;
  Map<String, Object?>? metadata;

  @override
  final int ordinal;
}

/// One entry in the chat transcript.
final class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.time,
    this.text = '',
    List<ChatPart>? parts,
    this.agent,
    this.model,
    this.cost,
    this.tokens,
    this.finish,
    this.errorMessage,
    this.notice,
    this.streaming = false,
    this.toolCount = 0,
  }) : parts = parts ?? <ChatPart>[];

  final String id;
  final ChatRole role;
  final DateTime time;

  /// Prompt text for user messages, description for notices.
  String text;

  /// Assistant content parts.
  final List<ChatPart> parts;

  /// Last seen agent id for assistant messages.
  String? agent;

  /// Last seen model reference for assistant messages.
  ModelRef? model;

  /// Cost reported when the step ended.
  MoneyUSD? cost;

  /// Token usage reported when the step ended.
  TokenUsageInfo? tokens;

  /// Provider finish reason, when completed.
  String? finish;

  /// Provider/structured error text, when failed.
  String? errorMessage;

  /// Optional notice body (system/idle/compaction entries).
  String? notice;

  /// Whether the assistant is still streaming into this message.
  bool streaming;

  /// Count of tool calls, for a compact collapsed header.
  int toolCount;

  /// Whether this notice should be rendered at all.
  bool get isEmpty =>
      role == ChatRole.assistant && parts.isEmpty && !streaming && toolCount == 0;

  /// Decodes an API message into its chat representation.
  static ChatMessage? fromApi(SessionMessageInfo info) {
    final created = _createdAt(info);
    return switch (info) {
      SessionMessageUser user => ChatMessage(
          id: user.id,
          role: ChatRole.user,
          time: created,
          text: user.text,
        ),
      SessionMessageAssistant assistant => ChatMessage(
          id: assistant.id,
          role: ChatRole.assistant,
          time: created,
          parts: assistant.content.map(_partFromApi).toList(),
          toolCount: assistant.content
              .whereType<SessionMessageAssistantTool>()
              .length,
          agent: assistant.agent,
          model: assistant.model,
          cost: assistant.cost,
          tokens: assistant.tokens,
          finish: assistant.finish?.wire,
          errorMessage: assistant.error?.message,
        ),
      SessionMessageCompaction compaction => ChatMessage(
          id: compaction.id,
          role: ChatRole.notice,
          time: created,
          text: 'Context compacted',
          notice: switch (compaction) {
            SessionMessageCompactionCompleted() => 'Context compacted',
            SessionMessageCompactionFailed() => 'Compaction failed',
            _ => 'Compacting context\u2026',
          },
        ),
      SessionMessageIdle idle => ChatMessage(
          id: idle.id,
          role: ChatRole.notice,
          time: created,
          text: 'Turn finished',
          notice: switch (idle.outcome) {
            SessionMessageIdleOutcome.failed => 'Turn failed',
            SessionMessageIdleOutcome.interrupted => 'Turn interrupted',
            _ => 'Turn finished',
          },
        ),
      SessionMessageSystem system => ChatMessage(
          id: system.id,
          role: ChatRole.notice,
          time: created,
          text: system.text,
          notice: system.text,
        ),
      SessionMessageSynthetic synthetic => ChatMessage(
          id: synthetic.id,
          role: ChatRole.notice,
          time: created,
          text: synthetic.text,
          notice: synthetic.text,
        ),
      SessionMessageShell shell => ChatMessage(
          id: shell.id,
          role: ChatRole.notice,
          time: created,
          text: shell.command,
          notice: 'Shell: ${shell.command} (${shell.status.wire})',
        ),
      SessionMessageSkill skill => ChatMessage(
          id: skill.id,
          role: ChatRole.notice,
          time: created,
          text: skill.name,
          notice: 'Skill activated: ${skill.name}',
        ),
      SessionMessageAgentSelected selected => ChatMessage(
          id: selected.id,
          role: ChatRole.notice,
          time: created,
          text: selected.agent,
          notice: 'Agent switched to ${selected.agent}',
        ),
      SessionMessageModelSelected selected => ChatMessage(
          id: selected.id,
          role: ChatRole.notice,
          time: created,
          text: '${selected.model.providerID}/${selected.model.id}',
          notice:
              'Model switched to ${selected.model.providerID}/${selected.model.id}',
        ),
      SessionMessageLocationSwitched switched => ChatMessage(
          id: switched.id,
          role: ChatRole.notice,
          time: created,
          text: switched.location.directory ?? '',
          notice: 'Moved to ${switched.location.directory ?? 'unknown'}',
        ),
    };
  }

  static ChatPart _partFromApi(SessionMessageAssistantContent content) {
    return switch (content) {
      SessionMessageAssistantText text =>
        ChatTextPart(text: text.text, done: true),
      SessionMessageAssistantReasoning reasoning =>
        ChatReasoningPart(text: reasoning.text, done: true),
      SessionMessageAssistantTool tool => ChatToolPart(
          id: tool.id,
          name: tool.name,
          status: switch (tool.state) {
            SessionMessageToolStateStreaming() => ChatToolStatus.streaming,
            SessionMessageToolStateRunning() => ChatToolStatus.running,
            SessionMessageToolStateCompleted() => ChatToolStatus.completed,
            SessionMessageToolStateError() => ChatToolStatus.failed,
          },
          inputJson: switch (tool.state) {
            SessionMessageToolStateRunning(:final input) => input,
            SessionMessageToolStateCompleted(:final input) => input,
            SessionMessageToolStateError(:final input) => input,
            _ => null,
          },
          input: switch (tool.state) {
            SessionMessageToolStateStreaming(:final input) => input,
            _ => '',
          },
          output: switch (tool.state) {
            SessionMessageToolStateCompleted(:final content) =>
              toolContentPreview(content),
            SessionMessageToolStateError(:final content) =>
              toolContentPreview(content ?? const []),
            _ => null,
          },
          error: switch (tool.state) {
            SessionMessageToolStateError(:final error) => error.message,
            _ => null,
          },
          metadata: switch (tool.state) {
            SessionMessageToolStateRunning(:final metadata) => metadata,
            SessionMessageToolStateCompleted(:final metadata) => metadata,
            SessionMessageToolStateError(:final metadata) => metadata,
            _ => null,
          },
        ),
    };
  }

  static double? _createdAtNum(SessionMessageInfo info) {
    final time = info.toJson()['time'];
    if (time is Map) {
      final created = time['created'];
      if (created is num) return created.toDouble();
    }
    return null;
  }

  static DateTime _createdAt(SessionMessageInfo info) {
    final created = _createdAtNum(info);
    if (created == null) return DateTime.now();
    return DateTime.fromMillisecondsSinceEpoch(created.round());
  }
}

/// Renders tool content parts into a readable preview string.
String toolContentPreview(List<ToolContent> content) {
  final buffer = StringBuffer();
  for (final part in content) {
    switch (part) {
      case ToolTextContent text:
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(text.text);
      case ToolFileContent file:
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer
          ..write('\u{1F4CE} ')
          ..write(file.name ?? file.uri)
          ..write(' (')
          ..write(file.mime)
          ..write(')');
    }
  }
  return buffer.toString();
}
