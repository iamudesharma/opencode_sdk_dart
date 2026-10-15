// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Agent.Info`
final class AgentInfo {
  const AgentInfo({
    required this.id,
    required this.name,
    this.model,
    required this.request,
    this.system,
    this.description,
    required this.mode,
    required this.hidden,
    this.color,
    this.steps,
    required this.permissions,
  });

  factory AgentInfo.fromJson(Map<String, Object?> json) => AgentInfo(
        id: AgentID.fromJson(asJsonString(json['id'])),
        name: decodeString(json, 'name'),
        model: json['model'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['model'])),
        request: ProviderRequest.fromJson(asJsonMap(json['request'])),
        system: decodeOptionalString(json, 'system'),
        description: decodeOptionalString(json, 'description'),
        mode: AgentInfoMode.fromJson(json['mode']),
        hidden: decodeBool(json, 'hidden'),
        color: json['color'] == null
            ? null
            : AgentColor.fromJson(asJsonString(json['color'])),
        steps: decodeOptionalInt(json, 'steps'),
        permissions: jsonList(json['permissions'],
            (item) => PermissionRule.fromJson(asJsonMap(item))),
      );

  final AgentID id;
  final String name;
  final ModelRef? model;
  final ProviderRequest request;
  final String? system;
  final String? description;
  final AgentInfoMode mode;
  final bool hidden;
  final AgentColor? color;
  final int? steps;
  final List<PermissionRule> permissions;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (model != null) 'model': model!.toJson(),
        'request': request.toJson(),
        if (system != null) 'system': system!,
        if (description != null) 'description': description!,
        'mode': mode.wire,
        'hidden': hidden,
        if (color != null) 'color': color!,
        if (steps != null) 'steps': steps!,
        'permissions': [for (final item in permissions) item.toJson()],
      };
}

/// `Command.Info`
final class CommandInfo {
  const CommandInfo({
    required this.name,
    this.description,
  });

  factory CommandInfo.fromJson(Map<String, Object?> json) => CommandInfo(
        name: decodeString(json, 'name'),
        description: decodeOptionalString(json, 'description'),
      );

  final String name;
  final String? description;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        if (description != null) 'description': description!,
      };
}

/// `FileSystem.Entry`
final class FileSystemEntry {
  const FileSystemEntry({
    required this.path,
    required this.type,
  });

  factory FileSystemEntry.fromJson(Map<String, Object?> json) =>
      FileSystemEntry(
        path: RelativePath.fromJson(asJsonString(json['path'])),
        type: FileSystemEntryType.fromJson(json['type']),
      );

  final RelativePath path;
  final FileSystemEntryType type;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        'type': type.wire,
      };
}

/// `FileSystem.Write`
final class FileSystemWrite {
  const FileSystemWrite({
    required this.path,
  });

  factory FileSystemWrite.fromJson(Map<String, Object?> json) =>
      FileSystemWrite(
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
      );

  final AbsolutePath path;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
      };
}

/// `GenerateTextResponse`
final class GenerateTextResponse {
  const GenerateTextResponse({
    required this.data,
  });

  factory GenerateTextResponse.fromJson(Map<String, Object?> json) =>
      GenerateTextResponse(
        data: GenerateTextResponseData.fromJson(asJsonMap(json['data'])),
      );

  final GenerateTextResponseData data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `InstructionEntry.Info`
final class InstructionEntryInfo {
  const InstructionEntryInfo({
    required this.key,
    required this.value,
  });

  factory InstructionEntryInfo.fromJson(Map<String, Object?> json) =>
      InstructionEntryInfo(
        key: InstructionEntryKey.fromJson(asJsonString(json['key'])),
        value: json['value'],
      );

  final InstructionEntryKey key;
  final Object? value;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'value': value,
      };
}

/// `Location.PublicInfo`
final class LocationPublicInfo {
  const LocationPublicInfo({
    required this.directory,
    required this.project,
  });

  factory LocationPublicInfo.fromJson(Map<String, Object?> json) =>
      LocationPublicInfo(
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
        project: LocationPublicInfoProject.fromJson(asJsonMap(json['project'])),
      );

  final AbsolutePath directory;
  final LocationPublicInfoProject project;

  Map<String, Object?> toJson() => <String, Object?>{
        'directory': directory,
        'project': project.toJson(),
      };
}

/// `PairingCode`
final class PairingCode {
  const PairingCode({
    required this.code,
    required this.expiresIn,
  });

  factory PairingCode.fromJson(Map<String, Object?> json) => PairingCode(
        code: decodeString(json, 'code'),
        expiresIn: decodeInt(json, 'expires_in'),
      );

  final String code;

  /// Wire field: `expires_in`.
  final int expiresIn;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'expires_in': expiresIn,
      };
}

/// `PairingSession`
final class PairingSession {
  const PairingSession({
    required this.token,
  });

  factory PairingSession.fromJson(Map<String, Object?> json) => PairingSession(
        token: decodeString(json, 'token'),
      );

  final String token;

  Map<String, Object?> toJson() => <String, Object?>{
        'token': token,
      };
}

/// `Project`
final class Project {
  const Project({
    required this.id,
    required this.canonical,
    this.vcs,
    this.name,
    this.icon,
    this.commands,
    required this.time,
    required this.sandboxes,
  });

  factory Project.fromJson(Map<String, Object?> json) => Project(
        id: ProjectID.fromJson(asJsonString(json['id'])),
        canonical: AbsolutePath.fromJson(asJsonString(json['canonical'])),
        vcs: json['vcs'] == null
            ? null
            : ProjectVcs.fromJson(asJsonString(json['vcs'])),
        name: decodeOptionalString(json, 'name'),
        icon: json['icon'] == null
            ? null
            : ProjectIcon.fromJson(asJsonMap(json['icon'])),
        commands: json['commands'] == null
            ? null
            : ProjectCommands.fromJson(asJsonMap(json['commands'])),
        time: ProjectTime.fromJson(asJsonMap(json['time'])),
        sandboxes: jsonList(json['sandboxes'], (item) => asJsonString(item)),
      );

  final ProjectID id;
  final AbsolutePath canonical;
  final ProjectVcs? vcs;
  final String? name;
  final ProjectIcon? icon;
  final ProjectCommands? commands;
  final ProjectTime time;
  final List<String> sandboxes;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'canonical': canonical,
        if (vcs != null) 'vcs': vcs!,
        if (name != null) 'name': name!,
        if (icon != null) 'icon': icon!.toJson(),
        if (commands != null) 'commands': commands!.toJson(),
        'time': time.toJson(),
        'sandboxes': sandboxes,
      };
}

/// `Project.Icon`
final class ProjectIcon {
  const ProjectIcon({
    this.url,
    this.override,
    this.color,
  });

  factory ProjectIcon.fromJson(Map<String, Object?> json) => ProjectIcon(
        url: decodeOptionalString(json, 'url'),
        override: decodeOptionalString(json, 'override'),
        color: decodeOptionalString(json, 'color'),
      );

  final String? url;
  final String? override;
  final String? color;

  Map<String, Object?> toJson() => <String, Object?>{
        if (url != null) 'url': url!,
        if (override != null) 'override': override!,
        if (color != null) 'color': color!,
      };
}

/// `Project.Commands`
final class ProjectCommands {
  const ProjectCommands({
    this.start,
  });

  factory ProjectCommands.fromJson(Map<String, Object?> json) =>
      ProjectCommands(
        start: decodeOptionalString(json, 'start'),
      );

  final String? start;

  Map<String, Object?> toJson() => <String, Object?>{
        if (start != null) 'start': start!,
      };
}

/// `Project.Time`
final class ProjectTime {
  const ProjectTime({
    required this.created,
    required this.updated,
    required this.active,
    this.archived,
  });

  factory ProjectTime.fromJson(Map<String, Object?> json) => ProjectTime(
        created: decodeInt(json, 'created'),
        updated: decodeInt(json, 'updated'),
        active: decodeInt(json, 'active'),
        archived: decodeOptionalInt(json, 'archived'),
      );

  final int created;
  final int updated;
  final int active;
  final int? archived;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'updated': updated,
        'active': active,
        if (archived != null) 'archived': archived!,
      };
}

/// `Prompt.AgentAttachment`
final class PromptAgentAttachment {
  const PromptAgentAttachment({
    required this.name,
    this.mention,
  });

  factory PromptAgentAttachment.fromJson(Map<String, Object?> json) =>
      PromptAgentAttachment(
        name: decodeString(json, 'name'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final String name;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `Prompt.Mention`
final class PromptMention {
  const PromptMention({
    required this.start,
    required this.end,
    required this.text,
  });

  factory PromptMention.fromJson(Map<String, Object?> json) => PromptMention(
        start: decodeNumber(json, 'start'),
        end: decodeNumber(json, 'end'),
        text: decodeString(json, 'text'),
      );

  final double start;
  final double end;
  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'start': start,
        'end': end,
        'text': text,
      };
}

/// `Prompt.FileAttachment`
final class PromptFileAttachment {
  const PromptFileAttachment({
    required this.data,
    required this.mime,
    required this.source,
    this.name,
    this.description,
    this.mention,
  });

  factory PromptFileAttachment.fromJson(Map<String, Object?> json) =>
      PromptFileAttachment(
        data: PromptBase64.fromJson(asJsonString(json['data'])),
        mime: decodeString(json, 'mime'),
        source: PromptFileSource.fromJson(asJsonMap(json['source'])),
        name: decodeOptionalString(json, 'name'),
        description: decodeOptionalString(json, 'description'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final PromptBase64 data;
  final String mime;
  final PromptFileSource source;
  final String? name;
  final String? description;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data,
        'mime': mime,
        'source': source.toJson(),
        if (name != null) 'name': name!,
        if (description != null) 'description': description!,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `Prompt.FileSource`
sealed class PromptFileSource {
  const PromptFileSource();

  /// Decodes a payload into the matching variant.
  factory PromptFileSource.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'inline' => PromptFileSourceInline.fromJson(json),
      'uri' => PromptFileSourceUri.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Prompt.FileSource discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `PromptFileSourceInline`
final class PromptFileSourceInline extends PromptFileSource {
  const PromptFileSourceInline();

  factory PromptFileSourceInline.fromJson(Map<String, Object?> json) =>
      PromptFileSourceInline();

  /// Always `inline`.
  @override
  String get type => 'inline';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'inline',
      };
}

/// `PromptFileSourceUri`
final class PromptFileSourceUri extends PromptFileSource {
  const PromptFileSourceUri({
    required this.uri,
  });

  factory PromptFileSourceUri.fromJson(Map<String, Object?> json) =>
      PromptFileSourceUri(
        uri: decodeString(json, 'uri'),
      );

  final String uri;

  /// Always `uri`.
  @override
  String get type => 'uri';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'uri',
        'uri': uri,
      };
}

/// `Prompt.SkillAttachment`
final class PromptSkillAttachment {
  const PromptSkillAttachment({
    required this.id,
    required this.name,
    this.text,
    this.mention,
  });

  factory PromptSkillAttachment.fromJson(Map<String, Object?> json) =>
      PromptSkillAttachment(
        id: SkillID.fromJson(asJsonString(json['id'])),
        name: SkillName.fromJson(asJsonString(json['name'])),
        text: decodeOptionalString(json, 'text'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final SkillID id;
  final SkillName name;
  final String? text;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (text != null) 'text': text!,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `PromptInput.FileAttachment`
final class PromptInputFileAttachment {
  const PromptInputFileAttachment({
    required this.uri,
    this.name,
    this.description,
    this.mention,
  });

  factory PromptInputFileAttachment.fromJson(Map<String, Object?> json) =>
      PromptInputFileAttachment(
        uri: decodeString(json, 'uri'),
        name: decodeOptionalString(json, 'name'),
        description: decodeOptionalString(json, 'description'),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final String uri;
  final String? name;
  final String? description;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'uri': uri,
        if (name != null) 'name': name!,
        if (description != null) 'description': description!,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `PromptInput.SkillAttachment`
final class PromptInputSkillAttachment {
  const PromptInputSkillAttachment({
    required this.id,
    this.mention,
  });

  factory PromptInputSkillAttachment.fromJson(Map<String, Object?> json) =>
      PromptInputSkillAttachment(
        id: SkillID.fromJson(asJsonString(json['id'])),
        mention: json['mention'] == null
            ? null
            : PromptMention.fromJson(asJsonMap(json['mention'])),
      );

  final SkillID id;
  final PromptMention? mention;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (mention != null) 'mention': mention!.toJson(),
      };
}

/// `PtyTicket.ConnectToken`
final class PtyTicketConnectToken {
  const PtyTicketConnectToken({
    required this.ticket,
    required this.expiresIn,
  });

  factory PtyTicketConnectToken.fromJson(Map<String, Object?> json) =>
      PtyTicketConnectToken(
        ticket: decodeString(json, 'ticket'),
        expiresIn: decodeInt(json, 'expires_in'),
      );

  final String ticket;

  /// Wire field: `expires_in`.
  final int expiresIn;

  Map<String, Object?> toJson() => <String, Object?>{
        'ticket': ticket,
        'expires_in': expiresIn,
      };
}

/// `Reference.GitSource`
final class ReferenceGitSource extends ReferenceSource {
  const ReferenceGitSource({
    required this.repository,
    this.branch,
  });

  factory ReferenceGitSource.fromJson(Map<String, Object?> json) =>
      ReferenceGitSource(
        repository: decodeString(json, 'repository'),
        branch: decodeOptionalString(json, 'branch'),
      );

  final String repository;
  final String? branch;

  /// Always `git`.
  @override
  String get type => 'git';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'git',
        'repository': repository,
        if (branch != null) 'branch': branch!,
      };
}

/// `Reference.Info`
final class ReferenceInfo {
  const ReferenceInfo({
    required this.name,
    required this.path,
    this.description,
    this.hidden,
    required this.source,
  });

  factory ReferenceInfo.fromJson(Map<String, Object?> json) => ReferenceInfo(
        name: decodeString(json, 'name'),
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
        description: decodeOptionalString(json, 'description'),
        hidden: decodeOptionalBool(json, 'hidden'),
        source: ReferenceSource.fromJson(asJsonMap(json['source'])),
      );

  final String name;
  final AbsolutePath path;
  final String? description;
  final bool? hidden;
  final ReferenceSource source;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'path': path,
        if (description != null) 'description': description!,
        if (hidden != null) 'hidden': hidden!,
        'source': source.toJson(),
      };
}

/// `Reference.Source`
sealed class ReferenceSource {
  const ReferenceSource();

  /// Decodes a payload into the matching variant.
  factory ReferenceSource.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'local' => ReferenceLocalSource.fromJson(json),
      'git' => ReferenceGitSource.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Reference.Source discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Reference.LocalSource`
final class ReferenceLocalSource extends ReferenceSource {
  const ReferenceLocalSource({
    required this.path,
  });

  factory ReferenceLocalSource.fromJson(Map<String, Object?> json) =>
      ReferenceLocalSource(
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
      );

  final AbsolutePath path;

  /// Always `local`.
  @override
  String get type => 'local';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'local',
        'path': path,
      };
}

/// `Rpc.Input`
final class RpcInput {
  const RpcInput({
    this.input,
  });

  factory RpcInput.fromJson(Map<String, Object?> json) => RpcInput(
        input: json['input'],
      );

  final Object? input;

  Map<String, Object?> toJson() => <String, Object?>{
        if (input != null) 'input': input!,
      };
}

/// `Rpc.Output`
final class RpcOutput {
  const RpcOutput({
    this.output,
  });

  factory RpcOutput.fromJson(Map<String, Object?> json) => RpcOutput(
        output: json['output'],
      );

  final Object? output;

  Map<String, Object?> toJson() => <String, Object?>{
        if (output != null) 'output': output!,
      };
}

/// `ServerInfo`
final class ServerInfo {
  const ServerInfo({
    required this.version,
    required this.pid,
    required this.urls,
    required this.paths,
    this.capabilities,
  });

  factory ServerInfo.fromJson(Map<String, Object?> json) => ServerInfo(
        version: decodeString(json, 'version'),
        pid: decodeInt(json, 'pid'),
        urls: jsonList(json['urls'], (item) => asJsonString(item)),
        paths: ServerInfoPaths.fromJson(asJsonMap(json['paths'])),
        capabilities: json['capabilities'] == null
            ? null
            : ServerInfoCapabilities.fromJson(asJsonMap(json['capabilities'])),
      );

  final String version;
  final int pid;
  final List<String> urls;
  final ServerInfoPaths paths;
  final ServerInfoCapabilities? capabilities;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': version,
        'pid': pid,
        'urls': urls,
        'paths': paths.toJson(),
        if (capabilities != null) 'capabilities': capabilities!.toJson(),
      };
}

/// `Tool.Content`
sealed class ToolContent {
  const ToolContent();

  /// Decodes a payload into the matching variant.
  factory ToolContent.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'text' => ToolTextContent.fromJson(json),
      'file' => ToolFileContent.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Tool.Content discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Tool.TextContent`
final class ToolTextContent extends ToolContent {
  const ToolTextContent({
    required this.text,
  });

  factory ToolTextContent.fromJson(Map<String, Object?> json) =>
      ToolTextContent(
        text: decodeString(json, 'text'),
      );

  final String text;

  /// Always `text`.
  @override
  String get type => 'text';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'text',
        'text': text,
      };
}

/// `Tool.FileContent`
final class ToolFileContent extends ToolContent {
  const ToolFileContent({
    required this.uri,
    required this.mime,
    this.name,
  });

  factory ToolFileContent.fromJson(Map<String, Object?> json) =>
      ToolFileContent(
        uri: decodeString(json, 'uri'),
        mime: decodeString(json, 'mime'),
        name: decodeOptionalString(json, 'name'),
      );

  final String uri;
  final String mime;
  final String? name;

  /// Always `file`.
  @override
  String get type => 'file';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'file',
        'uri': uri,
        'mime': mime,
        if (name != null) 'name': name!,
      };
}

/// `SessionGenerateResponse`
final class SessionGenerateResponse {
  const SessionGenerateResponse({
    required this.data,
  });

  factory SessionGenerateResponse.fromJson(Map<String, Object?> json) =>
      SessionGenerateResponse(
        data: SessionGenerateResponseData.fromJson(asJsonMap(json['data'])),
      );

  final SessionGenerateResponseData data;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': data.toJson(),
      };
}

/// `SessionInterruptResponse`
final class SessionInterruptResponse {
  const SessionInterruptResponse({
    required this.interrupted,
  });

  factory SessionInterruptResponse.fromJson(Map<String, Object?> json) =>
      SessionInterruptResponse(
        interrupted: decodeBool(json, 'interrupted'),
      );

  final bool interrupted;

  Map<String, Object?> toJson() => <String, Object?>{
        'interrupted': interrupted,
      };
}

/// `SessionMessagesResponse`
final class SessionMessagesResponse {
  const SessionMessagesResponse({
    required this.data,
    required this.cursor,
  });

  factory SessionMessagesResponse.fromJson(Map<String, Object?> json) =>
      SessionMessagesResponse(
        data: jsonList(json['data'],
            (item) => SessionMessageInfo.fromJson(asJsonMap(item))),
        cursor:
            SessionMessagesResponseCursor.fromJson(asJsonMap(json['cursor'])),
      );

  final List<SessionMessageInfo> data;
  final SessionMessagesResponseCursor cursor;

  Map<String, Object?> toJson() => <String, Object?>{
        'data': [for (final item in data) item.toJson()],
        'cursor': cursor.toJson(),
      };
}

/// `Shell.Info`
final class ShellInfo {
  const ShellInfo({
    required this.id,
    required this.status,
    required this.command,
    required this.cwd,
    required this.shell,
    required this.file,
    this.pid,
    this.exit,
    this.signal,
    required this.metadata,
    required this.time,
  });

  factory ShellInfo.fromJson(Map<String, Object?> json) => ShellInfo(
        id: ShellID.fromJson(asJsonString(json['id'])),
        status: ShellInfoStatus.fromJson(json['status']),
        command: decodeString(json, 'command'),
        cwd: decodeString(json, 'cwd'),
        shell: decodeString(json, 'shell'),
        file: decodeString(json, 'file'),
        pid: decodeOptionalInt(json, 'pid'),
        exit: decodeOptionalNumber(json, 'exit'),
        signal: decodeOptionalString(json, 'signal'),
        metadata: asJsonMap(json['metadata']),
        time: ShellInfoTime.fromJson(asJsonMap(json['time'])),
      );

  final ShellID id;
  final ShellInfoStatus status;
  final String command;
  final String cwd;
  final String shell;
  final String file;
  final int? pid;
  final double? exit;
  final String? signal;
  final Map<String, Object?> metadata;
  final ShellInfoTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'status': status.wire,
        'command': command,
        'cwd': cwd,
        'shell': shell,
        'file': file,
        if (pid != null) 'pid': pid!,
        if (exit != null) 'exit': exit!,
        if (signal != null) 'signal': signal!,
        'metadata': metadata,
        'time': time.toJson(),
      };
}

/// `Skill.Info`
final class SkillInfo {
  const SkillInfo({
    required this.id,
    required this.name,
    this.description,
    this.autoinvoke,
    required this.path,
    required this.content,
  });

  factory SkillInfo.fromJson(Map<String, Object?> json) => SkillInfo(
        id: SkillID.fromJson(asJsonString(json['id'])),
        name: SkillName.fromJson(asJsonString(json['name'])),
        description: decodeOptionalString(json, 'description'),
        autoinvoke: decodeOptionalBool(json, 'autoinvoke'),
        path: AbsolutePath.fromJson(asJsonString(json['path'])),
        content: decodeString(json, 'content'),
      );

  final SkillID id;
  final SkillName name;
  final String? description;
  final bool? autoinvoke;
  final AbsolutePath path;
  final String content;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (description != null) 'description': description!,
        if (autoinvoke != null) 'autoinvoke': autoinvoke!,
        'path': path,
        'content': content,
      };
}

/// `WebSearch.Provider`
final class WebSearchProvider {
  const WebSearchProvider({
    required this.id,
    required this.name,
  });

  factory WebSearchProvider.fromJson(Map<String, Object?> json) =>
      WebSearchProvider(
        id: WebSearchID.fromJson(asJsonString(json['id'])),
        name: decodeString(json, 'name'),
      );

  final WebSearchID id;
  final String name;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
      };
}

/// `WebSearch.ResponseEncoded`
final class WebSearchResponseEncoded {
  const WebSearchResponseEncoded({
    required this.providerID,
    required this.results,
  });

  factory WebSearchResponseEncoded.fromJson(Map<String, Object?> json) =>
      WebSearchResponseEncoded(
        providerID: WebSearchID.fromJson(asJsonString(json['providerID'])),
        results: jsonList(json['results'],
            (item) => WebSearchResult.fromJson(asJsonMap(item))),
      );

  final WebSearchID providerID;
  final List<WebSearchResult> results;

  Map<String, Object?> toJson() => <String, Object?>{
        'providerID': providerID,
        'results': [for (final item in results) item.toJson()],
      };
}

/// `WebSearch.Result`
final class WebSearchResult {
  const WebSearchResult({
    required this.url,
    this.title,
    this.content,
    required this.time,
  });

  factory WebSearchResult.fromJson(Map<String, Object?> json) =>
      WebSearchResult(
        url: decodeString(json, 'url'),
        title: decodeOptionalString(json, 'title'),
        content: decodeOptionalString(json, 'content'),
        time: WebSearchResultTime.fromJson(asJsonMap(json['time'])),
      );

  final String url;
  final String? title;
  final String? content;
  final WebSearchResultTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'url': url,
        if (title != null) 'title': title!,
        if (content != null) 'content': content!,
        'time': time.toJson(),
      };
}
