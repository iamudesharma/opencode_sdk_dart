// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `FileDiff.Info`
final class FileDiffInfo {
  const FileDiffInfo({
    required this.file,
    required this.patch,
    required this.additions,
    required this.deletions,
    required this.status,
  });

  factory FileDiffInfo.fromJson(Map<String, Object?> json) => FileDiffInfo(
        file: decodeString(json, 'file'),
        patch: decodeString(json, 'patch'),
        additions: decodeInt(json, 'additions'),
        deletions: decodeInt(json, 'deletions'),
        status: FileDiffInfoStatus.fromJson(json['status']),
      );

  final String file;
  final String patch;
  final int additions;
  final int deletions;
  final FileDiffInfoStatus status;

  Map<String, Object?> toJson() => <String, Object?>{
        'file': file,
        'patch': patch,
        'additions': additions,
        'deletions': deletions,
        'status': status.wire,
      };
}

/// `Session.ForkBoundary`
sealed class SessionForkBoundary {
  const SessionForkBoundary();

  /// Decodes a payload into the matching variant.
  factory SessionForkBoundary.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'before' => SessionForkBoundaryBefore.fromJson(json),
      'through' => SessionForkBoundaryThrough.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Session.ForkBoundary discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`messageID`).
  SessionMessageID get messageID;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `SessionForkBoundaryBefore`
final class SessionForkBoundaryBefore extends SessionForkBoundary {
  const SessionForkBoundaryBefore({
    required this.messageID,
  });

  factory SessionForkBoundaryBefore.fromJson(Map<String, Object?> json) =>
      SessionForkBoundaryBefore(
        messageID: SessionMessageID.fromJson(asJsonString(json['messageID'])),
      );

  @override
  final SessionMessageID messageID;

  /// Always `before`.
  @override
  String get type => 'before';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'before',
        'messageID': messageID,
      };
}

/// `SessionForkBoundaryThrough`
final class SessionForkBoundaryThrough extends SessionForkBoundary {
  const SessionForkBoundaryThrough({
    required this.messageID,
  });

  factory SessionForkBoundaryThrough.fromJson(Map<String, Object?> json) =>
      SessionForkBoundaryThrough(
        messageID: SessionMessageID.fromJson(asJsonString(json['messageID'])),
      );

  @override
  final SessionMessageID messageID;

  /// Always `through`.
  @override
  String get type => 'through';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'through',
        'messageID': messageID,
      };
}

/// `Session.Inbox.Compaction`
final class SessionInboxCompaction extends SessionInboxInfo {
  const SessionInboxCompaction({
    required this.id,
    required this.sessionID,
    required this.time,
    required this.payload,
    required this.delivery,
  });

  factory SessionInboxCompaction.fromJson(Map<String, Object?> json) =>
      SessionInboxCompaction(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        time: SessionInboxCompactionTime.fromJson(asJsonMap(json['time'])),
        payload: json['payload'],
        delivery: SessionInboxDelivery.fromJson(json['delivery']),
      );

  @override
  final SessionMessageID id;
  @override
  final SessionID sessionID;
  final SessionInboxCompactionTime time;
  final Object? payload;
  @override
  final SessionInboxDelivery delivery;

  /// Always `compaction`.
  @override
  String get type => 'compaction';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'time': time.toJson(),
        'type': 'compaction',
        'payload': payload,
        'delivery': delivery.wire,
      };
}

/// `Session.Inbox.Info`
sealed class SessionInboxInfo {
  const SessionInboxInfo();

  /// Decodes a payload into the matching variant.
  factory SessionInboxInfo.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'user' => SessionInboxUser.fromJson(json),
      'synthetic' => SessionInboxSynthetic.fromJson(json),
      'compaction' => SessionInboxCompaction.fromJson(json),
      'move' => SessionInboxMove.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Session.Inbox.Info discriminator: $value'),
    };
  }

  /// Present on every variant (`id`).
  SessionMessageID get id;

  /// Present on every variant (`sessionID`).
  SessionID get sessionID;

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`delivery`).
  SessionInboxDelivery get delivery;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Session.Inbox.User`
final class SessionInboxUser extends SessionInboxInfo {
  const SessionInboxUser({
    required this.id,
    required this.sessionID,
    required this.time,
    required this.payload,
    required this.delivery,
  });

  factory SessionInboxUser.fromJson(Map<String, Object?> json) =>
      SessionInboxUser(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        time: SessionInboxUserTime.fromJson(asJsonMap(json['time'])),
        payload: SessionInboxUserPayload.fromJson(asJsonMap(json['payload'])),
        delivery: SessionInboxDelivery.fromJson(json['delivery']),
      );

  @override
  final SessionMessageID id;
  @override
  final SessionID sessionID;
  final SessionInboxUserTime time;
  final SessionInboxUserPayload payload;
  @override
  final SessionInboxDelivery delivery;

  /// Always `user`.
  @override
  String get type => 'user';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'time': time.toJson(),
        'type': 'user',
        'payload': payload.toJson(),
        'delivery': delivery.wire,
      };
}

/// `Session.Inbox.UserPayload`
final class SessionInboxUserPayload {
  const SessionInboxUserPayload({
    required this.text,
    this.files,
    this.agents,
    this.skills,
    this.metadata,
  });

  factory SessionInboxUserPayload.fromJson(Map<String, Object?> json) =>
      SessionInboxUserPayload(
        text: decodeString(json, 'text'),
        files: json['files'] == null
            ? null
            : jsonList(json['files'],
                (item) => PromptFileAttachment.fromJson(asJsonMap(item))),
        agents: json['agents'] == null
            ? null
            : jsonList(json['agents'],
                (item) => PromptAgentAttachment.fromJson(asJsonMap(item))),
        skills: json['skills'] == null
            ? null
            : jsonList(json['skills'],
                (item) => PromptSkillAttachment.fromJson(asJsonMap(item))),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final String text;
  final List<PromptFileAttachment>? files;
  final List<PromptAgentAttachment>? agents;
  final List<PromptSkillAttachment>? skills;
  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
        if (files != null) 'files': [for (final item in files!) item.toJson()],
        if (agents != null)
          'agents': [for (final item in agents!) item.toJson()],
        if (skills != null)
          'skills': [for (final item in skills!) item.toJson()],
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `Session.Inbox.Synthetic`
final class SessionInboxSynthetic extends SessionInboxInfo {
  const SessionInboxSynthetic({
    required this.id,
    required this.sessionID,
    required this.time,
    required this.payload,
    required this.delivery,
  });

  factory SessionInboxSynthetic.fromJson(Map<String, Object?> json) =>
      SessionInboxSynthetic(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        time: SessionInboxSyntheticTime.fromJson(asJsonMap(json['time'])),
        payload:
            SessionInboxSyntheticPayload.fromJson(asJsonMap(json['payload'])),
        delivery: SessionInboxDelivery.fromJson(json['delivery']),
      );

  @override
  final SessionMessageID id;
  @override
  final SessionID sessionID;
  final SessionInboxSyntheticTime time;
  final SessionInboxSyntheticPayload payload;
  @override
  final SessionInboxDelivery delivery;

  /// Always `synthetic`.
  @override
  String get type => 'synthetic';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'time': time.toJson(),
        'type': 'synthetic',
        'payload': payload.toJson(),
        'delivery': delivery.wire,
      };
}

/// `Session.Inbox.SyntheticPayload`
final class SessionInboxSyntheticPayload {
  const SessionInboxSyntheticPayload({
    required this.text,
    this.description,
    this.metadata,
  });

  factory SessionInboxSyntheticPayload.fromJson(Map<String, Object?> json) =>
      SessionInboxSyntheticPayload(
        text: decodeString(json, 'text'),
        description: decodeOptionalString(json, 'description'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final String text;
  final String? description;
  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
        if (description != null) 'description': description!,
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `Session.Inbox.Move`
final class SessionInboxMove extends SessionInboxInfo {
  const SessionInboxMove({
    required this.id,
    required this.sessionID,
    required this.time,
    required this.delivery,
    required this.payload,
  });

  factory SessionInboxMove.fromJson(Map<String, Object?> json) =>
      SessionInboxMove(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        time: SessionInboxMoveTime.fromJson(asJsonMap(json['time'])),
        delivery: SessionInboxDelivery.fromJson(json['delivery']),
        payload: SessionInboxMovePayload.fromJson(asJsonMap(json['payload'])),
      );

  @override
  final SessionMessageID id;
  @override
  final SessionID sessionID;
  final SessionInboxMoveTime time;
  @override
  final SessionInboxDelivery delivery;
  final SessionInboxMovePayload payload;

  /// Always `move`.
  @override
  String get type => 'move';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'time': time.toJson(),
        'type': 'move',
        'delivery': delivery.wire,
        'payload': payload.toJson(),
      };
}

/// `Session.Inbox.MovePayload`
final class SessionInboxMovePayload {
  const SessionInboxMovePayload({
    required this.projectID,
    this.subpath,
    required this.location,
  });

  factory SessionInboxMovePayload.fromJson(Map<String, Object?> json) =>
      SessionInboxMovePayload(
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        subpath: json['subpath'] == null
            ? null
            : RelativePath.fromJson(asJsonString(json['subpath'])),
        location: LocationRef.fromJson(json['location']),
      );

  final ProjectID projectID;
  final RelativePath? subpath;
  final LocationRef location;

  Map<String, Object?> toJson() => <String, Object?>{
        'projectID': projectID,
        if (subpath != null) 'subpath': subpath!,
        'location': location.toJson(),
      };
}

/// `Session.Info`
final class SessionInfo {
  const SessionInfo({
    required this.id,
    this.parentID,
    this.fork,
    required this.projectID,
    this.agent,
    this.model,
    required this.cost,
    required this.tokens,
    this.outcome,
    required this.time,
    this.title,
    this.subpath,
    this.metadata,
    this.permissions,
    this.revert,
    required this.location,
  });

  factory SessionInfo.fromJson(Map<String, Object?> json) => SessionInfo(
        id: SessionID.fromJson(asJsonString(json['id'])),
        parentID: json['parentID'] == null
            ? null
            : SessionID.fromJson(asJsonString(json['parentID'])),
        fork: json['fork'] == null
            ? null
            : SessionInfoFork.fromJson(asJsonMap(json['fork'])),
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        agent: json['agent'] == null
            ? null
            : AgentID.fromJson(asJsonString(json['agent'])),
        model: json['model'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['model'])),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        outcome: json['outcome'] == null
            ? null
            : SessionInfoOutcome.fromJson(json['outcome']),
        time: SessionInfoTime.fromJson(asJsonMap(json['time'])),
        title: decodeOptionalString(json, 'title'),
        subpath: json['subpath'] == null
            ? null
            : RelativePath.fromJson(asJsonString(json['subpath'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        permissions: json['permissions'] == null
            ? null
            : jsonList(json['permissions'],
                (item) => PermissionRule.fromJson(asJsonMap(item))),
        revert: json['revert'] == null
            ? null
            : SessionRevert.fromJson(asJsonMap(json['revert'])),
        location: LocationRef.fromJson(json['location']),
      );

  final SessionID id;
  final SessionID? parentID;
  final SessionInfoFork? fork;
  final ProjectID projectID;
  final AgentID? agent;
  final ModelRef? model;
  final MoneyUSD cost;
  final TokenUsageInfo tokens;
  final SessionInfoOutcome? outcome;
  final SessionInfoTime time;
  final String? title;
  final RelativePath? subpath;
  final Map<String, Object?>? metadata;
  final List<PermissionRule>? permissions;
  final SessionRevert? revert;
  final LocationRef location;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (parentID != null) 'parentID': parentID!,
        if (fork != null) 'fork': fork!.toJson(),
        'projectID': projectID,
        if (agent != null) 'agent': agent!,
        if (model != null) 'model': model!.toJson(),
        'cost': cost,
        'tokens': tokens.toJson(),
        if (outcome != null) 'outcome': outcome!.wire,
        'time': time.toJson(),
        if (title != null) 'title': title!,
        if (subpath != null) 'subpath': subpath!,
        if (metadata != null) 'metadata': metadata!,
        if (permissions != null)
          'permissions': [for (final item in permissions!) item.toJson()],
        if (revert != null) 'revert': revert!.toJson(),
        'location': location.toJson(),
      };
}

/// `TokenUsage.Info`
final class TokenUsageInfo {
  const TokenUsageInfo({
    required this.input,
    required this.output,
    required this.reasoning,
    required this.cache,
  });

  factory TokenUsageInfo.fromJson(Map<String, Object?> json) => TokenUsageInfo(
        input: decodeNumber(json, 'input'),
        output: decodeNumber(json, 'output'),
        reasoning: decodeNumber(json, 'reasoning'),
        cache: TokenUsageInfoCache.fromJson(asJsonMap(json['cache'])),
      );

  final double input;
  final double output;
  final double reasoning;
  final TokenUsageInfoCache cache;

  Map<String, Object?> toJson() => <String, Object?>{
        'input': input,
        'output': output,
        'reasoning': reasoning,
        'cache': cache.toJson(),
      };
}

/// `Session.Revert`
final class SessionRevert {
  const SessionRevert({
    required this.messageID,
    this.partID,
    this.snapshot,
    this.files,
  });

  factory SessionRevert.fromJson(Map<String, Object?> json) => SessionRevert(
        messageID: SessionMessageID.fromJson(asJsonString(json['messageID'])),
        partID: decodeOptionalString(json, 'partID'),
        snapshot: json['snapshot'] == null
            ? null
            : SnapshotID.fromJson(asJsonString(json['snapshot'])),
        files: json['files'] == null
            ? null
            : jsonList(json['files'],
                (item) => FileDiffInfo.fromJson(asJsonMap(item))),
      );

  final SessionMessageID messageID;
  final String? partID;
  final SnapshotID? snapshot;
  final List<FileDiffInfo>? files;

  Map<String, Object?> toJson() => <String, Object?>{
        'messageID': messageID,
        if (partID != null) 'partID': partID!,
        if (snapshot != null) 'snapshot': snapshot!,
        if (files != null) 'files': [for (final item in files!) item.toJson()],
      };
}

/// `Session.Message.AgentSelected`
final class SessionMessageAgentSelected extends SessionMessageInfo {
  const SessionMessageAgentSelected({
    required this.id,
    this.metadata,
    required this.time,
    required this.agent,
    this.previous,
  });

  factory SessionMessageAgentSelected.fromJson(Map<String, Object?> json) =>
      SessionMessageAgentSelected(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageAgentSelectedTime.fromJson(asJsonMap(json['time'])),
        agent: AgentID.fromJson(asJsonString(json['agent'])),
        previous: json['previous'] == null
            ? null
            : AgentID.fromJson(asJsonString(json['previous'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageAgentSelectedTime time;
  final AgentID agent;
  final AgentID? previous;

  /// Always `agent-switched`.
  @override
  String get type => 'agent-switched';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'agent-switched',
        'agent': agent,
        if (previous != null) 'previous': previous!,
      };
}

/// `Session.Message.Assistant`
final class SessionMessageAssistant extends SessionMessageInfo {
  const SessionMessageAssistant({
    required this.id,
    this.metadata,
    required this.time,
    required this.agent,
    required this.model,
    required this.content,
    this.snapshot,
    this.finish,
    this.rawFinish,
    this.providerState,
    this.cost,
    this.tokens,
    this.error,
    this.retry,
  });

  factory SessionMessageAssistant.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistant(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageAssistantTime.fromJson(asJsonMap(json['time'])),
        agent: AgentID.fromJson(asJsonString(json['agent'])),
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        content: jsonList(json['content'],
            (item) => SessionMessageAssistantContent.fromJson(asJsonMap(item))),
        snapshot: json['snapshot'] == null
            ? null
            : SessionMessageAssistantSnapshot.fromJson(
                asJsonMap(json['snapshot'])),
        finish: json['finish'] == null
            ? null
            : SessionMessageAssistantFinish.fromJson(json['finish']),
        rawFinish: decodeOptionalString(json, 'rawFinish'),
        providerState: json['providerState'] == null
            ? null
            : asJsonMap(json['providerState']),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        error: json['error'] == null
            ? null
            : SessionStructuredError.fromJson(asJsonMap(json['error'])),
        retry: json['retry'] == null
            ? null
            : SessionMessageAssistantRetry.fromJson(asJsonMap(json['retry'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageAssistantTime time;
  final AgentID agent;
  final ModelRef model;
  final List<SessionMessageAssistantContent> content;
  final SessionMessageAssistantSnapshot? snapshot;
  final SessionMessageAssistantFinish? finish;
  final String? rawFinish;
  final Map<String, Object?>? providerState;
  final MoneyUSD? cost;
  final TokenUsageInfo? tokens;
  final SessionStructuredError? error;
  final SessionMessageAssistantRetry? retry;

  /// Always `assistant`.
  @override
  String get type => 'assistant';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'assistant',
        'agent': agent,
        'model': model.toJson(),
        'content': [for (final item in content) item.toJson()],
        if (snapshot != null) 'snapshot': snapshot!.toJson(),
        if (finish != null) 'finish': finish!.wire,
        if (rawFinish != null) 'rawFinish': rawFinish!,
        if (providerState != null) 'providerState': providerState!,
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
        if (error != null) 'error': error!.toJson(),
        if (retry != null) 'retry': retry!.toJson(),
      };
}

/// `Session.Message.Assistant.Text`
final class SessionMessageAssistantText extends SessionMessageAssistantContent {
  const SessionMessageAssistantText({
    required this.text,
    this.state,
  });

  factory SessionMessageAssistantText.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantText(
        text: decodeString(json, 'text'),
        state: json['state'] == null ? null : asJsonMap(json['state']),
      );

  final String text;
  final Map<String, Object?>? state;

  /// Always `text`.
  @override
  String get type => 'text';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'text',
        'text': text,
        if (state != null) 'state': state!,
      };
}

/// `Session.Message.Assistant.Reasoning`
final class SessionMessageAssistantReasoning
    extends SessionMessageAssistantContent {
  const SessionMessageAssistantReasoning({
    required this.text,
    this.state,
    this.time,
  });

  factory SessionMessageAssistantReasoning.fromJson(
          Map<String, Object?> json) =>
      SessionMessageAssistantReasoning(
        text: decodeString(json, 'text'),
        state: json['state'] == null ? null : asJsonMap(json['state']),
        time: json['time'] == null
            ? null
            : SessionMessageAssistantReasoningTime.fromJson(
                asJsonMap(json['time'])),
      );

  final String text;
  final Map<String, Object?>? state;
  final SessionMessageAssistantReasoningTime? time;

  /// Always `reasoning`.
  @override
  String get type => 'reasoning';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'reasoning',
        'text': text,
        if (state != null) 'state': state!,
        if (time != null) 'time': time!.toJson(),
      };
}

/// `Session.Message.Assistant.Tool`
final class SessionMessageAssistantTool extends SessionMessageAssistantContent {
  const SessionMessageAssistantTool({
    required this.id,
    required this.name,
    this.executed,
    this.providerState,
    this.providerResultState,
    required this.state,
    required this.time,
  });

  factory SessionMessageAssistantTool.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantTool(
        id: decodeString(json, 'id'),
        name: decodeString(json, 'name'),
        executed: decodeOptionalBool(json, 'executed'),
        providerState: json['providerState'] == null
            ? null
            : asJsonMap(json['providerState']),
        providerResultState: json['providerResultState'] == null
            ? null
            : asJsonMap(json['providerResultState']),
        state:
            SessionMessageAssistantToolState.fromJson(asJsonMap(json['state'])),
        time: SessionMessageAssistantToolTime.fromJson(asJsonMap(json['time'])),
      );

  final String id;
  final String name;
  final bool? executed;
  final Map<String, Object?>? providerState;
  final Map<String, Object?>? providerResultState;
  final SessionMessageAssistantToolState state;
  final SessionMessageAssistantToolTime time;

  /// Always `tool`.
  @override
  String get type => 'tool';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'tool',
        'id': id,
        'name': name,
        if (executed != null) 'executed': executed!,
        if (providerState != null) 'providerState': providerState!,
        if (providerResultState != null)
          'providerResultState': providerResultState!,
        'state': state.toJson(),
        'time': time.toJson(),
      };
}

/// `Session.Message.ToolState.Streaming`
final class SessionMessageToolStateStreaming
    extends SessionMessageAssistantToolState {
  const SessionMessageToolStateStreaming({
    required this.input,
  });

  factory SessionMessageToolStateStreaming.fromJson(
          Map<String, Object?> json) =>
      SessionMessageToolStateStreaming(
        input: decodeString(json, 'input'),
      );

  final String input;

  /// Always `streaming`.
  @override
  String get status => 'streaming';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'streaming',
        'input': input,
      };
}

/// `Session.Message.ToolState.Running`
final class SessionMessageToolStateRunning
    extends SessionMessageAssistantToolState {
  const SessionMessageToolStateRunning({
    required this.input,
    required this.metadata,
  });

  factory SessionMessageToolStateRunning.fromJson(Map<String, Object?> json) =>
      SessionMessageToolStateRunning(
        input: asJsonMap(json['input']),
        metadata: asJsonMap(json['metadata']),
      );

  final Map<String, Object?> input;
  final Map<String, Object?> metadata;

  /// Always `running`.
  @override
  String get status => 'running';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'running',
        'input': input,
        'metadata': metadata,
      };
}

/// `Session.Message.ToolState.Completed`
final class SessionMessageToolStateCompleted
    extends SessionMessageAssistantToolState {
  const SessionMessageToolStateCompleted({
    required this.input,
    required this.content,
    this.metadata,
  });

  factory SessionMessageToolStateCompleted.fromJson(
          Map<String, Object?> json) =>
      SessionMessageToolStateCompleted(
        input: asJsonMap(json['input']),
        content: jsonList(
            json['content'], (item) => ToolContent.fromJson(asJsonMap(item))),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final Map<String, Object?> input;
  final List<ToolContent> content;
  final Map<String, Object?>? metadata;

  /// Always `completed`.
  @override
  String get status => 'completed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'completed',
        'input': input,
        'content': [for (final item in content) item.toJson()],
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `Session.Message.ToolState.Error`
final class SessionMessageToolStateError
    extends SessionMessageAssistantToolState {
  const SessionMessageToolStateError({
    required this.input,
    required this.error,
    this.content,
    this.metadata,
  });

  factory SessionMessageToolStateError.fromJson(Map<String, Object?> json) =>
      SessionMessageToolStateError(
        input: asJsonMap(json['input']),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
        content: json['content'] == null
            ? null
            : jsonList(json['content'],
                (item) => ToolContent.fromJson(asJsonMap(item))),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final Map<String, Object?> input;
  final SessionStructuredError error;
  final List<ToolContent>? content;
  final Map<String, Object?>? metadata;

  /// Always `error`.
  @override
  String get status => 'error';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'error',
        'input': input,
        'error': error.toJson(),
        if (content != null)
          'content': [for (final item in content!) item.toJson()],
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `Session.StructuredError`
final class SessionStructuredError {
  const SessionStructuredError({
    required this.type,
    required this.message,
    this.status,
    this.response,
  });

  factory SessionStructuredError.fromJson(Map<String, Object?> json) =>
      SessionStructuredError(
        type: decodeString(json, 'type'),
        message: decodeString(json, 'message'),
        status: decodeOptionalInt(json, 'status'),
        response: json['response'] == null
            ? null
            : SessionStructuredErrorResponse.fromJson(
                asJsonMap(json['response'])),
      );

  final String type;
  final String message;
  final int? status;
  final SessionStructuredErrorResponse? response;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'message': message,
        if (status != null) 'status': status!,
        if (response != null) 'response': response!.toJson(),
      };
}

/// `Session.Message.Assistant.Retry`
final class SessionMessageAssistantRetry {
  const SessionMessageAssistantRetry({
    required this.attempt,
    required this.at,
    required this.error,
  });

  factory SessionMessageAssistantRetry.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantRetry(
        attempt: decodeInt(json, 'attempt'),
        at: decodeNumber(json, 'at'),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
      );

  final int attempt;
  final double at;
  final SessionStructuredError error;

  Map<String, Object?> toJson() => <String, Object?>{
        'attempt': attempt,
        'at': at,
        'error': error.toJson(),
      };
}

/// `Session.Message.Compaction`
sealed class SessionMessageCompaction extends SessionMessageInfo {
  const SessionMessageCompaction();

  /// Decodes a payload into the matching variant.
  factory SessionMessageCompaction.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'running' => SessionMessageCompactionRunning.fromJson(json),
      'completed' => SessionMessageCompactionCompleted.fromJson(json),
      'failed' => SessionMessageCompactionFailed.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Session.Message.Compaction discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  @override
  String get type;

  /// Present on every variant (`id`).
  @override
  SessionMessageID get id;

  /// Present on every variant (`metadata`).
  @override
  Map<String, Object?>? get metadata;

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  @override
  Map<String, Object?> toJson();
}

/// `Session.Message.Compaction.Running`
final class SessionMessageCompactionRunning extends SessionMessageCompaction {
  const SessionMessageCompactionRunning({
    required this.id,
    this.metadata,
    required this.time,
    required this.reason,
    required this.summary,
    required this.recent,
  });

  factory SessionMessageCompactionRunning.fromJson(Map<String, Object?> json) =>
      SessionMessageCompactionRunning(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageCompactionRunningTime.fromJson(
            asJsonMap(json['time'])),
        reason: SessionMessageCompactionRunningReason.fromJson(json['reason']),
        summary: decodeString(json, 'summary'),
        recent: decodeString(json, 'recent'),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageCompactionRunningTime time;
  final SessionMessageCompactionRunningReason reason;
  final String summary;
  final String recent;

  /// Always `compaction`.
  @override
  String get type => 'compaction';

  /// Always `running`.
  @override
  String get status => 'running';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'compaction',
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'status': 'running',
        'reason': reason.wire,
        'summary': summary,
        'recent': recent,
      };
}

/// `Session.Message.Compaction.Completed`
final class SessionMessageCompactionCompleted extends SessionMessageCompaction {
  const SessionMessageCompactionCompleted({
    required this.id,
    this.metadata,
    required this.time,
    required this.reason,
    this.model,
    this.providerState,
    required this.summary,
    required this.recent,
    this.providerContext,
    this.cost,
    this.tokens,
  });

  factory SessionMessageCompactionCompleted.fromJson(
          Map<String, Object?> json) =>
      SessionMessageCompactionCompleted(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageCompactionCompletedTime.fromJson(
            asJsonMap(json['time'])),
        reason:
            SessionMessageCompactionCompletedReason.fromJson(json['reason']),
        model: json['model'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['model'])),
        providerState: json['providerState'] == null
            ? null
            : asJsonMap(json['providerState']),
        summary: decodeString(json, 'summary'),
        recent: decodeString(json, 'recent'),
        providerContext: json['providerContext'] == null
            ? null
            : SessionProviderContext.fromJson(
                asJsonMap(json['providerContext'])),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageCompactionCompletedTime time;
  final SessionMessageCompactionCompletedReason reason;
  final ModelRef? model;
  final Map<String, Object?>? providerState;
  final String summary;
  final String recent;
  final SessionProviderContext? providerContext;
  final MoneyUSD? cost;
  final TokenUsageInfo? tokens;

  /// Always `compaction`.
  @override
  String get type => 'compaction';

  /// Always `completed`.
  @override
  String get status => 'completed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'compaction',
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'status': 'completed',
        'reason': reason.wire,
        if (model != null) 'model': model!.toJson(),
        if (providerState != null) 'providerState': providerState!,
        'summary': summary,
        'recent': recent,
        if (providerContext != null)
          'providerContext': providerContext!.toJson(),
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
      };
}

/// `Session.ProviderContext`
final class SessionProviderContext {
  const SessionProviderContext({
    required this.version,
    required this.provenance,
    required this.messages,
  });

  factory SessionProviderContext.fromJson(Map<String, Object?> json) =>
      SessionProviderContext(
        version: decodeNumber(json, 'version'),
        provenance: SessionProviderContextProvenance.fromJson(
            asJsonMap(json['provenance'])),
        messages: json['messages'],
      );

  final double version;
  final SessionProviderContextProvenance provenance;
  final Object? messages;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': version,
        'provenance': provenance.toJson(),
        'messages': messages,
      };
}

/// `Session.ProviderContext.Provenance`
final class SessionProviderContextProvenance {
  const SessionProviderContextProvenance({
    required this.providerID,
    required this.provider,
    required this.modelID,
    required this.route,
    required this.protocol,
    required this.endpoint,
  });

  factory SessionProviderContextProvenance.fromJson(
          Map<String, Object?> json) =>
      SessionProviderContextProvenance(
        providerID: ProviderID.fromJson(asJsonString(json['providerID'])),
        provider: decodeString(json, 'provider'),
        modelID: decodeString(json, 'modelID'),
        route: decodeString(json, 'route'),
        protocol: decodeString(json, 'protocol'),
        endpoint: decodeString(json, 'endpoint'),
      );

  final ProviderID providerID;
  final String provider;
  final String modelID;
  final String route;
  final String protocol;
  final String endpoint;

  Map<String, Object?> toJson() => <String, Object?>{
        'providerID': providerID,
        'provider': provider,
        'modelID': modelID,
        'route': route,
        'protocol': protocol,
        'endpoint': endpoint,
      };
}

/// `Session.Message.Compaction.Failed`
final class SessionMessageCompactionFailed extends SessionMessageCompaction {
  const SessionMessageCompactionFailed({
    required this.id,
    this.metadata,
    required this.time,
    required this.reason,
    required this.error,
    this.cost,
    this.tokens,
  });

  factory SessionMessageCompactionFailed.fromJson(Map<String, Object?> json) =>
      SessionMessageCompactionFailed(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageCompactionFailedTime.fromJson(
            asJsonMap(json['time'])),
        reason: SessionMessageCompactionFailedReason.fromJson(json['reason']),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageCompactionFailedTime time;
  final SessionMessageCompactionFailedReason reason;
  final SessionStructuredError error;
  final MoneyUSD? cost;
  final TokenUsageInfo? tokens;

  /// Always `compaction`.
  @override
  String get type => 'compaction';

  /// Always `failed`.
  @override
  String get status => 'failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'compaction',
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'status': 'failed',
        'reason': reason.wire,
        'error': error.toJson(),
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
      };
}

/// `Session.Message.Idle`
final class SessionMessageIdle extends SessionMessageInfo {
  const SessionMessageIdle({
    required this.id,
    this.metadata,
    required this.time,
    required this.outcome,
    this.error,
  });

  factory SessionMessageIdle.fromJson(Map<String, Object?> json) =>
      SessionMessageIdle(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageIdleTime.fromJson(asJsonMap(json['time'])),
        outcome: SessionMessageIdleOutcome.fromJson(json['outcome']),
        error: json['error'] == null
            ? null
            : SessionStructuredError.fromJson(asJsonMap(json['error'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageIdleTime time;
  final SessionMessageIdleOutcome outcome;
  final SessionStructuredError? error;

  /// Always `idle`.
  @override
  String get type => 'idle';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'idle',
        'outcome': outcome.wire,
        if (error != null) 'error': error!.toJson(),
      };
}

/// `Session.Message.Info`
sealed class SessionMessageInfo {
  const SessionMessageInfo();

  /// Decodes a payload into the matching variant.
  factory SessionMessageInfo.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'agent-switched' => SessionMessageAgentSelected.fromJson(json),
      'model-switched' => SessionMessageModelSelected.fromJson(json),
      'location-switched' => SessionMessageLocationSwitched.fromJson(json),
      'user' => SessionMessageUser.fromJson(json),
      'synthetic' => SessionMessageSynthetic.fromJson(json),
      'system' => SessionMessageSystem.fromJson(json),
      'skill' => SessionMessageSkill.fromJson(json),
      'shell' => SessionMessageShell.fromJson(json),
      'assistant' => SessionMessageAssistant.fromJson(json),
      'compaction' => SessionMessageCompaction.fromJson(json),
      'idle' => SessionMessageIdle.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Session.Message.Info discriminator: $value'),
    };
  }

  /// Present on every variant (`id`).
  SessionMessageID get id;

  /// Present on every variant (`metadata`).
  Map<String, Object?>? get metadata;

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Session.Message.ModelSelected`
final class SessionMessageModelSelected extends SessionMessageInfo {
  const SessionMessageModelSelected({
    required this.id,
    this.metadata,
    required this.time,
    required this.model,
    this.previous,
  });

  factory SessionMessageModelSelected.fromJson(Map<String, Object?> json) =>
      SessionMessageModelSelected(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageModelSelectedTime.fromJson(asJsonMap(json['time'])),
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        previous: json['previous'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['previous'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageModelSelectedTime time;
  final ModelRef model;
  final ModelRef? previous;

  /// Always `model-switched`.
  @override
  String get type => 'model-switched';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'model-switched',
        'model': model.toJson(),
        if (previous != null) 'previous': previous!.toJson(),
      };
}

/// `Session.Message.LocationSwitched`
final class SessionMessageLocationSwitched extends SessionMessageInfo {
  const SessionMessageLocationSwitched({
    required this.id,
    this.metadata,
    required this.time,
    this.projectID,
    this.subpath,
    required this.location,
    this.previous,
  });

  factory SessionMessageLocationSwitched.fromJson(Map<String, Object?> json) =>
      SessionMessageLocationSwitched(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageLocationSwitchedTime.fromJson(
            asJsonMap(json['time'])),
        projectID: json['projectID'] == null
            ? null
            : ProjectID.fromJson(asJsonString(json['projectID'])),
        subpath: json['subpath'] == null
            ? null
            : RelativePath.fromJson(asJsonString(json['subpath'])),
        location: LocationRef.fromJson(json['location']),
        previous: json['previous'] == null
            ? null
            : SessionMessageLocationSwitchedPrevious.fromJson(
                asJsonMap(json['previous'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageLocationSwitchedTime time;
  final ProjectID? projectID;
  final RelativePath? subpath;
  final LocationRef location;
  final SessionMessageLocationSwitchedPrevious? previous;

  /// Always `location-switched`.
  @override
  String get type => 'location-switched';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'location-switched',
        if (projectID != null) 'projectID': projectID!,
        if (subpath != null) 'subpath': subpath!,
        'location': location.toJson(),
        if (previous != null) 'previous': previous!.toJson(),
      };
}

/// `Session.Message.User`
final class SessionMessageUser extends SessionMessageInfo {
  const SessionMessageUser({
    required this.id,
    this.metadata,
    required this.time,
    required this.text,
    this.files,
    this.agents,
    this.skills,
  });

  factory SessionMessageUser.fromJson(Map<String, Object?> json) =>
      SessionMessageUser(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageUserTime.fromJson(asJsonMap(json['time'])),
        text: decodeString(json, 'text'),
        files: json['files'] == null
            ? null
            : jsonList(json['files'],
                (item) => PromptFileAttachment.fromJson(asJsonMap(item))),
        agents: json['agents'] == null
            ? null
            : jsonList(json['agents'],
                (item) => PromptAgentAttachment.fromJson(asJsonMap(item))),
        skills: json['skills'] == null
            ? null
            : jsonList(json['skills'],
                (item) => PromptSkillAttachment.fromJson(asJsonMap(item))),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageUserTime time;
  final String text;
  final List<PromptFileAttachment>? files;
  final List<PromptAgentAttachment>? agents;
  final List<PromptSkillAttachment>? skills;

  /// Always `user`.
  @override
  String get type => 'user';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'text': text,
        if (files != null) 'files': [for (final item in files!) item.toJson()],
        if (agents != null)
          'agents': [for (final item in agents!) item.toJson()],
        if (skills != null)
          'skills': [for (final item in skills!) item.toJson()],
        'type': 'user',
      };
}

/// `Session.Message.Synthetic`
final class SessionMessageSynthetic extends SessionMessageInfo {
  const SessionMessageSynthetic({
    required this.id,
    this.metadata,
    required this.time,
    required this.text,
    this.description,
  });

  factory SessionMessageSynthetic.fromJson(Map<String, Object?> json) =>
      SessionMessageSynthetic(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageSyntheticTime.fromJson(asJsonMap(json['time'])),
        text: decodeString(json, 'text'),
        description: decodeOptionalString(json, 'description'),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageSyntheticTime time;
  final String text;
  final String? description;

  /// Always `synthetic`.
  @override
  String get type => 'synthetic';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'text': text,
        if (description != null) 'description': description!,
        'type': 'synthetic',
      };
}

/// `Session.Message.System`
final class SessionMessageSystem extends SessionMessageInfo {
  const SessionMessageSystem({
    required this.id,
    this.metadata,
    required this.time,
    required this.text,
    this.description,
  });

  factory SessionMessageSystem.fromJson(Map<String, Object?> json) =>
      SessionMessageSystem(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageSystemTime.fromJson(asJsonMap(json['time'])),
        text: decodeString(json, 'text'),
        description: decodeOptionalString(json, 'description'),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageSystemTime time;
  final String text;
  final String? description;

  /// Always `system`.
  @override
  String get type => 'system';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'system',
        'text': text,
        if (description != null) 'description': description!,
      };
}

/// `Session.Message.Skill`
final class SessionMessageSkill extends SessionMessageInfo {
  const SessionMessageSkill({
    required this.id,
    this.metadata,
    required this.time,
    required this.skill,
    required this.name,
    required this.text,
  });

  factory SessionMessageSkill.fromJson(Map<String, Object?> json) =>
      SessionMessageSkill(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageSkillTime.fromJson(asJsonMap(json['time'])),
        skill: SkillID.fromJson(asJsonString(json['skill'])),
        name: SkillName.fromJson(asJsonString(json['name'])),
        text: decodeString(json, 'text'),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageSkillTime time;
  final SkillID skill;
  final SkillName name;
  final String text;

  /// Always `skill`.
  @override
  String get type => 'skill';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'skill',
        'skill': skill,
        'name': name,
        'text': text,
      };
}

/// `Session.Message.Shell`
final class SessionMessageShell extends SessionMessageInfo {
  const SessionMessageShell({
    required this.id,
    this.metadata,
    required this.time,
    required this.shellID,
    required this.command,
    required this.status,
    this.exit,
    this.output,
  });

  factory SessionMessageShell.fromJson(Map<String, Object?> json) =>
      SessionMessageShell(
        id: SessionMessageID.fromJson(asJsonString(json['id'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        time: SessionMessageShellTime.fromJson(asJsonMap(json['time'])),
        shellID: ShellID.fromJson(asJsonString(json['shellID'])),
        command: decodeString(json, 'command'),
        status: SessionMessageShellStatus.fromJson(json['status']),
        exit: json['exit'],
        output: json['output'] == null
            ? null
            : SessionMessageShellOutput.fromJson(asJsonMap(json['output'])),
      );

  @override
  final SessionMessageID id;
  @override
  final Map<String, Object?>? metadata;
  final SessionMessageShellTime time;
  final ShellID shellID;
  final String command;
  final SessionMessageShellStatus status;
  final Object? exit;
  final SessionMessageShellOutput? output;

  /// Always `shell`.
  @override
  String get type => 'shell';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (metadata != null) 'metadata': metadata!,
        'time': time.toJson(),
        'type': 'shell',
        'shellID': shellID,
        'command': command,
        'status': status.wire,
        if (exit != null) 'exit': exit!,
        if (output != null) 'output': output!.toJson(),
      };
}

/// `SessionActive`
final class SessionActive {
  const SessionActive();

  factory SessionActive.fromJson(Map<String, Object?> json) => SessionActive();

  /// Always `running`.
  String get type => 'running';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'running',
      };
}

/// `SessionStats.Activity`
final class SessionStatsActivity {
  const SessionStatsActivity({
    required this.date,
    required this.steps,
  });

  factory SessionStatsActivity.fromJson(Map<String, Object?> json) =>
      SessionStatsActivity(
        date: decodeString(json, 'date'),
        steps: decodeInt(json, 'steps'),
      );

  final String date;
  final int steps;

  Map<String, Object?> toJson() => <String, Object?>{
        'date': date,
        'steps': steps,
      };
}

/// `SessionStats.Info`
final class SessionStatsInfo {
  const SessionStatsInfo({
    required this.range,
    required this.sessions,
    required this.subagents,
    required this.prompts,
    required this.steps,
    required this.tokens,
    required this.cost,
    required this.tools,
    required this.activeDays,
    required this.streak,
    required this.activity,
    required this.models,
  });

  factory SessionStatsInfo.fromJson(Map<String, Object?> json) =>
      SessionStatsInfo(
        range: SessionStatsInfoRange.fromJson(asJsonMap(json['range'])),
        sessions: decodeInt(json, 'sessions'),
        subagents: decodeInt(json, 'subagents'),
        prompts: decodeInt(json, 'prompts'),
        steps: decodeInt(json, 'steps'),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tools: SessionStatsTools.fromJson(asJsonMap(json['tools'])),
        activeDays: decodeInt(json, 'activeDays'),
        streak: decodeInt(json, 'streak'),
        activity: jsonList(json['activity'],
            (item) => SessionStatsActivity.fromJson(asJsonMap(item))),
        models: jsonList(json['models'],
            (item) => SessionStatsModelUsage.fromJson(asJsonMap(item))),
      );

  final SessionStatsInfoRange range;
  final int sessions;
  final int subagents;
  final int prompts;
  final int steps;
  final TokenUsageInfo tokens;
  final MoneyUSD cost;
  final SessionStatsTools tools;
  final int activeDays;
  final int streak;
  final List<SessionStatsActivity> activity;
  final List<SessionStatsModelUsage> models;

  Map<String, Object?> toJson() => <String, Object?>{
        'range': range.toJson(),
        'sessions': sessions,
        'subagents': subagents,
        'prompts': prompts,
        'steps': steps,
        'tokens': tokens.toJson(),
        'cost': cost,
        'tools': tools.toJson(),
        'activeDays': activeDays,
        'streak': streak,
        'activity': [for (final item in activity) item.toJson()],
        'models': [for (final item in models) item.toJson()],
      };
}

/// `SessionStats.Tools`
sealed class SessionStatsTools {
  const SessionStatsTools();

  /// Decodes a payload into the matching variant.
  factory SessionStatsTools.fromJson(Map<String, Object?> json) {
    final value = json['mode'];
    return switch (value) {
      'none' => SessionStatsToolsNone.fromJson(json),
      'summary' => SessionStatsToolsSummary.fromJson(json),
      'detail' => SessionStatsToolsDetail.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown SessionStats.Tools discriminator: $value'),
    };
  }

  /// Present on every variant (`mode`).
  String get mode;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `SessionStatsToolsNone`
final class SessionStatsToolsNone extends SessionStatsTools {
  const SessionStatsToolsNone();

  factory SessionStatsToolsNone.fromJson(Map<String, Object?> json) =>
      SessionStatsToolsNone();

  /// Always `none`.
  @override
  String get mode => 'none';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'mode': 'none',
      };
}

/// `SessionStats.ToolTotals`
final class SessionStatsToolTotals {
  const SessionStatsToolTotals({
    required this.calls,
    required this.succeeded,
    required this.failed,
    required this.unfinished,
  });

  factory SessionStatsToolTotals.fromJson(Map<String, Object?> json) =>
      SessionStatsToolTotals(
        calls: decodeInt(json, 'calls'),
        succeeded: decodeInt(json, 'succeeded'),
        failed: decodeInt(json, 'failed'),
        unfinished: decodeInt(json, 'unfinished'),
      );

  final int calls;
  final int succeeded;
  final int failed;
  final int unfinished;

  Map<String, Object?> toJson() => <String, Object?>{
        'calls': calls,
        'succeeded': succeeded,
        'failed': failed,
        'unfinished': unfinished,
      };
}

/// `SessionStatsToolsSummary`
final class SessionStatsToolsSummary extends SessionStatsTools {
  const SessionStatsToolsSummary({
    required this.totals,
  });

  factory SessionStatsToolsSummary.fromJson(Map<String, Object?> json) =>
      SessionStatsToolsSummary(
        totals: SessionStatsToolTotals.fromJson(asJsonMap(json['totals'])),
      );

  final SessionStatsToolTotals totals;

  /// Always `summary`.
  @override
  String get mode => 'summary';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'mode': 'summary',
        'totals': totals.toJson(),
      };
}

/// `SessionStats.ToolUsage`
final class SessionStatsToolUsage {
  const SessionStatsToolUsage({
    required this.name,
    required this.calls,
    required this.succeeded,
    required this.failed,
    required this.unfinished,
    this.durationP50,
  });

  factory SessionStatsToolUsage.fromJson(Map<String, Object?> json) =>
      SessionStatsToolUsage(
        name: decodeString(json, 'name'),
        calls: decodeInt(json, 'calls'),
        succeeded: decodeInt(json, 'succeeded'),
        failed: decodeInt(json, 'failed'),
        unfinished: decodeInt(json, 'unfinished'),
        durationP50: decodeOptionalNumber(json, 'durationP50'),
      );

  final String name;
  final int calls;
  final int succeeded;
  final int failed;
  final int unfinished;
  final double? durationP50;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'calls': calls,
        'succeeded': succeeded,
        'failed': failed,
        'unfinished': unfinished,
        if (durationP50 != null) 'durationP50': durationP50!,
      };
}

/// `SessionStatsToolsDetail`
final class SessionStatsToolsDetail extends SessionStatsTools {
  const SessionStatsToolsDetail({
    required this.totals,
    required this.usage,
  });

  factory SessionStatsToolsDetail.fromJson(Map<String, Object?> json) =>
      SessionStatsToolsDetail(
        totals: SessionStatsToolTotals.fromJson(asJsonMap(json['totals'])),
        usage: jsonList(json['usage'],
            (item) => SessionStatsToolUsage.fromJson(asJsonMap(item))),
      );

  final SessionStatsToolTotals totals;
  final List<SessionStatsToolUsage> usage;

  /// Always `detail`.
  @override
  String get mode => 'detail';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'mode': 'detail',
        'totals': totals.toJson(),
        'usage': [for (final item in usage) item.toJson()],
      };
}

/// `SessionStats.ModelUsage`
final class SessionStatsModelUsage {
  const SessionStatsModelUsage({
    required this.model,
    required this.steps,
    required this.tokens,
    required this.cost,
  });

  factory SessionStatsModelUsage.fromJson(Map<String, Object?> json) =>
      SessionStatsModelUsage(
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        steps: decodeInt(json, 'steps'),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
      );

  final ModelRef model;
  final int steps;
  final TokenUsageInfo tokens;
  final MoneyUSD cost;

  Map<String, Object?> toJson() => <String, Object?>{
        'model': model.toJson(),
        'steps': steps,
        'tokens': tokens.toJson(),
        'cost': cost,
      };
}

/// `SessionTransfer.Data`
final class SessionTransferData {
  const SessionTransferData({
    required this.info,
    required this.messages,
  });

  factory SessionTransferData.fromJson(Map<String, Object?> json) =>
      SessionTransferData(
        info: SessionInfo.fromJson(asJsonMap(json['info'])),
        messages: jsonList(json['messages'],
            (item) => SessionMessageInfo.fromJson(asJsonMap(item))),
      );

  final SessionInfo info;
  final List<SessionMessageInfo> messages;

  Map<String, Object?> toJson() => <String, Object?>{
        'info': info.toJson(),
        'messages': [for (final item in messages) item.toJson()],
      };
}

/// `SessionsResponse`
final class SessionsResponse {
  const SessionsResponse({
    required this.data,
    required this.cursor,
  });

  factory SessionsResponse.fromJson(Map<String, Object?> json) =>
      SessionsResponse(
        data: jsonList(
            json['data'], (item) => SessionInfo.fromJson(asJsonMap(item))),
        cursor: SessionsResponseCursor.fromJson(asJsonMap(json['cursor'])),
      );

  final List<SessionInfo> data;
  final SessionsResponseCursor cursor;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': [for (final item in data) item.toJson()],
        'cursor': cursor.toJson(),
      };
}
