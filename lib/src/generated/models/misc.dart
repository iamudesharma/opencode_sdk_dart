// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `ConfigAgentEncodedRequest`
final class ConfigAgentEncodedRequest {
  const ConfigAgentEncodedRequest({
    this.headers,
    this.body,
  });

  factory ConfigAgentEncodedRequest.fromJson(Map<String, Object?> json) =>
      ConfigAgentEncodedRequest(
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
      );

  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;

  Map<String, Object?> toJson() => <String, Object?>{
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
      };
}

/// `ConfigInfoEncodedEnterprise`
final class ConfigInfoEncodedEnterprise {
  const ConfigInfoEncodedEnterprise({
    this.url,
  });

  factory ConfigInfoEncodedEnterprise.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedEnterprise(
        url: decodeOptionalString(json, 'url'),
      );

  final String? url;

  Map<String, Object?> toJson() => <String, Object?>{
        if (url != null) 'url': url!,
      };
}

/// `ConfigInfoEncodedPolicies`
final class ConfigInfoEncodedPolicies {
  const ConfigInfoEncodedPolicies({
    required this.action,
    required this.resource,
    required this.effect,
  });

  factory ConfigInfoEncodedPolicies.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedPolicies(
        action: ConfigInfoEncodedPoliciesAction.fromJson(json['action']),
        resource: decodeString(json, 'resource'),
        effect: ConfigInfoEncodedPoliciesEffect.fromJson(json['effect']),
      );

  final ConfigInfoEncodedPoliciesAction action;
  final String resource;
  final ConfigInfoEncodedPoliciesEffect effect;

  Map<String, Object?> toJson() => <String, Object?>{
        'action': action.wire,
        'resource': resource,
        'effect': effect.wire,
      };
}

/// `ConfigInfoEncodedWatcher`
final class ConfigInfoEncodedWatcher {
  const ConfigInfoEncodedWatcher({
    this.ignore,
  });

  factory ConfigInfoEncodedWatcher.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedWatcher(
        ignore: json['ignore'] == null
            ? null
            : jsonList(json['ignore'], (item) => asJsonString(item)),
      );

  final List<String>? ignore;

  Map<String, Object?> toJson() => <String, Object?>{
        if (ignore != null) 'ignore': ignore!,
      };
}

/// `ConfigInfoEncodedMediaImage`
final class ConfigInfoEncodedMediaImage {
  const ConfigInfoEncodedMediaImage({
    this.autoResize,
    this.maxWidth,
    this.maxHeight,
    this.maxBase64Bytes,
  });

  factory ConfigInfoEncodedMediaImage.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedMediaImage(
        autoResize: decodeOptionalBool(json, 'auto_resize'),
        maxWidth: decodeOptionalInt(json, 'max_width'),
        maxHeight: decodeOptionalInt(json, 'max_height'),
        maxBase64Bytes: decodeOptionalInt(json, 'max_base64_bytes'),
      );

  /// Wire field: `auto_resize`.
  final bool? autoResize;

  /// Wire field: `max_width`.
  final int? maxWidth;

  /// Wire field: `max_height`.
  final int? maxHeight;

  /// Wire field: `max_base64_bytes`.
  final int? maxBase64Bytes;

  Map<String, Object?> toJson() => <String, Object?>{
        if (autoResize != null) 'auto_resize': autoResize!,
        if (maxWidth != null) 'max_width': maxWidth!,
        if (maxHeight != null) 'max_height': maxHeight!,
        if (maxBase64Bytes != null) 'max_base64_bytes': maxBase64Bytes!,
      };
}

/// `ConfigInfoEncodedMedia`
final class ConfigInfoEncodedMedia {
  const ConfigInfoEncodedMedia({
    this.image,
  });

  factory ConfigInfoEncodedMedia.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedMedia(
        image: json['image'] == null
            ? null
            : ConfigInfoEncodedMediaImage.fromJson(asJsonMap(json['image'])),
      );

  final ConfigInfoEncodedMediaImage? image;

  Map<String, Object?> toJson() => <String, Object?>{
        if (image != null) 'image': image!.toJson(),
      };
}

/// `ConfigInfoEncodedToolOutput`
final class ConfigInfoEncodedToolOutput {
  const ConfigInfoEncodedToolOutput({
    this.maxLines,
    this.maxBytes,
  });

  factory ConfigInfoEncodedToolOutput.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedToolOutput(
        maxLines: decodeOptionalInt(json, 'max_lines'),
        maxBytes: decodeOptionalInt(json, 'max_bytes'),
      );

  /// Wire field: `max_lines`.
  final int? maxLines;

  /// Wire field: `max_bytes`.
  final int? maxBytes;

  Map<String, Object?> toJson() => <String, Object?>{
        if (maxLines != null) 'max_lines': maxLines!,
        if (maxBytes != null) 'max_bytes': maxBytes!,
      };
}

/// `ConfigInfoEncodedMcpTimeout`
final class ConfigInfoEncodedMcpTimeout {
  const ConfigInfoEncodedMcpTimeout({
    this.startup,
    this.catalog,
    this.execution,
  });

  factory ConfigInfoEncodedMcpTimeout.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedMcpTimeout(
        startup: decodeOptionalInt(json, 'startup'),
        catalog: decodeOptionalInt(json, 'catalog'),
        execution: decodeOptionalInt(json, 'execution'),
      );

  final int? startup;
  final int? catalog;
  final int? execution;

  Map<String, Object?> toJson() => <String, Object?>{
        if (startup != null) 'startup': startup!,
        if (catalog != null) 'catalog': catalog!,
        if (execution != null) 'execution': execution!,
      };
}

/// `ConfigInfoEncodedMcp`
final class ConfigInfoEncodedMcp {
  const ConfigInfoEncodedMcp({
    this.timeout,
    this.servers,
  });

  factory ConfigInfoEncodedMcp.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedMcp(
        timeout: json['timeout'] == null
            ? null
            : ConfigInfoEncodedMcpTimeout.fromJson(asJsonMap(json['timeout'])),
        servers: json['servers'] == null ? null : asJsonMap(json['servers']),
      );

  final ConfigInfoEncodedMcpTimeout? timeout;
  final Map<String, Object?>? servers;

  Map<String, Object?> toJson() => <String, Object?>{
        if (timeout != null) 'timeout': timeout!.toJson(),
        if (servers != null) 'servers': servers!,
      };
}

/// `ConfigInfoEncodedCompactionKeep`
final class ConfigInfoEncodedCompactionKeep {
  const ConfigInfoEncodedCompactionKeep({
    this.tokens,
  });

  factory ConfigInfoEncodedCompactionKeep.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedCompactionKeep(
        tokens: decodeOptionalInt(json, 'tokens'),
      );

  final int? tokens;

  Map<String, Object?> toJson() => <String, Object?>{
        if (tokens != null) 'tokens': tokens!,
      };
}

/// `ConfigInfoEncodedCompaction`
final class ConfigInfoEncodedCompaction {
  const ConfigInfoEncodedCompaction({
    this.auto,
    this.keep,
    this.buffer,
  });

  factory ConfigInfoEncodedCompaction.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedCompaction(
        auto: decodeOptionalBool(json, 'auto'),
        keep: json['keep'] == null
            ? null
            : ConfigInfoEncodedCompactionKeep.fromJson(asJsonMap(json['keep'])),
        buffer: decodeOptionalInt(json, 'buffer'),
      );

  final bool? auto;
  final ConfigInfoEncodedCompactionKeep? keep;
  final int? buffer;

  Map<String, Object?> toJson() => <String, Object?>{
        if (auto != null) 'auto': auto!,
        if (keep != null) 'keep': keep!.toJson(),
        if (buffer != null) 'buffer': buffer!,
      };
}

/// `ConfigInfoEncodedExperimentalPolicies`
final class ConfigInfoEncodedExperimentalPolicies {
  const ConfigInfoEncodedExperimentalPolicies({
    required this.action,
    required this.resource,
    required this.effect,
  });

  factory ConfigInfoEncodedExperimentalPolicies.fromJson(
          Map<String, Object?> json) =>
      ConfigInfoEncodedExperimentalPolicies(
        action: ConfigInfoEncodedExperimentalPoliciesAction.fromJson(
            json['action']),
        resource: decodeString(json, 'resource'),
        effect: ConfigInfoEncodedExperimentalPoliciesEffect.fromJson(
            json['effect']),
      );

  final ConfigInfoEncodedExperimentalPoliciesAction action;
  final String resource;
  final ConfigInfoEncodedExperimentalPoliciesEffect effect;

  Map<String, Object?> toJson() => <String, Object?>{
        'action': action.wire,
        'resource': resource,
        'effect': effect.wire,
      };
}

/// `ConfigInfoEncodedExperimental`
final class ConfigInfoEncodedExperimental {
  const ConfigInfoEncodedExperimental({
    this.portableShellScanner,
    this.subagentDepth,
    this.policies,
  });

  factory ConfigInfoEncodedExperimental.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedExperimental(
        portableShellScanner:
            decodeOptionalBool(json, 'portable_shell_scanner'),
        subagentDepth: decodeOptionalInt(json, 'subagent_depth'),
        policies: json['policies'] == null
            ? null
            : jsonList(
                json['policies'],
                (item) => ConfigInfoEncodedExperimentalPolicies.fromJson(
                    asJsonMap(item))),
      );

  /// Wire field: `portable_shell_scanner`.
  final bool? portableShellScanner;

  /// Wire field: `subagent_depth`.
  final int? subagentDepth;
  final List<ConfigInfoEncodedExperimentalPolicies>? policies;

  Map<String, Object?> toJson() => <String, Object?>{
        if (portableShellScanner != null)
          'portable_shell_scanner': portableShellScanner!,
        if (subagentDepth != null) 'subagent_depth': subagentDepth!,
        if (policies != null)
          'policies': [for (final item in policies!) item.toJson()],
      };
}

/// `ConfigModelCostEncodedTier`
final class ConfigModelCostEncodedTier {
  const ConfigModelCostEncodedTier({
    required this.size,
  });

  factory ConfigModelCostEncodedTier.fromJson(Map<String, Object?> json) =>
      ConfigModelCostEncodedTier(
        size: decodeInt(json, 'size'),
      );

  final int size;

  /// Always `context`.
  String get type => 'context';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'context',
        'size': size,
      };
}

/// `ConfigModelCostEncodedCache`
final class ConfigModelCostEncodedCache {
  const ConfigModelCostEncodedCache({
    this.read,
    this.write,
  });

  factory ConfigModelCostEncodedCache.fromJson(Map<String, Object?> json) =>
      ConfigModelCostEncodedCache(
        read: json['read'] == null
            ? null
            : MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['read'])),
        write: json['write'] == null
            ? null
            : MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['write'])),
      );

  final MoneyUSDPerMillionTokens? read;
  final MoneyUSDPerMillionTokens? write;

  Map<String, Object?> toJson() => <String, Object?>{
        if (read != null) 'read': read!,
        if (write != null) 'write': write!,
      };
}

/// `ConfigModelEncodedVariants`
final class ConfigModelEncodedVariants {
  const ConfigModelEncodedVariants({
    required this.id,
    this.settings,
    this.headers,
    this.body,
  });

  factory ConfigModelEncodedVariants.fromJson(Map<String, Object?> json) =>
      ConfigModelEncodedVariants(
        id: decodeString(json, 'id'),
        settings: json['settings'] == null
            ? null
            : ConfigModelSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
      );

  final String id;
  final ConfigModelSettings? settings;
  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (settings != null) 'settings': settings!.toJson(),
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
      };
}

/// `ConfigModelEncodedLimit`
final class ConfigModelEncodedLimit {
  const ConfigModelEncodedLimit({
    this.context,
    this.input,
    this.output,
  });

  factory ConfigModelEncodedLimit.fromJson(Map<String, Object?> json) =>
      ConfigModelEncodedLimit(
        context: decodeOptionalInt(json, 'context'),
        input: decodeOptionalInt(json, 'input'),
        output: decodeOptionalInt(json, 'output'),
      );

  final int? context;
  final int? input;
  final int? output;

  Map<String, Object?> toJson() => <String, Object?>{
        if (context != null) 'context': context!,
        if (input != null) 'input': input!,
        if (output != null) 'output': output!,
      };
}

/// `GenerateTextResponseData`
final class GenerateTextResponseData {
  const GenerateTextResponseData({
    required this.text,
  });

  factory GenerateTextResponseData.fromJson(Map<String, Object?> json) =>
      GenerateTextResponseData(
        text: decodeString(json, 'text'),
      );

  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
      };
}

/// `IntegrationAttemptEncodedTime`
final class IntegrationAttemptEncodedTime {
  const IntegrationAttemptEncodedTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationAttemptEncodedTime.fromJson(Map<String, Object?> json) =>
      IntegrationAttemptEncodedTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationAttemptStatusPendingTime`
final class IntegrationAttemptStatusPendingTime {
  const IntegrationAttemptStatusPendingTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationAttemptStatusPendingTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationAttemptStatusPendingTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationAttemptStatusCompleteTime`
final class IntegrationAttemptStatusCompleteTime {
  const IntegrationAttemptStatusCompleteTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationAttemptStatusCompleteTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationAttemptStatusCompleteTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationAttemptStatusFailedTime`
final class IntegrationAttemptStatusFailedTime {
  const IntegrationAttemptStatusFailedTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationAttemptStatusFailedTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationAttemptStatusFailedTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationAttemptStatusExpiredTime`
final class IntegrationAttemptStatusExpiredTime {
  const IntegrationAttemptStatusExpiredTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationAttemptStatusExpiredTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationAttemptStatusExpiredTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationCommandAttemptTime`
final class IntegrationCommandAttemptTime {
  const IntegrationCommandAttemptTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationCommandAttemptTime.fromJson(Map<String, Object?> json) =>
      IntegrationCommandAttemptTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationCommandAttemptStatusPendingTime`
final class IntegrationCommandAttemptStatusPendingTime {
  const IntegrationCommandAttemptStatusPendingTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationCommandAttemptStatusPendingTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusPendingTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationCommandAttemptStatusCompleteTime`
final class IntegrationCommandAttemptStatusCompleteTime {
  const IntegrationCommandAttemptStatusCompleteTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationCommandAttemptStatusCompleteTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusCompleteTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationCommandAttemptStatusFailedTime`
final class IntegrationCommandAttemptStatusFailedTime {
  const IntegrationCommandAttemptStatusFailedTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationCommandAttemptStatusFailedTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusFailedTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `IntegrationCommandAttemptStatusExpiredTime`
final class IntegrationCommandAttemptStatusExpiredTime {
  const IntegrationCommandAttemptStatusExpiredTime({
    required this.created,
    required this.expires,
  });

  factory IntegrationCommandAttemptStatusExpiredTime.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusExpiredTime(
        created: json['created'],
        expires: json['expires'],
      );

  final Object? created;
  final Object? expires;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'expires': expires,
      };
}

/// `LocationPublicInfoProject`
final class LocationPublicInfoProject {
  const LocationPublicInfoProject({
    required this.id,
    required this.directory,
    required this.canonical,
  });

  factory LocationPublicInfoProject.fromJson(Map<String, Object?> json) =>
      LocationPublicInfoProject(
        id: ProjectID.fromJson(asJsonString(json['id'])),
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
        canonical: AbsolutePath.fromJson(asJsonString(json['canonical'])),
      );

  final ProjectID id;
  final AbsolutePath directory;
  final AbsolutePath canonical;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'directory': directory,
        'canonical': canonical,
      };
}

/// `McpLocalConfigEncodedTimeout`
final class McpLocalConfigEncodedTimeout {
  const McpLocalConfigEncodedTimeout({
    this.startup,
    this.catalog,
    this.execution,
  });

  factory McpLocalConfigEncodedTimeout.fromJson(Map<String, Object?> json) =>
      McpLocalConfigEncodedTimeout(
        startup: decodeOptionalInt(json, 'startup'),
        catalog: decodeOptionalInt(json, 'catalog'),
        execution: decodeOptionalInt(json, 'execution'),
      );

  final int? startup;
  final int? catalog;
  final int? execution;

  Map<String, Object?> toJson() => <String, Object?>{
        if (startup != null) 'startup': startup!,
        if (catalog != null) 'catalog': catalog!,
        if (execution != null) 'execution': execution!,
      };
}

/// `McpRemoteConfigEncodedTimeout`
final class McpRemoteConfigEncodedTimeout {
  const McpRemoteConfigEncodedTimeout({
    this.startup,
    this.catalog,
    this.execution,
  });

  factory McpRemoteConfigEncodedTimeout.fromJson(Map<String, Object?> json) =>
      McpRemoteConfigEncodedTimeout(
        startup: decodeOptionalInt(json, 'startup'),
        catalog: decodeOptionalInt(json, 'catalog'),
        execution: decodeOptionalInt(json, 'execution'),
      );

  final int? startup;
  final int? catalog;
  final int? execution;

  Map<String, Object?> toJson() => <String, Object?>{
        if (startup != null) 'startup': startup!,
        if (catalog != null) 'catalog': catalog!,
        if (execution != null) 'execution': execution!,
      };
}

/// `McpServerStatus`
sealed class McpServerStatus {
  const McpServerStatus();

  /// Decodes a payload into the matching variant.
  factory McpServerStatus.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'connected' => McpStatusConnected.fromJson(json),
      'pending' => McpStatusPending.fromJson(json),
      'disabled' => McpStatusDisabled.fromJson(json),
      'failed' => McpStatusFailed.fromJson(json),
      'needs_auth' => McpStatusNeedsAuth.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown McpServerStatus discriminator: $value'),
    };
  }

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `ModelCostTier`
final class ModelCostTier {
  const ModelCostTier({
    required this.size,
  });

  factory ModelCostTier.fromJson(Map<String, Object?> json) => ModelCostTier(
        size: decodeInt(json, 'size'),
      );

  final int size;

  /// Always `context`.
  String get type => 'context';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'context',
        'size': size,
      };
}

/// `ModelCostCache`
final class ModelCostCache {
  const ModelCostCache({
    required this.read,
    required this.write,
  });

  factory ModelCostCache.fromJson(Map<String, Object?> json) => ModelCostCache(
        read: MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['read'])),
        write: MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['write'])),
      );

  final MoneyUSDPerMillionTokens read;
  final MoneyUSDPerMillionTokens write;

  Map<String, Object?> toJson() => <String, Object?>{
        'read': read,
        'write': write,
      };
}

/// `ModelInfoTime`
final class ModelInfoTime {
  const ModelInfoTime({
    required this.released,
  });

  factory ModelInfoTime.fromJson(Map<String, Object?> json) => ModelInfoTime(
        released: decodeNumber(json, 'released'),
      );

  final double released;

  Map<String, Object?> toJson() => <String, Object?>{
        'released': released,
      };
}

/// `ModelInfoLimit`
final class ModelInfoLimit {
  const ModelInfoLimit({
    required this.context,
    this.input,
    required this.output,
  });

  factory ModelInfoLimit.fromJson(Map<String, Object?> json) => ModelInfoLimit(
        context: decodeInt(json, 'context'),
        input: decodeOptionalInt(json, 'input'),
        output: decodeInt(json, 'output'),
      );

  final int context;
  final int? input;
  final int output;

  Map<String, Object?> toJson() => <String, Object?>{
        'context': context,
        if (input != null) 'input': input!,
        'output': output,
      };
}

/// `PermissionSource2`
final class PermissionSource2 {
  const PermissionSource2({
    required this.messageID,
    required this.id,
  });

  factory PermissionSource2.fromJson(Map<String, Object?> json) =>
      PermissionSource2(
        messageID: decodeString(json, 'messageID'),
        id: decodeString(json, 'id'),
      );

  final String messageID;
  final String id;

  /// Always `tool`.
  String get type => 'tool';

  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'tool',
        'messageID': messageID,
        'id': id,
      };
}

/// `PermissionSavedInfoTime`
final class PermissionSavedInfoTime {
  const PermissionSavedInfoTime({
    required this.created,
    required this.updated,
  });

  factory PermissionSavedInfoTime.fromJson(Map<String, Object?> json) =>
      PermissionSavedInfoTime(
        created: decodeNumber(json, 'created'),
        updated: decodeNumber(json, 'updated'),
      );

  final double created;
  final double updated;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'updated': updated,
      };
}

/// `PersistentPtyCreateInputSize`
final class PersistentPtyCreateInputSize {
  const PersistentPtyCreateInputSize({
    required this.cols,
    required this.rows,
  });

  factory PersistentPtyCreateInputSize.fromJson(Map<String, Object?> json) =>
      PersistentPtyCreateInputSize(
        cols: decodeInt(json, 'cols'),
        rows: decodeInt(json, 'rows'),
      );

  final int cols;
  final int rows;

  Map<String, Object?> toJson() => <String, Object?>{
        'cols': cols,
        'rows': rows,
      };
}

/// `PersistentPtyInfoSize`
final class PersistentPtyInfoSize {
  const PersistentPtyInfoSize({
    required this.cols,
    required this.rows,
  });

  factory PersistentPtyInfoSize.fromJson(Map<String, Object?> json) =>
      PersistentPtyInfoSize(
        cols: decodeInt(json, 'cols'),
        rows: decodeInt(json, 'rows'),
      );

  final int cols;
  final int rows;

  Map<String, Object?> toJson() => <String, Object?>{
        'cols': cols,
        'rows': rows,
      };
}

/// `PersistentPtyInfoOutput`
final class PersistentPtyInfoOutput {
  const PersistentPtyInfoOutput({
    required this.head,
    required this.tail,
  });

  factory PersistentPtyInfoOutput.fromJson(Map<String, Object?> json) =>
      PersistentPtyInfoOutput(
        head: decodeInt(json, 'head'),
        tail: decodeInt(json, 'tail'),
      );

  final int head;
  final int tail;

  Map<String, Object?> toJson() => <String, Object?>{
        'head': head,
        'tail': tail,
      };
}

/// `PersistentPtyReadResultScreenCursor`
final class PersistentPtyReadResultScreenCursor {
  const PersistentPtyReadResultScreenCursor({
    required this.x,
    required this.y,
  });

  factory PersistentPtyReadResultScreenCursor.fromJson(
          Map<String, Object?> json) =>
      PersistentPtyReadResultScreenCursor(
        x: decodeInt(json, 'x'),
        y: decodeInt(json, 'y'),
      );

  final int x;
  final int y;

  Map<String, Object?> toJson() => <String, Object?>{
        'x': x,
        'y': y,
      };
}

/// `PersistentPtyReadResultScreen`
final class PersistentPtyReadResultScreen {
  const PersistentPtyReadResultScreen({
    required this.text,
    required this.cols,
    required this.rows,
    required this.cursor,
  });

  factory PersistentPtyReadResultScreen.fromJson(Map<String, Object?> json) =>
      PersistentPtyReadResultScreen(
        text: decodeString(json, 'text'),
        cols: decodeInt(json, 'cols'),
        rows: decodeInt(json, 'rows'),
        cursor: PersistentPtyReadResultScreenCursor.fromJson(
            asJsonMap(json['cursor'])),
      );

  final String text;
  final int cols;
  final int rows;
  final PersistentPtyReadResultScreenCursor cursor;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
        'cols': cols,
        'rows': rows,
        'cursor': cursor.toJson(),
      };
}

/// `PersistentPtySnapshotCursor`
final class PersistentPtySnapshotCursor {
  const PersistentPtySnapshotCursor({
    required this.x,
    required this.y,
  });

  factory PersistentPtySnapshotCursor.fromJson(Map<String, Object?> json) =>
      PersistentPtySnapshotCursor(
        x: decodeInt(json, 'x'),
        y: decodeInt(json, 'y'),
      );

  final int x;
  final int y;

  Map<String, Object?> toJson() => <String, Object?>{
        'x': x,
        'y': y,
      };
}

/// `PersistentPtyUpdateInputSize`
final class PersistentPtyUpdateInputSize {
  const PersistentPtyUpdateInputSize({
    required this.cols,
    required this.rows,
  });

  factory PersistentPtyUpdateInputSize.fromJson(Map<String, Object?> json) =>
      PersistentPtyUpdateInputSize(
        cols: decodeInt(json, 'cols'),
        rows: decodeInt(json, 'rows'),
      );

  final int cols;
  final int rows;

  Map<String, Object?> toJson() => <String, Object?>{
        'cols': cols,
        'rows': rows,
      };
}

/// `ServerInfoPaths`
final class ServerInfoPaths {
  const ServerInfoPaths({
    required this.tmp,
  });

  factory ServerInfoPaths.fromJson(Map<String, Object?> json) =>
      ServerInfoPaths(
        tmp: decodeString(json, 'tmp'),
      );

  final String tmp;

  Map<String, Object?> toJson() => <String, Object?>{
        'tmp': tmp,
      };
}

/// `ServerInfoCapabilities`
final class ServerInfoCapabilities {
  const ServerInfoCapabilities({
    this.persistentPty,
  });

  factory ServerInfoCapabilities.fromJson(Map<String, Object?> json) =>
      ServerInfoCapabilities(
        persistentPty: decodeOptionalBool(json, 'persistentPty'),
      );

  final bool? persistentPty;

  Map<String, Object?> toJson() => <String, Object?>{
        if (persistentPty != null) 'persistentPty': persistentPty!,
      };
}

/// `SessionInboxCompactionTime`
final class SessionInboxCompactionTime {
  const SessionInboxCompactionTime({
    required this.created,
  });

  factory SessionInboxCompactionTime.fromJson(Map<String, Object?> json) =>
      SessionInboxCompactionTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionInboxUserTime`
final class SessionInboxUserTime {
  const SessionInboxUserTime({
    required this.created,
  });

  factory SessionInboxUserTime.fromJson(Map<String, Object?> json) =>
      SessionInboxUserTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionInboxSyntheticTime`
final class SessionInboxSyntheticTime {
  const SessionInboxSyntheticTime({
    required this.created,
  });

  factory SessionInboxSyntheticTime.fromJson(Map<String, Object?> json) =>
      SessionInboxSyntheticTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionInboxMoveTime`
final class SessionInboxMoveTime {
  const SessionInboxMoveTime({
    required this.created,
  });

  factory SessionInboxMoveTime.fromJson(Map<String, Object?> json) =>
      SessionInboxMoveTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionInfoFork`
final class SessionInfoFork {
  const SessionInfoFork({
    required this.sessionID,
    required this.boundary,
  });

  factory SessionInfoFork.fromJson(Map<String, Object?> json) =>
      SessionInfoFork(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        boundary: SessionForkBoundary.fromJson(asJsonMap(json['boundary'])),
      );

  final SessionID sessionID;
  final SessionForkBoundary boundary;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'boundary': boundary.toJson(),
      };
}

/// `TokenUsageInfoCache`
final class TokenUsageInfoCache {
  const TokenUsageInfoCache({
    required this.read,
    required this.write,
  });

  factory TokenUsageInfoCache.fromJson(Map<String, Object?> json) =>
      TokenUsageInfoCache(
        read: decodeNumber(json, 'read'),
        write: decodeNumber(json, 'write'),
      );

  final double read;
  final double write;

  Map<String, Object?> toJson() => <String, Object?>{
        'read': read,
        'write': write,
      };
}

/// `SessionInfoTime`
final class SessionInfoTime {
  const SessionInfoTime({
    required this.created,
    required this.updated,
    this.idle,
    this.viewed,
    this.archived,
  });

  factory SessionInfoTime.fromJson(Map<String, Object?> json) =>
      SessionInfoTime(
        created: decodeNumber(json, 'created'),
        updated: decodeNumber(json, 'updated'),
        idle: decodeOptionalNumber(json, 'idle'),
        viewed: decodeOptionalNumber(json, 'viewed'),
        archived: decodeOptionalNumber(json, 'archived'),
      );

  final double created;
  final double updated;
  final double? idle;
  final double? viewed;
  final double? archived;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'updated': updated,
        if (idle != null) 'idle': idle!,
        if (viewed != null) 'viewed': viewed!,
        if (archived != null) 'archived': archived!,
      };
}

/// `SessionMessageAgentSelectedTime`
final class SessionMessageAgentSelectedTime {
  const SessionMessageAgentSelectedTime({
    required this.created,
  });

  factory SessionMessageAgentSelectedTime.fromJson(Map<String, Object?> json) =>
      SessionMessageAgentSelectedTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageAssistantTime`
final class SessionMessageAssistantTime {
  const SessionMessageAssistantTime({
    required this.created,
    this.streamed,
    this.completed,
  });

  factory SessionMessageAssistantTime.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantTime(
        created: decodeNumber(json, 'created'),
        streamed: decodeOptionalNumber(json, 'streamed'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double created;
  final double? streamed;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        if (streamed != null) 'streamed': streamed!,
        if (completed != null) 'completed': completed!,
      };
}

/// `SessionMessageAssistantContent`
sealed class SessionMessageAssistantContent {
  const SessionMessageAssistantContent();

  /// Decodes a payload into the matching variant.
  factory SessionMessageAssistantContent.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'text' => SessionMessageAssistantText.fromJson(json),
      'reasoning' => SessionMessageAssistantReasoning.fromJson(json),
      'tool' => SessionMessageAssistantTool.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown SessionMessageAssistantContent discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `SessionMessageAssistantReasoningTime`
final class SessionMessageAssistantReasoningTime {
  const SessionMessageAssistantReasoningTime({
    required this.created,
    this.completed,
  });

  factory SessionMessageAssistantReasoningTime.fromJson(
          Map<String, Object?> json) =>
      SessionMessageAssistantReasoningTime(
        created: decodeNumber(json, 'created'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double created;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        if (completed != null) 'completed': completed!,
      };
}

/// `SessionMessageAssistantToolState`
sealed class SessionMessageAssistantToolState {
  const SessionMessageAssistantToolState();

  /// Decodes a payload into the matching variant.
  factory SessionMessageAssistantToolState.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'streaming' => SessionMessageToolStateStreaming.fromJson(json),
      'running' => SessionMessageToolStateRunning.fromJson(json),
      'completed' => SessionMessageToolStateCompleted.fromJson(json),
      'error' => SessionMessageToolStateError.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown SessionMessageAssistantToolState discriminator: $value'),
    };
  }

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `SessionStructuredErrorResponse`
final class SessionStructuredErrorResponse {
  const SessionStructuredErrorResponse({
    required this.body,
  });

  factory SessionStructuredErrorResponse.fromJson(Map<String, Object?> json) =>
      SessionStructuredErrorResponse(
        body: decodeString(json, 'body'),
      );

  final String body;

  Map<String, Object?> toJson() => <String, Object?>{
        'body': body,
      };
}

/// `SessionMessageAssistantToolTime`
final class SessionMessageAssistantToolTime {
  const SessionMessageAssistantToolTime({
    required this.created,
    this.ran,
    this.completed,
  });

  factory SessionMessageAssistantToolTime.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantToolTime(
        created: decodeNumber(json, 'created'),
        ran: decodeOptionalNumber(json, 'ran'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double created;
  final double? ran;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        if (ran != null) 'ran': ran!,
        if (completed != null) 'completed': completed!,
      };
}

/// `SessionMessageAssistantSnapshot`
final class SessionMessageAssistantSnapshot {
  const SessionMessageAssistantSnapshot({
    this.start,
    this.end,
    this.files,
  });

  factory SessionMessageAssistantSnapshot.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantSnapshot(
        start: json['start'] == null
            ? null
            : SnapshotID.fromJson(asJsonString(json['start'])),
        end: json['end'] == null
            ? null
            : SnapshotID.fromJson(asJsonString(json['end'])),
        files: json['files'] == null
            ? null
            : jsonList(json['files'],
                (item) => RelativePath.fromJson(asJsonString(item))),
      );

  final SnapshotID? start;
  final SnapshotID? end;
  final List<RelativePath>? files;

  Map<String, Object?> toJson() => <String, Object?>{
        if (start != null) 'start': start!,
        if (end != null) 'end': end!,
        if (files != null) 'files': files!,
      };
}

/// `SessionMessageCompactionRunningTime`
final class SessionMessageCompactionRunningTime {
  const SessionMessageCompactionRunningTime({
    required this.created,
  });

  factory SessionMessageCompactionRunningTime.fromJson(
          Map<String, Object?> json) =>
      SessionMessageCompactionRunningTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageCompactionCompletedTime`
final class SessionMessageCompactionCompletedTime {
  const SessionMessageCompactionCompletedTime({
    required this.created,
  });

  factory SessionMessageCompactionCompletedTime.fromJson(
          Map<String, Object?> json) =>
      SessionMessageCompactionCompletedTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageCompactionFailedTime`
final class SessionMessageCompactionFailedTime {
  const SessionMessageCompactionFailedTime({
    required this.created,
  });

  factory SessionMessageCompactionFailedTime.fromJson(
          Map<String, Object?> json) =>
      SessionMessageCompactionFailedTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageIdleTime`
final class SessionMessageIdleTime {
  const SessionMessageIdleTime({
    required this.created,
  });

  factory SessionMessageIdleTime.fromJson(Map<String, Object?> json) =>
      SessionMessageIdleTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageModelSelectedTime`
final class SessionMessageModelSelectedTime {
  const SessionMessageModelSelectedTime({
    required this.created,
  });

  factory SessionMessageModelSelectedTime.fromJson(Map<String, Object?> json) =>
      SessionMessageModelSelectedTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageLocationSwitchedTime`
final class SessionMessageLocationSwitchedTime {
  const SessionMessageLocationSwitchedTime({
    required this.created,
  });

  factory SessionMessageLocationSwitchedTime.fromJson(
          Map<String, Object?> json) =>
      SessionMessageLocationSwitchedTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageLocationSwitchedPrevious`
final class SessionMessageLocationSwitchedPrevious {
  const SessionMessageLocationSwitchedPrevious({
    required this.location,
    this.projectID,
    this.subpath,
  });

  factory SessionMessageLocationSwitchedPrevious.fromJson(
          Map<String, Object?> json) =>
      SessionMessageLocationSwitchedPrevious(
        location: LocationRef.fromJson(json['location']),
        projectID: json['projectID'] == null
            ? null
            : ProjectID.fromJson(asJsonString(json['projectID'])),
        subpath: json['subpath'] == null
            ? null
            : RelativePath.fromJson(asJsonString(json['subpath'])),
      );

  final LocationRef location;
  final ProjectID? projectID;
  final RelativePath? subpath;

  Map<String, Object?> toJson() => <String, Object?>{
        'location': location.toJson(),
        if (projectID != null) 'projectID': projectID!,
        if (subpath != null) 'subpath': subpath!,
      };
}

/// `SessionMessageUserTime`
final class SessionMessageUserTime {
  const SessionMessageUserTime({
    required this.created,
  });

  factory SessionMessageUserTime.fromJson(Map<String, Object?> json) =>
      SessionMessageUserTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageSyntheticTime`
final class SessionMessageSyntheticTime {
  const SessionMessageSyntheticTime({
    required this.created,
  });

  factory SessionMessageSyntheticTime.fromJson(Map<String, Object?> json) =>
      SessionMessageSyntheticTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageSystemTime`
final class SessionMessageSystemTime {
  const SessionMessageSystemTime({
    required this.created,
  });

  factory SessionMessageSystemTime.fromJson(Map<String, Object?> json) =>
      SessionMessageSystemTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageSkillTime`
final class SessionMessageSkillTime {
  const SessionMessageSkillTime({
    required this.created,
  });

  factory SessionMessageSkillTime.fromJson(Map<String, Object?> json) =>
      SessionMessageSkillTime(
        created: decodeNumber(json, 'created'),
      );

  final double created;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
      };
}

/// `SessionMessageShellTime`
final class SessionMessageShellTime {
  const SessionMessageShellTime({
    required this.created,
    this.completed,
  });

  factory SessionMessageShellTime.fromJson(Map<String, Object?> json) =>
      SessionMessageShellTime(
        created: decodeNumber(json, 'created'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double created;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        if (completed != null) 'completed': completed!,
      };
}

/// `SessionMessageShellOutput`
final class SessionMessageShellOutput {
  const SessionMessageShellOutput({
    required this.output,
    required this.cursor,
    required this.size,
    required this.truncated,
  });

  factory SessionMessageShellOutput.fromJson(Map<String, Object?> json) =>
      SessionMessageShellOutput(
        output: decodeString(json, 'output'),
        cursor: decodeInt(json, 'cursor'),
        size: decodeInt(json, 'size'),
        truncated: decodeBool(json, 'truncated'),
      );

  final String output;
  final int cursor;
  final int size;
  final bool truncated;

  Map<String, Object?> toJson() => <String, Object?>{
        'output': output,
        'cursor': cursor,
        'size': size,
        'truncated': truncated,
      };
}

/// `SessionGenerateResponseData`
final class SessionGenerateResponseData {
  const SessionGenerateResponseData({
    required this.text,
  });

  factory SessionGenerateResponseData.fromJson(Map<String, Object?> json) =>
      SessionGenerateResponseData(
        text: decodeString(json, 'text'),
      );

  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
      };
}

/// `SessionMessagesResponseCursor`
final class SessionMessagesResponseCursor {
  const SessionMessagesResponseCursor({
    this.previous,
    this.next,
  });

  factory SessionMessagesResponseCursor.fromJson(Map<String, Object?> json) =>
      SessionMessagesResponseCursor(
        previous: decodeOptionalString(json, 'previous'),
        next: decodeOptionalString(json, 'next'),
      );

  final String? previous;
  final String? next;

  Map<String, Object?> toJson() => <String, Object?>{
        if (previous != null) 'previous': previous!,
        if (next != null) 'next': next!,
      };
}

/// `SessionStatsInfoRange`
final class SessionStatsInfoRange {
  const SessionStatsInfoRange({
    required this.from,
    required this.to,
  });

  factory SessionStatsInfoRange.fromJson(Map<String, Object?> json) =>
      SessionStatsInfoRange(
        from: decodeNumber(json, 'from'),
        to: decodeNumber(json, 'to'),
      );

  final double from;
  final double to;

  Map<String, Object?> toJson() => <String, Object?>{
        'from': from,
        'to': to,
      };
}

/// `SessionsResponseCursor`
final class SessionsResponseCursor {
  const SessionsResponseCursor({
    this.previous,
    this.next,
  });

  factory SessionsResponseCursor.fromJson(Map<String, Object?> json) =>
      SessionsResponseCursor(
        previous: json['previous'] == null
            ? null
            : SessionsCursor.fromJson(asJsonString(json['previous'])),
        next: json['next'] == null
            ? null
            : SessionsCursor.fromJson(asJsonString(json['next'])),
      );

  final SessionsCursor? previous;
  final SessionsCursor? next;

  Map<String, Object?> toJson() => <String, Object?>{
        if (previous != null) 'previous': previous!,
        if (next != null) 'next': next!,
      };
}

/// `ShellInfoTime`
final class ShellInfoTime {
  const ShellInfoTime({
    required this.started,
    this.completed,
  });

  factory ShellInfoTime.fromJson(Map<String, Object?> json) => ShellInfoTime(
        started: decodeNumber(json, 'started'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double started;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'started': started,
        if (completed != null) 'completed': completed!,
      };
}

/// `WebSearchResultTime`
final class WebSearchResultTime {
  const WebSearchResultTime({
    this.published,
  });

  factory WebSearchResultTime.fromJson(Map<String, Object?> json) =>
      WebSearchResultTime(
        published: decodeOptionalNumber(json, 'published'),
      );

  final double? published;

  Map<String, Object?> toJson() => <String, Object?>{
        if (published != null) 'published': published!,
      };
}

/// `WorktreeErrorData`
final class WorktreeErrorData {
  const WorktreeErrorData({
    required this.message,
    this.forceRequired,
  });

  factory WorktreeErrorData.fromJson(Map<String, Object?> json) =>
      WorktreeErrorData(
        message: decodeString(json, 'message'),
        forceRequired: decodeOptionalBool(json, 'forceRequired'),
      );

  final String message;
  final bool? forceRequired;

  Map<String, Object?> toJson() => <String, Object?>{
        'message': message,
        if (forceRequired != null) 'forceRequired': forceRequired!,
      };
}

/// `ExperimentalMcpAddInputConfig`
sealed class ExperimentalMcpAddInputConfig {
  const ExperimentalMcpAddInputConfig();

  /// Decodes a payload into the matching variant.
  factory ExperimentalMcpAddInputConfig.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'local' => McpLocalConfigEncoded.fromJson(json),
      'remote' => McpRemoteConfigEncoded.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown ExperimentalMcpAddInputConfig discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`disabled`).
  bool? get disabled;

  /// Present on every variant (`codemode`).
  bool? get codemode;

  /// Present on every variant (`protocol`).
  McpProtocol? get protocol;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `SessionPermissionCreateResponse`
final class SessionPermissionCreateResponse {
  const SessionPermissionCreateResponse({
    required this.id,
    required this.effect,
  });

  factory SessionPermissionCreateResponse.fromJson(Map<String, Object?> json) =>
      SessionPermissionCreateResponse(
        id: PermissionID.fromJson(asJsonString(json['id'])),
        effect: PermissionEffect.fromJson(json['effect']),
      );

  final PermissionID id;
  final PermissionEffect effect;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'effect': effect.wire,
      };
}

/// `ServerExperimentalPersistentPtyCreateInputSize`
final class ServerExperimentalPersistentPtyCreateInputSize {
  const ServerExperimentalPersistentPtyCreateInputSize({
    required this.cols,
    required this.rows,
  });

  factory ServerExperimentalPersistentPtyCreateInputSize.fromJson(
          Map<String, Object?> json) =>
      ServerExperimentalPersistentPtyCreateInputSize(
        cols: decodeInt(json, 'cols'),
        rows: decodeInt(json, 'rows'),
      );

  final int cols;
  final int rows;

  Map<String, Object?> toJson() => <String, Object?>{
        'cols': cols,
        'rows': rows,
      };
}

/// `ServerExperimentalPersistentPtyHandoffResponse`
final class ServerExperimentalPersistentPtyHandoffResponse {
  const ServerExperimentalPersistentPtyHandoffResponse({
    required this.handoff,
  });

  factory ServerExperimentalPersistentPtyHandoffResponse.fromJson(
          Map<String, Object?> json) =>
      ServerExperimentalPersistentPtyHandoffResponse(
        handoff: json['handoff'] == null
            ? null
            : PersistentPtyHandoff.fromJson(asJsonMap(json['handoff'])),
      );

  final PersistentPtyHandoff? handoff;

  Map<String, Object?> toJson() => <String, Object?>{
        if (handoff != null) 'handoff': handoff!.toJson(),
      };
}

/// `ServerExperimentalPersistentPtyUpdateInputSize`
final class ServerExperimentalPersistentPtyUpdateInputSize {
  const ServerExperimentalPersistentPtyUpdateInputSize({
    required this.cols,
    required this.rows,
  });

  factory ServerExperimentalPersistentPtyUpdateInputSize.fromJson(
          Map<String, Object?> json) =>
      ServerExperimentalPersistentPtyUpdateInputSize(
        cols: decodeInt(json, 'cols'),
        rows: decodeInt(json, 'rows'),
      );

  final int cols;
  final int rows;

  Map<String, Object?> toJson() => <String, Object?>{
        'cols': cols,
        'rows': rows,
      };
}

/// `PtyUpdateInputSize`
final class PtyUpdateInputSize {
  const PtyUpdateInputSize({
    required this.rows,
    required this.cols,
  });

  factory PtyUpdateInputSize.fromJson(Map<String, Object?> json) =>
      PtyUpdateInputSize(
        rows: decodeInt(json, 'rows'),
        cols: decodeInt(json, 'cols'),
      );

  final int rows;
  final int cols;

  Map<String, Object?> toJson() => <String, Object?>{
        'rows': rows,
        'cols': cols,
      };
}

/// `ShellOutputResponse`
final class ShellOutputResponse {
  const ShellOutputResponse({
    required this.output,
    required this.cursor,
    required this.size,
    required this.truncated,
  });

  factory ShellOutputResponse.fromJson(Map<String, Object?> json) =>
      ShellOutputResponse(
        output: decodeString(json, 'output'),
        cursor: decodeInt(json, 'cursor'),
        size: decodeInt(json, 'size'),
        truncated: decodeBool(json, 'truncated'),
      );

  final String output;
  final int cursor;
  final int size;
  final bool truncated;

  Map<String, Object?> toJson() => <String, Object?>{
        'output': output,
        'cursor': cursor,
        'size': size,
        'truncated': truncated,
      };
}
