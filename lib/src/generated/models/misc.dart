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
        buffer: json['buffer'],
      );

  final bool? auto;
  final ConfigInfoEncodedCompactionKeep? keep;
  final Object? buffer;

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
    this.codemodeVm,
    this.allFlags,
    this.todo,
    this.backgroundCompaction,
    this.mediaBlob,
    this.schedules,
    this.artifacts,
    this.consoleWatches,
    this.mcpEvents,
    this.partRows,
    this.imageGenerate,
    this.subagentDepth,
    this.locationIdleTimeout,
    this.policies,
  });

  factory ConfigInfoEncodedExperimental.fromJson(Map<String, Object?> json) =>
      ConfigInfoEncodedExperimental(
        portableShellScanner:
            decodeOptionalBool(json, 'portable_shell_scanner'),
        codemodeVm: decodeOptionalBool(json, 'codemode_vm'),
        allFlags: decodeOptionalBool(json, 'all_flags'),
        todo: decodeOptionalBool(json, 'todo'),
        backgroundCompaction: decodeOptionalBool(json, 'background_compaction'),
        mediaBlob: decodeOptionalBool(json, 'media_blob'),
        schedules: decodeOptionalBool(json, 'schedules'),
        artifacts: decodeOptionalBool(json, 'artifacts'),
        consoleWatches: decodeOptionalBool(json, 'console_watches'),
        mcpEvents: decodeOptionalBool(json, 'mcp_events'),
        partRows: decodeOptionalBool(json, 'part_rows'),
        imageGenerate: json['image_generate'],
        subagentDepth: decodeOptionalInt(json, 'subagent_depth'),
        locationIdleTimeout: json['location_idle_timeout'],
        policies: json['policies'] == null
            ? null
            : jsonList(
                json['policies'],
                (item) => ConfigInfoEncodedExperimentalPolicies.fromJson(
                    asJsonMap(item))),
      );

  /// Wire field: `portable_shell_scanner`.
  final bool? portableShellScanner;

  /// Wire field: `codemode_vm`.
  final bool? codemodeVm;

  /// Wire field: `all_flags`.
  final bool? allFlags;
  final bool? todo;

  /// Wire field: `background_compaction`.
  final bool? backgroundCompaction;

  /// Wire field: `media_blob`.
  final bool? mediaBlob;
  final bool? schedules;
  final bool? artifacts;

  /// Wire field: `console_watches`.
  final bool? consoleWatches;

  /// Wire field: `mcp_events`.
  final bool? mcpEvents;

  /// Wire field: `part_rows`.
  final bool? partRows;

  /// Wire field: `image_generate`.
  final Object? imageGenerate;

  /// Wire field: `subagent_depth`.
  final int? subagentDepth;

  /// Wire field: `location_idle_timeout`.
  final Object? locationIdleTimeout;
  final List<ConfigInfoEncodedExperimentalPolicies>? policies;

  Map<String, Object?> toJson() => <String, Object?>{
        if (portableShellScanner != null)
          'portable_shell_scanner': portableShellScanner!,
        if (codemodeVm != null) 'codemode_vm': codemodeVm!,
        if (allFlags != null) 'all_flags': allFlags!,
        if (todo != null) 'todo': todo!,
        if (backgroundCompaction != null)
          'background_compaction': backgroundCompaction!,
        if (mediaBlob != null) 'media_blob': mediaBlob!,
        if (schedules != null) 'schedules': schedules!,
        if (artifacts != null) 'artifacts': artifacts!,
        if (consoleWatches != null) 'console_watches': consoleWatches!,
        if (mcpEvents != null) 'mcp_events': mcpEvents!,
        if (partRows != null) 'part_rows': partRows!,
        if (imageGenerate != null) 'image_generate': imageGenerate!,
        if (subagentDepth != null) 'subagent_depth': subagentDepth!,
        if (locationIdleTimeout != null)
          'location_idle_timeout': locationIdleTimeout!,
        if (policies != null)
          'policies': [for (final item in policies!) item.toJson()],
      };
}

/// `ConfigModelReasoningTrueBudget`
final class ConfigModelReasoningTrueBudget {
  const ConfigModelReasoningTrueBudget({
    this.min,
    this.max,
  });

  factory ConfigModelReasoningTrueBudget.fromJson(Map<String, Object?> json) =>
      ConfigModelReasoningTrueBudget(
        min: decodeOptionalInt(json, 'min'),
        max: decodeOptionalInt(json, 'max'),
      );

  final int? min;
  final int? max;

  Map<String, Object?> toJson() => <String, Object?>{
        if (min != null) 'min': min!,
        if (max != null) 'max': max!,
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
            : ConfigModelVariantSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
      );

  final String id;
  final ConfigModelVariantSettings? settings;
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

/// `GenerateChoiceAnswerProbabilities`
final class GenerateChoiceAnswerProbabilities {
  const GenerateChoiceAnswerProbabilities({
    required this.value,
    required this.probability,
  });

  factory GenerateChoiceAnswerProbabilities.fromJson(
          Map<String, Object?> json) =>
      GenerateChoiceAnswerProbabilities(
        value: json['value'],
        probability: decodeNumber(json, 'probability'),
      );

  final Object? value;
  final double probability;

  Map<String, Object?> toJson() => <String, Object?>{
        'value': value,
        'probability': probability,
      };
}

/// `GenerateChoiceQuestionChoices`
final class GenerateChoiceQuestionChoices {
  const GenerateChoiceQuestionChoices({
    required this.value,
    this.description,
  });

  factory GenerateChoiceQuestionChoices.fromJson(Map<String, Object?> json) =>
      GenerateChoiceQuestionChoices(
        value: json['value'],
        description: decodeOptionalString(json, 'description'),
      );

  final Object? value;
  final String? description;

  Map<String, Object?> toJson() => <String, Object?>{
        'value': value,
        if (description != null) 'description': description!,
      };
}

/// `GenerateScoreAnswerProbabilities`
final class GenerateScoreAnswerProbabilities {
  const GenerateScoreAnswerProbabilities({
    required this.value,
    required this.label,
    required this.probability,
  });

  factory GenerateScoreAnswerProbabilities.fromJson(
          Map<String, Object?> json) =>
      GenerateScoreAnswerProbabilities(
        value: decodeInt(json, 'value'),
        label: decodeString(json, 'label'),
        probability: decodeNumber(json, 'probability'),
      );

  final int value;
  final String label;
  final double probability;

  Map<String, Object?> toJson() => <String, Object?>{
        'value': value,
        'label': label,
        'probability': probability,
      };
}

/// `GeneratePredicateQuestionCriteria`
final class GeneratePredicateQuestionCriteria {
  const GeneratePredicateQuestionCriteria({
    this.trueValue,
    this.falseValue,
  });

  factory GeneratePredicateQuestionCriteria.fromJson(
          Map<String, Object?> json) =>
      GeneratePredicateQuestionCriteria(
        trueValue: decodeOptionalString(json, 'true'),
        falseValue: decodeOptionalString(json, 'false'),
      );

  /// Wire field: `true`.
  final String? trueValue;

  /// Wire field: `false`.
  final String? falseValue;

  Map<String, Object?> toJson() => <String, Object?>{
        if (trueValue != null) 'true': trueValue!,
        if (falseValue != null) 'false': falseValue!,
      };
}

/// `GenerateScoreQuestionLevels`
final class GenerateScoreQuestionLevels {
  const GenerateScoreQuestionLevels({
    required this.label,
    this.description,
  });

  factory GenerateScoreQuestionLevels.fromJson(Map<String, Object?> json) =>
      GenerateScoreQuestionLevels(
        label: decodeString(json, 'label'),
        description: decodeOptionalString(json, 'description'),
      );

  final String label;
  final String? description;

  Map<String, Object?> toJson() => <String, Object?>{
        'label': label,
        if (description != null) 'description': description!,
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

/// `InstructionEntrySnapshot2`
final class InstructionEntrySnapshot2 {
  const InstructionEntrySnapshot2({
    required this.key,
    required this.value,
    required this.removed,
  });

  factory InstructionEntrySnapshot2.fromJson(Map<String, Object?> json) =>
      InstructionEntrySnapshot2(
        key: InstructionEntryKey.fromJson(asJsonString(json['key'])),
        value: json['value'],
        removed: decodeBool(json, 'removed'),
      );

  final InstructionEntryKey key;
  final Object? value;
  final bool removed;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'value': value,
        'removed': removed,
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

/// `ScheduleInfoTime`
final class ScheduleInfoTime {
  const ScheduleInfoTime({
    required this.created,
    required this.updated,
  });

  factory ScheduleInfoTime.fromJson(Map<String, Object?> json) =>
      ScheduleInfoTime(
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

/// `SessionCreatedDurable`
final class SessionCreatedDurable {
  const SessionCreatedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionCreatedDurable.fromJson(Map<String, Object?> json) =>
      SessionCreatedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionCreatedData`
final class SessionCreatedData {
  const SessionCreatedData({
    required this.sessionID,
    required this.projectID,
    required this.location,
    this.subpath,
    this.parentID,
    required this.slug,
    this.title,
    this.agent,
    this.model,
    this.metadata,
    this.permissions,
    required this.version,
  });

  factory SessionCreatedData.fromJson(Map<String, Object?> json) =>
      SessionCreatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        location: LocationRef.fromJson(json['location']),
        subpath: json['subpath'] == null
            ? null
            : RelativePath.fromJson(asJsonString(json['subpath'])),
        parentID: json['parentID'] == null
            ? null
            : SessionID.fromJson(asJsonString(json['parentID'])),
        slug: decodeString(json, 'slug'),
        title: decodeOptionalString(json, 'title'),
        agent: json['agent'] == null
            ? null
            : AgentID.fromJson(asJsonString(json['agent'])),
        model: json['model'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['model'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        permissions: json['permissions'] == null
            ? null
            : jsonList(json['permissions'],
                (item) => PermissionRule.fromJson(asJsonMap(item))),
        version: decodeString(json, 'version'),
      );

  final SessionID sessionID;
  final ProjectID projectID;
  final LocationRef location;
  final RelativePath? subpath;
  final SessionID? parentID;
  final String slug;
  final String? title;
  final AgentID? agent;
  final ModelRef? model;
  final Map<String, Object?>? metadata;
  final List<PermissionRule>? permissions;
  final String version;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'projectID': projectID,
        'location': location.toJson(),
        if (subpath != null) 'subpath': subpath!,
        if (parentID != null) 'parentID': parentID!,
        'slug': slug,
        if (title != null) 'title': title!,
        if (agent != null) 'agent': agent!,
        if (model != null) 'model': model!.toJson(),
        if (metadata != null) 'metadata': metadata!,
        if (permissions != null)
          'permissions': [for (final item in permissions!) item.toJson()],
        'version': version,
      };
}

/// `SessionAgentSelectedDurable`
final class SessionAgentSelectedDurable {
  const SessionAgentSelectedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionAgentSelectedDurable.fromJson(Map<String, Object?> json) =>
      SessionAgentSelectedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionAgentSelectedData`
final class SessionAgentSelectedData {
  const SessionAgentSelectedData({
    required this.sessionID,
    required this.agent,
    this.previous,
  });

  factory SessionAgentSelectedData.fromJson(Map<String, Object?> json) =>
      SessionAgentSelectedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        agent: AgentID.fromJson(asJsonString(json['agent'])),
        previous: json['previous'] == null
            ? null
            : AgentID.fromJson(asJsonString(json['previous'])),
      );

  final SessionID sessionID;
  final AgentID agent;
  final AgentID? previous;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'agent': agent,
        if (previous != null) 'previous': previous!,
      };
}

/// `SessionModelSelectedDurable`
final class SessionModelSelectedDurable {
  const SessionModelSelectedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionModelSelectedDurable.fromJson(Map<String, Object?> json) =>
      SessionModelSelectedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionModelSelectedData`
final class SessionModelSelectedData {
  const SessionModelSelectedData({
    required this.sessionID,
    required this.model,
    this.previous,
  });

  factory SessionModelSelectedData.fromJson(Map<String, Object?> json) =>
      SessionModelSelectedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        previous: json['previous'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['previous'])),
      );

  final SessionID sessionID;
  final ModelRef model;
  final ModelRef? previous;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'model': model.toJson(),
        if (previous != null) 'previous': previous!.toJson(),
      };
}

/// `SessionMovedDurable`
final class SessionMovedDurable {
  const SessionMovedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionMovedDurable.fromJson(Map<String, Object?> json) =>
      SessionMovedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionMovedData`
final class SessionMovedData {
  const SessionMovedData({
    required this.sessionID,
    required this.location,
    required this.projectID,
    this.subpath,
  });

  factory SessionMovedData.fromJson(Map<String, Object?> json) =>
      SessionMovedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        location: LocationRef.fromJson(json['location']),
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        subpath: json['subpath'] == null
            ? null
            : RelativePath.fromJson(asJsonString(json['subpath'])),
      );

  final SessionID sessionID;
  final LocationRef location;
  final ProjectID projectID;
  final RelativePath? subpath;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'location': location.toJson(),
        'projectID': projectID,
        if (subpath != null) 'subpath': subpath!,
      };
}

/// `SessionRenamedDurable`
final class SessionRenamedDurable {
  const SessionRenamedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionRenamedDurable.fromJson(Map<String, Object?> json) =>
      SessionRenamedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionRenamedData`
final class SessionRenamedData {
  const SessionRenamedData({
    required this.sessionID,
    required this.title,
  });

  factory SessionRenamedData.fromJson(Map<String, Object?> json) =>
      SessionRenamedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        title: decodeString(json, 'title'),
      );

  final SessionID sessionID;
  final String title;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'title': title,
      };
}

/// `SessionMetadataUpdatedDurable`
final class SessionMetadataUpdatedDurable {
  const SessionMetadataUpdatedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionMetadataUpdatedDurable.fromJson(Map<String, Object?> json) =>
      SessionMetadataUpdatedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionMetadataUpdatedData`
final class SessionMetadataUpdatedData {
  const SessionMetadataUpdatedData({
    required this.sessionID,
    required this.metadata,
  });

  factory SessionMetadataUpdatedData.fromJson(Map<String, Object?> json) =>
      SessionMetadataUpdatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        metadata: asJsonMap(json['metadata']),
      );

  final SessionID sessionID;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'metadata': metadata,
      };
}

/// `SessionPermissionsDurable`
final class SessionPermissionsDurable {
  const SessionPermissionsDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionPermissionsDurable.fromJson(Map<String, Object?> json) =>
      SessionPermissionsDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionPermissionsData`
final class SessionPermissionsData {
  const SessionPermissionsData({
    required this.sessionID,
    required this.permissions,
  });

  factory SessionPermissionsData.fromJson(Map<String, Object?> json) =>
      SessionPermissionsData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        permissions: jsonList(json['permissions'],
            (item) => PermissionRule.fromJson(asJsonMap(item))),
      );

  final SessionID sessionID;
  final List<PermissionRule> permissions;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'permissions': [for (final item in permissions) item.toJson()],
      };
}

/// `SessionViewedDurable`
final class SessionViewedDurable {
  const SessionViewedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionViewedDurable.fromJson(Map<String, Object?> json) =>
      SessionViewedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionViewedData`
final class SessionViewedData {
  const SessionViewedData({
    required this.sessionID,
    required this.idle,
  });

  factory SessionViewedData.fromJson(Map<String, Object?> json) =>
      SessionViewedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        idle: decodeNumber(json, 'idle'),
      );

  final SessionID sessionID;
  final double idle;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'idle': idle,
      };
}

/// `SessionArchivedDurable`
final class SessionArchivedDurable {
  const SessionArchivedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionArchivedDurable.fromJson(Map<String, Object?> json) =>
      SessionArchivedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionArchivedData`
final class SessionArchivedData {
  const SessionArchivedData({
    required this.sessionID,
  });

  factory SessionArchivedData.fromJson(Map<String, Object?> json) =>
      SessionArchivedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionUnarchivedDurable`
final class SessionUnarchivedDurable {
  const SessionUnarchivedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionUnarchivedDurable.fromJson(Map<String, Object?> json) =>
      SessionUnarchivedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionUnarchivedData`
final class SessionUnarchivedData {
  const SessionUnarchivedData({
    required this.sessionID,
  });

  factory SessionUnarchivedData.fromJson(Map<String, Object?> json) =>
      SessionUnarchivedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionDeletedDurable`
final class SessionDeletedDurable {
  const SessionDeletedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionDeletedDurable.fromJson(Map<String, Object?> json) =>
      SessionDeletedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC3ea984aceae.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC3ea984aceae version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionDeletedData`
final class SessionDeletedData {
  const SessionDeletedData({
    required this.sessionID,
  });

  factory SessionDeletedData.fromJson(Map<String, Object?> json) =>
      SessionDeletedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionForkedDurable`
final class SessionForkedDurable {
  const SessionForkedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionForkedDurable.fromJson(Map<String, Object?> json) =>
      SessionForkedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC3ea984aceae.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC3ea984aceae version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionForkedData`
final class SessionForkedData {
  const SessionForkedData({
    required this.sessionID,
    required this.parentID,
    required this.boundary,
    this.instructions,
    this.instructionEntries,
  });

  factory SessionForkedData.fromJson(Map<String, Object?> json) =>
      SessionForkedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        parentID: SessionID.fromJson(asJsonString(json['parentID'])),
        boundary: SessionForkBoundary.fromJson(asJsonMap(json['boundary'])),
        instructions: json['instructions'] == null
            ? null
            : jsonMap(json['instructions'],
                (item) => InstructionHash.fromJson(asJsonString(item))),
        instructionEntries: json['instructionEntries'] == null
            ? null
            : jsonList(json['instructionEntries'],
                (item) => InstructionEntrySnapshot2.fromJson(asJsonMap(item))),
      );

  final SessionID sessionID;
  final SessionID parentID;
  final SessionForkBoundary boundary;
  final Map<String, InstructionHash>? instructions;
  final List<InstructionEntrySnapshot2>? instructionEntries;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'parentID': parentID,
        'boundary': boundary.toJson(),
        if (instructions != null) 'instructions': instructions!,
        if (instructionEntries != null)
          'instructionEntries': [
            for (final item in instructionEntries!) item.toJson()
          ],
      };
}

/// `SessionInboxDeliveredDurable`
final class SessionInboxDeliveredDurable {
  const SessionInboxDeliveredDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionInboxDeliveredDurable.fromJson(Map<String, Object?> json) =>
      SessionInboxDeliveredDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionInboxDeliveredData`
final class SessionInboxDeliveredData {
  const SessionInboxDeliveredData({
    required this.sessionID,
    required this.inboxID,
  });

  factory SessionInboxDeliveredData.fromJson(Map<String, Object?> json) =>
      SessionInboxDeliveredData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        inboxID: SessionMessageID.fromJson(asJsonString(json['inboxID'])),
      );

  final SessionID sessionID;
  final SessionMessageID inboxID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'inboxID': inboxID,
      };
}

/// `SessionInboxEnqueuedDurable`
final class SessionInboxEnqueuedDurable {
  const SessionInboxEnqueuedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionInboxEnqueuedDurable.fromJson(Map<String, Object?> json) =>
      SessionInboxEnqueuedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionInboxEnqueuedData`
final class SessionInboxEnqueuedData {
  const SessionInboxEnqueuedData({
    required this.sessionID,
    required this.inboxID,
    required this.item,
  });

  factory SessionInboxEnqueuedData.fromJson(Map<String, Object?> json) =>
      SessionInboxEnqueuedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        inboxID: SessionMessageID.fromJson(asJsonString(json['inboxID'])),
        item: SessionInboxItem.fromJson(asJsonMap(json['item'])),
      );

  final SessionID sessionID;
  final SessionMessageID inboxID;
  final SessionInboxItem item;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'inboxID': inboxID,
        'item': item.toJson(),
      };
}

/// `SessionInboxCancelledDurable`
final class SessionInboxCancelledDurable {
  const SessionInboxCancelledDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionInboxCancelledDurable.fromJson(Map<String, Object?> json) =>
      SessionInboxCancelledDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionInboxCancelledData`
final class SessionInboxCancelledData {
  const SessionInboxCancelledData({
    required this.sessionID,
    required this.inboxID,
  });

  factory SessionInboxCancelledData.fromJson(Map<String, Object?> json) =>
      SessionInboxCancelledData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        inboxID: SessionMessageID.fromJson(asJsonString(json['inboxID'])),
      );

  final SessionID sessionID;
  final SessionMessageID inboxID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'inboxID': inboxID,
      };
}

/// `SessionInboxDeliveryChangedDurable`
final class SessionInboxDeliveryChangedDurable {
  const SessionInboxDeliveryChangedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionInboxDeliveryChangedDurable.fromJson(
          Map<String, Object?> json) =>
      SessionInboxDeliveryChangedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionInboxDeliveryChangedData`
final class SessionInboxDeliveryChangedData {
  const SessionInboxDeliveryChangedData({
    required this.sessionID,
    required this.inboxID,
    required this.delivery,
  });

  factory SessionInboxDeliveryChangedData.fromJson(Map<String, Object?> json) =>
      SessionInboxDeliveryChangedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        inboxID: SessionMessageID.fromJson(asJsonString(json['inboxID'])),
        delivery: SessionInboxDelivery.fromJson(json['delivery']),
      );

  final SessionID sessionID;
  final SessionMessageID inboxID;
  final SessionInboxDelivery delivery;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'inboxID': inboxID,
        'delivery': delivery.wire,
      };
}

/// `SessionExecutionStartedDurable`
final class SessionExecutionStartedDurable {
  const SessionExecutionStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionExecutionStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionExecutionStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionExecutionStartedData`
final class SessionExecutionStartedData {
  const SessionExecutionStartedData({
    required this.sessionID,
  });

  factory SessionExecutionStartedData.fromJson(Map<String, Object?> json) =>
      SessionExecutionStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionExecutionSucceededDurable`
final class SessionExecutionSucceededDurable {
  const SessionExecutionSucceededDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionExecutionSucceededDurable.fromJson(
          Map<String, Object?> json) =>
      SessionExecutionSucceededDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionExecutionSucceededData`
final class SessionExecutionSucceededData {
  const SessionExecutionSucceededData({
    required this.sessionID,
  });

  factory SessionExecutionSucceededData.fromJson(Map<String, Object?> json) =>
      SessionExecutionSucceededData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionExecutionFailedDurable`
final class SessionExecutionFailedDurable {
  const SessionExecutionFailedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionExecutionFailedDurable.fromJson(Map<String, Object?> json) =>
      SessionExecutionFailedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
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

/// `SessionExecutionFailedData`
final class SessionExecutionFailedData {
  const SessionExecutionFailedData({
    required this.sessionID,
    required this.error,
  });

  factory SessionExecutionFailedData.fromJson(Map<String, Object?> json) =>
      SessionExecutionFailedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
      );

  final SessionID sessionID;
  final SessionStructuredError error;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'error': error.toJson(),
      };
}

/// `SessionExecutionInterruptedDurable`
final class SessionExecutionInterruptedDurable {
  const SessionExecutionInterruptedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionExecutionInterruptedDurable.fromJson(
          Map<String, Object?> json) =>
      SessionExecutionInterruptedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionExecutionInterruptedData`
final class SessionExecutionInterruptedData {
  const SessionExecutionInterruptedData({
    required this.sessionID,
    required this.reason,
  });

  factory SessionExecutionInterruptedData.fromJson(Map<String, Object?> json) =>
      SessionExecutionInterruptedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        reason: SessionExecutionInterruptedDataReason.fromJson(json['reason']),
      );

  final SessionID sessionID;
  final SessionExecutionInterruptedDataReason reason;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'reason': reason.wire,
      };
}

/// `SessionInstructionsUpdatedDurable`
final class SessionInstructionsUpdatedDurable {
  const SessionInstructionsUpdatedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionInstructionsUpdatedDurable.fromJson(
          Map<String, Object?> json) =>
      SessionInstructionsUpdatedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC3ea984aceae.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC3ea984aceae version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionInstructionsUpdatedData`
final class SessionInstructionsUpdatedData {
  const SessionInstructionsUpdatedData({
    required this.sessionID,
    required this.delta,
    this.text,
  });

  factory SessionInstructionsUpdatedData.fromJson(Map<String, Object?> json) =>
      SessionInstructionsUpdatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        delta: asJsonMap(json['delta']),
        text: decodeOptionalString(json, 'text'),
      );

  final SessionID sessionID;
  final Map<String, Object?> delta;
  final String? text;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'delta': delta,
        if (text != null) 'text': text!,
      };
}

/// `SessionSyntheticDurable`
final class SessionSyntheticDurable {
  const SessionSyntheticDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionSyntheticDurable.fromJson(Map<String, Object?> json) =>
      SessionSyntheticDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionSyntheticData`
final class SessionSyntheticData {
  const SessionSyntheticData({
    required this.sessionID,
    required this.text,
    this.description,
    this.metadata,
  });

  factory SessionSyntheticData.fromJson(Map<String, Object?> json) =>
      SessionSyntheticData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        text: decodeString(json, 'text'),
        description: decodeOptionalString(json, 'description'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final SessionID sessionID;
  final String text;
  final String? description;
  final Map<String, Object?>? metadata;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'text': text,
        if (description != null) 'description': description!,
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `SessionSkillActivatedDurable`
final class SessionSkillActivatedDurable {
  const SessionSkillActivatedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionSkillActivatedDurable.fromJson(Map<String, Object?> json) =>
      SessionSkillActivatedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionSkillActivatedData`
final class SessionSkillActivatedData {
  const SessionSkillActivatedData({
    required this.sessionID,
    required this.id,
    required this.name,
    required this.text,
  });

  factory SessionSkillActivatedData.fromJson(Map<String, Object?> json) =>
      SessionSkillActivatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        id: SkillID.fromJson(asJsonString(json['id'])),
        name: SkillName.fromJson(asJsonString(json['name'])),
        text: decodeString(json, 'text'),
      );

  final SessionID sessionID;
  final SkillID id;
  final SkillName name;
  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'id': id,
        'name': name,
        'text': text,
      };
}

/// `SessionShellStartedDurable`
final class SessionShellStartedDurable {
  const SessionShellStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionShellStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionShellStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
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

/// `SessionShellStartedData`
final class SessionShellStartedData {
  const SessionShellStartedData({
    required this.sessionID,
    required this.shell,
  });

  factory SessionShellStartedData.fromJson(Map<String, Object?> json) =>
      SessionShellStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        shell: ShellInfo.fromJson(asJsonMap(json['shell'])),
      );

  final SessionID sessionID;
  final ShellInfo shell;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'shell': shell.toJson(),
      };
}

/// `SessionShellEndedDurable`
final class SessionShellEndedDurable {
  const SessionShellEndedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionShellEndedDurable.fromJson(Map<String, Object?> json) =>
      SessionShellEndedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionShellEndedDataOutput`
final class SessionShellEndedDataOutput {
  const SessionShellEndedDataOutput({
    required this.output,
    required this.cursor,
    required this.size,
    required this.truncated,
  });

  factory SessionShellEndedDataOutput.fromJson(Map<String, Object?> json) =>
      SessionShellEndedDataOutput(
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

/// `SessionShellEndedData`
final class SessionShellEndedData {
  const SessionShellEndedData({
    required this.sessionID,
    required this.shell,
    required this.output,
  });

  factory SessionShellEndedData.fromJson(Map<String, Object?> json) =>
      SessionShellEndedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        shell: ShellInfo.fromJson(asJsonMap(json['shell'])),
        output: SessionShellEndedDataOutput.fromJson(asJsonMap(json['output'])),
      );

  final SessionID sessionID;
  final ShellInfo shell;
  final SessionShellEndedDataOutput output;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'shell': shell.toJson(),
        'output': output.toJson(),
      };
}

/// `SessionStepStartedDurable`
final class SessionStepStartedDurable {
  const SessionStepStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionStepStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionStepStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionStepStartedData`
final class SessionStepStartedData {
  const SessionStepStartedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.agent,
    required this.model,
    this.snapshot,
    required this.started,
  });

  factory SessionStepStartedData.fromJson(Map<String, Object?> json) =>
      SessionStepStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        agent: AgentID.fromJson(asJsonString(json['agent'])),
        model: ModelRef.fromJson(asJsonMap(json['model'])),
        snapshot: json['snapshot'] == null
            ? null
            : SnapshotID.fromJson(asJsonString(json['snapshot'])),
        started: decodeInt(json, 'started'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final AgentID agent;
  final ModelRef model;
  final SnapshotID? snapshot;
  final int started;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'agent': agent,
        'model': model.toJson(),
        if (snapshot != null) 'snapshot': snapshot!,
        'started': started,
      };
}

/// `SessionStepFirstTokenDurable`
final class SessionStepFirstTokenDurable {
  const SessionStepFirstTokenDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionStepFirstTokenDurable.fromJson(Map<String, Object?> json) =>
      SessionStepFirstTokenDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionStepFirstTokenData`
final class SessionStepFirstTokenData {
  const SessionStepFirstTokenData({
    required this.sessionID,
    required this.assistantMessageID,
  });

  factory SessionStepFirstTokenData.fromJson(Map<String, Object?> json) =>
      SessionStepFirstTokenData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
      };
}

/// `SessionStepStreamedDurable`
final class SessionStepStreamedDurable {
  const SessionStepStreamedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionStepStreamedDurable.fromJson(Map<String, Object?> json) =>
      SessionStepStreamedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionStepStreamedData`
final class SessionStepStreamedData {
  const SessionStepStreamedData({
    required this.sessionID,
    required this.assistantMessageID,
  });

  factory SessionStepStreamedData.fromJson(Map<String, Object?> json) =>
      SessionStepStreamedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
      };
}

/// `SessionStepEndedDurable`
final class SessionStepEndedDurable {
  const SessionStepEndedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionStepEndedDurable.fromJson(Map<String, Object?> json) =>
      SessionStepEndedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
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

/// `SessionStepEndedData`
final class SessionStepEndedData {
  const SessionStepEndedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.finish,
    this.rawFinish,
    this.native,
    required this.cost,
    required this.tokens,
    this.snapshot,
    this.files,
  });

  factory SessionStepEndedData.fromJson(Map<String, Object?> json) =>
      SessionStepEndedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        finish: SessionStepEndedDataFinish.fromJson(json['finish']),
        rawFinish: decodeOptionalString(json, 'rawFinish'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        snapshot: json['snapshot'] == null
            ? null
            : SnapshotID.fromJson(asJsonString(json['snapshot'])),
        files: json['files'] == null
            ? null
            : jsonList(json['files'],
                (item) => RelativePath.fromJson(asJsonString(item))),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final SessionStepEndedDataFinish finish;
  final String? rawFinish;
  final Map<String, Object?>? native;
  final MoneyUSD cost;
  final TokenUsageInfo tokens;
  final SnapshotID? snapshot;
  final List<RelativePath>? files;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'finish': finish.wire,
        if (rawFinish != null) 'rawFinish': rawFinish!,
        if (native != null) 'native': native!,
        'cost': cost,
        'tokens': tokens.toJson(),
        if (snapshot != null) 'snapshot': snapshot!,
        if (files != null) 'files': files!,
      };
}

/// `SessionStepFailedDurable`
final class SessionStepFailedDurable {
  const SessionStepFailedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionStepFailedDurable.fromJson(Map<String, Object?> json) =>
      SessionStepFailedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionStepFailedData`
final class SessionStepFailedData {
  const SessionStepFailedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.error,
    this.rawFinish,
    this.native,
    this.cost,
    this.tokens,
    this.snapshot,
    this.files,
  });

  factory SessionStepFailedData.fromJson(Map<String, Object?> json) =>
      SessionStepFailedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
        rawFinish: decodeOptionalString(json, 'rawFinish'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        snapshot: json['snapshot'] == null
            ? null
            : SnapshotID.fromJson(asJsonString(json['snapshot'])),
        files: json['files'] == null
            ? null
            : jsonList(json['files'],
                (item) => RelativePath.fromJson(asJsonString(item))),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final SessionStructuredError error;
  final String? rawFinish;
  final Map<String, Object?>? native;
  final MoneyUSD? cost;
  final TokenUsageInfo? tokens;
  final SnapshotID? snapshot;
  final List<RelativePath>? files;

  /// Always `content-filter`.
  String get finish => 'content-filter';

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'error': error.toJson(),
        'finish': 'content-filter',
        if (rawFinish != null) 'rawFinish': rawFinish!,
        if (native != null) 'native': native!,
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
        if (snapshot != null) 'snapshot': snapshot!,
        if (files != null) 'files': files!,
      };
}

/// `SessionTextStartedDurable`
final class SessionTextStartedDurable {
  const SessionTextStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionTextStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionTextStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionTextStartedData`
final class SessionTextStartedData {
  const SessionTextStartedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.ordinal,
  });

  factory SessionTextStartedData.fromJson(Map<String, Object?> json) =>
      SessionTextStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        ordinal: decodeInt(json, 'ordinal'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int ordinal;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'ordinal': ordinal,
      };
}

/// `SessionTextEndedDurable`
final class SessionTextEndedDurable {
  const SessionTextEndedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionTextEndedDurable.fromJson(Map<String, Object?> json) =>
      SessionTextEndedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionTextEndedData`
final class SessionTextEndedData {
  const SessionTextEndedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.ordinal,
    required this.text,
    this.native,
  });

  factory SessionTextEndedData.fromJson(Map<String, Object?> json) =>
      SessionTextEndedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        ordinal: decodeInt(json, 'ordinal'),
        text: decodeString(json, 'text'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int ordinal;
  final String text;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'ordinal': ordinal,
        'text': text,
        if (native != null) 'native': native!,
      };
}

/// `SessionReasoningStartedDurable`
final class SessionReasoningStartedDurable {
  const SessionReasoningStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionReasoningStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionReasoningStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionReasoningStartedData`
final class SessionReasoningStartedData {
  const SessionReasoningStartedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.ordinal,
    this.native,
  });

  factory SessionReasoningStartedData.fromJson(Map<String, Object?> json) =>
      SessionReasoningStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        ordinal: decodeInt(json, 'ordinal'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int ordinal;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'ordinal': ordinal,
        if (native != null) 'native': native!,
      };
}

/// `SessionReasoningEndedDurable`
final class SessionReasoningEndedDurable {
  const SessionReasoningEndedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionReasoningEndedDurable.fromJson(Map<String, Object?> json) =>
      SessionReasoningEndedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionReasoningEndedData`
final class SessionReasoningEndedData {
  const SessionReasoningEndedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.ordinal,
    required this.text,
    this.native,
  });

  factory SessionReasoningEndedData.fromJson(Map<String, Object?> json) =>
      SessionReasoningEndedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        ordinal: decodeInt(json, 'ordinal'),
        text: decodeString(json, 'text'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int ordinal;
  final String text;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'ordinal': ordinal,
        'text': text,
        if (native != null) 'native': native!,
      };
}

/// `SessionToolInputStartedDurable`
final class SessionToolInputStartedDurable {
  const SessionToolInputStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionToolInputStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionToolInputStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionToolInputStartedData`
final class SessionToolInputStartedData {
  const SessionToolInputStartedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.name,
  });

  factory SessionToolInputStartedData.fromJson(Map<String, Object?> json) =>
      SessionToolInputStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        name: decodeString(json, 'name'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final String name;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'name': name,
      };
}

/// `SessionToolInputEndedDurable`
final class SessionToolInputEndedDurable {
  const SessionToolInputEndedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionToolInputEndedDurable.fromJson(Map<String, Object?> json) =>
      SessionToolInputEndedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionToolInputEndedData`
final class SessionToolInputEndedData {
  const SessionToolInputEndedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.text,
  });

  factory SessionToolInputEndedData.fromJson(Map<String, Object?> json) =>
      SessionToolInputEndedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        text: decodeString(json, 'text'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'text': text,
      };
}

/// `SessionToolCalledDurable`
final class SessionToolCalledDurable {
  const SessionToolCalledDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionToolCalledDurable.fromJson(Map<String, Object?> json) =>
      SessionToolCalledDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionToolCalledData`
final class SessionToolCalledData {
  const SessionToolCalledData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.input,
    required this.executed,
    this.native,
  });

  factory SessionToolCalledData.fromJson(Map<String, Object?> json) =>
      SessionToolCalledData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        input: asJsonMap(json['input']),
        executed: decodeBool(json, 'executed'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final Map<String, Object?> input;
  final bool executed;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'input': input,
        'executed': executed,
        if (native != null) 'native': native!,
      };
}

/// `SessionToolSuccessDurable`
final class SessionToolSuccessDurable {
  const SessionToolSuccessDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionToolSuccessDurable.fromJson(Map<String, Object?> json) =>
      SessionToolSuccessDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC3ea984aceae.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC3ea984aceae version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionToolSuccessData`
final class SessionToolSuccessData {
  const SessionToolSuccessData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.content,
    this.metadata,
    required this.executed,
    this.native,
  });

  factory SessionToolSuccessData.fromJson(Map<String, Object?> json) =>
      SessionToolSuccessData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        content: jsonList(
            json['content'], (item) => ToolContent.fromJson(asJsonMap(item))),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        executed: decodeBool(json, 'executed'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final List<ToolContent> content;
  final Map<String, Object?>? metadata;
  final bool executed;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'content': [for (final item in content) item.toJson()],
        if (metadata != null) 'metadata': metadata!,
        'executed': executed,
        if (native != null) 'native': native!,
      };
}

/// `SessionToolFailedDurable`
final class SessionToolFailedDurable {
  const SessionToolFailedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionToolFailedDurable.fromJson(Map<String, Object?> json) =>
      SessionToolFailedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC3ea984aceae.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC3ea984aceae version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionToolFailedData`
final class SessionToolFailedData {
  const SessionToolFailedData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.error,
    this.content,
    this.metadata,
    required this.executed,
    this.native,
  });

  factory SessionToolFailedData.fromJson(Map<String, Object?> json) =>
      SessionToolFailedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
        content: json['content'] == null
            ? null
            : jsonList(json['content'],
                (item) => ToolContent.fromJson(asJsonMap(item))),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        executed: decodeBool(json, 'executed'),
        native: json['native'] == null ? null : asJsonMap(json['native']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final SessionStructuredError error;
  final List<ToolContent>? content;
  final Map<String, Object?>? metadata;
  final bool executed;
  final Map<String, Object?>? native;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'error': error.toJson(),
        if (content != null)
          'content': [for (final item in content!) item.toJson()],
        if (metadata != null) 'metadata': metadata!,
        'executed': executed,
        if (native != null) 'native': native!,
      };
}

/// `SessionRetryScheduledDurable`
final class SessionRetryScheduledDurable {
  const SessionRetryScheduledDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionRetryScheduledDurable.fromJson(Map<String, Object?> json) =>
      SessionRetryScheduledDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionRetryScheduledData`
final class SessionRetryScheduledData {
  const SessionRetryScheduledData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.attempt,
    required this.at,
    required this.error,
  });

  factory SessionRetryScheduledData.fromJson(Map<String, Object?> json) =>
      SessionRetryScheduledData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        attempt: decodeInt(json, 'attempt'),
        at: decodeInt(json, 'at'),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int attempt;
  final int at;
  final SessionStructuredError error;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'attempt': attempt,
        'at': at,
        'error': error.toJson(),
      };
}

/// `SessionCompactionStartedDurable`
final class SessionCompactionStartedDurable {
  const SessionCompactionStartedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionCompactionStartedDurable.fromJson(Map<String, Object?> json) =>
      SessionCompactionStartedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionCompactionStartedData`
final class SessionCompactionStartedData {
  const SessionCompactionStartedData({
    required this.sessionID,
    required this.reason,
    this.inputID,
  });

  factory SessionCompactionStartedData.fromJson(Map<String, Object?> json) =>
      SessionCompactionStartedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        reason: SessionCompactionStartedDataReason.fromJson(json['reason']),
        inputID: json['inputID'] == null
            ? null
            : SessionMessageID.fromJson(asJsonString(json['inputID'])),
      );

  final SessionID sessionID;
  final SessionCompactionStartedDataReason reason;
  final SessionMessageID? inputID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'reason': reason.wire,
        if (inputID != null) 'inputID': inputID!,
      };
}

/// `SessionCompactionEndedDurable`
final class SessionCompactionEndedDurable {
  const SessionCompactionEndedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionCompactionEndedDurable.fromJson(Map<String, Object?> json) =>
      SessionCompactionEndedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionCompactionEndedData`
final class SessionCompactionEndedData {
  const SessionCompactionEndedData({
    required this.sessionID,
    required this.reason,
    this.model,
    this.native,
    required this.text,
    this.cost,
    this.tokens,
  });

  factory SessionCompactionEndedData.fromJson(Map<String, Object?> json) =>
      SessionCompactionEndedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        reason: SessionCompactionEndedDataReason.fromJson(json['reason']),
        model: json['model'] == null
            ? null
            : ModelRef.fromJson(asJsonMap(json['model'])),
        native: json['native'] == null ? null : asJsonMap(json['native']),
        text: decodeString(json, 'text'),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
      );

  final SessionID sessionID;
  final SessionCompactionEndedDataReason reason;
  final ModelRef? model;
  final Map<String, Object?>? native;
  final String text;
  final MoneyUSD? cost;
  final TokenUsageInfo? tokens;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'reason': reason.wire,
        if (model != null) 'model': model!.toJson(),
        if (native != null) 'native': native!,
        'text': text,
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
      };
}

/// `SessionCompactionFailedDurable`
final class SessionCompactionFailedDurable {
  const SessionCompactionFailedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionCompactionFailedDurable.fromJson(Map<String, Object?> json) =>
      SessionCompactionFailedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionCompactionFailedData`
final class SessionCompactionFailedData {
  const SessionCompactionFailedData({
    required this.sessionID,
    required this.reason,
    required this.error,
    this.inputID,
    this.cost,
    this.tokens,
  });

  factory SessionCompactionFailedData.fromJson(Map<String, Object?> json) =>
      SessionCompactionFailedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        reason: SessionCompactionFailedDataReason.fromJson(json['reason']),
        error: SessionStructuredError.fromJson(asJsonMap(json['error'])),
        inputID: json['inputID'] == null
            ? null
            : SessionMessageID.fromJson(asJsonString(json['inputID'])),
        cost: json['cost'] == null
            ? null
            : MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: json['tokens'] == null
            ? null
            : TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
      );

  final SessionID sessionID;
  final SessionCompactionFailedDataReason reason;
  final SessionStructuredError error;
  final SessionMessageID? inputID;
  final MoneyUSD? cost;
  final TokenUsageInfo? tokens;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'reason': reason.wire,
        'error': error.toJson(),
        if (inputID != null) 'inputID': inputID!,
        if (cost != null) 'cost': cost!,
        if (tokens != null) 'tokens': tokens!.toJson(),
      };
}

/// `SessionRevertStagedDurable`
final class SessionRevertStagedDurable {
  const SessionRevertStagedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionRevertStagedDurable.fromJson(Map<String, Object?> json) =>
      SessionRevertStagedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionRevertStagedData`
final class SessionRevertStagedData {
  const SessionRevertStagedData({
    required this.sessionID,
    required this.revert,
  });

  factory SessionRevertStagedData.fromJson(Map<String, Object?> json) =>
      SessionRevertStagedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        revert: SessionRevert.fromJson(asJsonMap(json['revert'])),
      );

  final SessionID sessionID;
  final SessionRevert revert;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'revert': revert.toJson(),
      };
}

/// `SessionRevertClearedDurable`
final class SessionRevertClearedDurable {
  const SessionRevertClearedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionRevertClearedDurable.fromJson(Map<String, Object?> json) =>
      SessionRevertClearedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionRevertClearedData`
final class SessionRevertClearedData {
  const SessionRevertClearedData({
    required this.sessionID,
  });

  factory SessionRevertClearedData.fromJson(Map<String, Object?> json) =>
      SessionRevertClearedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionRevertCommittedDurable`
final class SessionRevertCommittedDurable {
  const SessionRevertCommittedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionRevertCommittedDurable.fromJson(Map<String, Object?> json) =>
      SessionRevertCommittedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionRevertCommittedData`
final class SessionRevertCommittedData {
  const SessionRevertCommittedData({
    required this.sessionID,
    required this.to,
  });

  factory SessionRevertCommittedData.fromJson(Map<String, Object?> json) =>
      SessionRevertCommittedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        to: SessionMessageID.fromJson(asJsonString(json['to'])),
      );

  final SessionID sessionID;
  final SessionMessageID to;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'to': to,
      };
}

/// `SessionUsageRecordedDurable`
final class SessionUsageRecordedDurable {
  const SessionUsageRecordedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionUsageRecordedDurable.fromJson(Map<String, Object?> json) =>
      SessionUsageRecordedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `SessionUsageRecordedData`
final class SessionUsageRecordedData {
  const SessionUsageRecordedData({
    required this.sessionID,
    required this.source,
    required this.cost,
    required this.tokens,
  });

  factory SessionUsageRecordedData.fromJson(Map<String, Object?> json) =>
      SessionUsageRecordedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        source: SessionUsageRecordedDataSource.fromJson(json['source']),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
      );

  final SessionID sessionID;
  final SessionUsageRecordedDataSource source;
  final MoneyUSD cost;
  final TokenUsageInfo tokens;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'source': source.wire,
        'cost': cost,
        'tokens': tokens.toJson(),
      };
}

/// `SessionMessageContentUpdatedDurable`
final class SessionMessageContentUpdatedDurable {
  const SessionMessageContentUpdatedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory SessionMessageContentUpdatedDurable.fromJson(
          Map<String, Object?> json) =>
      SessionMessageContentUpdatedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
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

/// `SessionMessageContentUpdatedData`
final class SessionMessageContentUpdatedData {
  const SessionMessageContentUpdatedData({
    required this.sessionID,
    required this.messageID,
    required this.content,
  });

  factory SessionMessageContentUpdatedData.fromJson(
          Map<String, Object?> json) =>
      SessionMessageContentUpdatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        messageID: SessionMessageID.fromJson(asJsonString(json['messageID'])),
        content: jsonList(
            json['content'],
            (item) => SessionMessageAssistantContentEncoded.fromJson(
                asJsonMap(item))),
      );

  final SessionID sessionID;
  final SessionMessageID messageID;
  final List<SessionMessageAssistantContentEncoded> content;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'messageID': messageID,
        'content': [for (final item in content) item.toJson()],
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

/// `SessionInfoTime`
final class SessionInfoTime {
  const SessionInfoTime({
    required this.created,
    required this.updated,
    this.busy,
    this.idle,
    this.viewed,
    this.archived,
  });

  factory SessionInfoTime.fromJson(Map<String, Object?> json) =>
      SessionInfoTime(
        created: decodeNumber(json, 'created'),
        updated: decodeNumber(json, 'updated'),
        busy: decodeOptionalNumber(json, 'busy'),
        idle: decodeOptionalNumber(json, 'idle'),
        viewed: decodeOptionalNumber(json, 'viewed'),
        archived: decodeOptionalNumber(json, 'archived'),
      );

  final double created;
  final double updated;
  final double? busy;
  final double? idle;
  final double? viewed;
  final double? archived;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        'updated': updated,
        if (busy != null) 'busy': busy!,
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
    this.firstToken,
    this.streamed,
    this.completed,
  });

  factory SessionMessageAssistantTime.fromJson(Map<String, Object?> json) =>
      SessionMessageAssistantTime(
        created: decodeNumber(json, 'created'),
        firstToken: decodeOptionalNumber(json, 'firstToken'),
        streamed: decodeOptionalNumber(json, 'streamed'),
        completed: decodeOptionalNumber(json, 'completed'),
      );

  final double created;
  final double? firstToken;
  final double? streamed;
  final double? completed;

  Map<String, Object?> toJson() => <String, Object?>{
        'created': created,
        if (firstToken != null) 'firstToken': firstToken!,
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

  /// Present on every variant (`native`).
  Map<String, Object?>? get native;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
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
    required this.tokens,
    required this.cost,
  });

  factory SessionGenerateResponseData.fromJson(Map<String, Object?> json) =>
      SessionGenerateResponseData(
        text: decodeString(json, 'text'),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
      );

  final String text;
  final TokenUsageInfo tokens;
  final MoneyUSD cost;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
        'tokens': tokens.toJson(),
        'cost': cost,
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

/// `SessionStatusRetryAction`
final class SessionStatusRetryAction {
  const SessionStatusRetryAction({
    required this.reason,
    required this.provider,
    required this.title,
    required this.message,
    required this.label,
    this.link,
  });

  factory SessionStatusRetryAction.fromJson(Map<String, Object?> json) =>
      SessionStatusRetryAction(
        reason: decodeString(json, 'reason'),
        provider: decodeString(json, 'provider'),
        title: decodeString(json, 'title'),
        message: decodeString(json, 'message'),
        label: decodeString(json, 'label'),
        link: decodeOptionalString(json, 'link'),
      );

  final String reason;
  final String provider;
  final String title;
  final String message;
  final String label;
  final String? link;

  Map<String, Object?> toJson() => <String, Object?>{
        'reason': reason,
        'provider': provider,
        'title': title,
        'message': message,
        'label': label,
        if (link != null) 'link': link!,
      };
}

/// `SessionStatusUpdatedData`
final class SessionStatusUpdatedData {
  const SessionStatusUpdatedData({
    required this.sessionID,
    required this.status,
  });

  factory SessionStatusUpdatedData.fromJson(Map<String, Object?> json) =>
      SessionStatusUpdatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        status: SessionStatus.fromJson(asJsonMap(json['status'])),
      );

  final SessionID sessionID;
  final SessionStatus status;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'status': status.toJson(),
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

/// `UsageLimitsInfoWorkspace`
final class UsageLimitsInfoWorkspace {
  const UsageLimitsInfoWorkspace({
    required this.id,
    this.name,
    required this.usageURL,
  });

  factory UsageLimitsInfoWorkspace.fromJson(Map<String, Object?> json) =>
      UsageLimitsInfoWorkspace(
        id: decodeString(json, 'id'),
        name: decodeOptionalString(json, 'name'),
        usageURL: decodeString(json, 'usageURL'),
      );

  final String id;
  final String? name;
  final String usageURL;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (name != null) 'name': name!,
        'usageURL': usageURL,
      };
}

/// `VoiceModelsResponseData`
final class VoiceModelsResponseData {
  const VoiceModelsResponseData({
    required this.models,
    this.defaultValue,
  });

  factory VoiceModelsResponseData.fromJson(Map<String, Object?> json) =>
      VoiceModelsResponseData(
        models: jsonList(
            json['models'], (item) => VoiceModel.fromJson(asJsonMap(item))),
        defaultValue: decodeOptionalString(json, 'default'),
      );

  final List<VoiceModel> models;

  /// Wire field: `default`.
  final String? defaultValue;

  Map<String, Object?> toJson() => <String, Object?>{
        'models': [for (final item in models) item.toJson()],
        if (defaultValue != null) 'default': defaultValue!,
      };
}

/// `VoiceSessionResponseData`
final class VoiceSessionResponseData {
  const VoiceSessionResponseData({
    required this.transport,
  });

  factory VoiceSessionResponseData.fromJson(Map<String, Object?> json) =>
      VoiceSessionResponseData(
        transport: VoiceTransport.fromJson(asJsonMap(json['transport'])),
      );

  final VoiceTransport transport;

  Map<String, Object?> toJson() => <String, Object?>{
        'transport': transport.toJson(),
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

/// `CredentialSwitchedData`
final class CredentialSwitchedData {
  const CredentialSwitchedData({
    required this.integrationID,
    required this.credentialID,
  });

  factory CredentialSwitchedData.fromJson(Map<String, Object?> json) =>
      CredentialSwitchedData(
        integrationID:
            IntegrationID.fromJson(asJsonString(json['integrationID'])),
        credentialID: json['credentialID'] == null
            ? null
            : CredentialID.fromJson(asJsonString(json['credentialID'])),
      );

  final IntegrationID integrationID;
  final CredentialID? credentialID;

  Map<String, Object?> toJson() => <String, Object?>{
        'integrationID': integrationID,
        if (credentialID != null) 'credentialID': credentialID!,
      };
}

/// `CredentialUpdatedData`
final class CredentialUpdatedData {
  const CredentialUpdatedData({
    required this.integrationID,
    required this.credentialID,
  });

  factory CredentialUpdatedData.fromJson(Map<String, Object?> json) =>
      CredentialUpdatedData(
        integrationID:
            IntegrationID.fromJson(asJsonString(json['integrationID'])),
        credentialID: CredentialID.fromJson(asJsonString(json['credentialID'])),
      );

  final IntegrationID integrationID;
  final CredentialID credentialID;

  Map<String, Object?> toJson() => <String, Object?>{
        'integrationID': integrationID,
        'credentialID': credentialID,
      };
}

/// `ExperimentalMcpEventData`
final class ExperimentalMcpEventData {
  const ExperimentalMcpEventData({
    required this.id,
    required this.server,
    required this.name,
    required this.eventId,
    required this.timestamp,
    required this.data,
    required this.cursor,
    this.truncated,
  });

  factory ExperimentalMcpEventData.fromJson(Map<String, Object?> json) =>
      ExperimentalMcpEventData(
        id: decodeString(json, 'id'),
        server: decodeString(json, 'server'),
        name: decodeString(json, 'name'),
        eventId: decodeString(json, 'eventId'),
        timestamp: decodeString(json, 'timestamp'),
        data: json['data'],
        cursor: decodeOptionalString(json, 'cursor'),
        truncated: decodeOptionalBool(json, 'truncated'),
      );

  final String id;
  final String server;
  final String name;
  final String eventId;
  final String timestamp;
  final Object? data;
  final String? cursor;
  final bool? truncated;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'server': server,
        'name': name,
        'eventId': eventId,
        'timestamp': timestamp,
        'data': data,
        if (cursor != null) 'cursor': cursor!,
        if (truncated != null) 'truncated': truncated!,
      };
}

/// `FilesystemChangedData`
final class FilesystemChangedData {
  const FilesystemChangedData({
    required this.file,
    required this.event,
  });

  factory FilesystemChangedData.fromJson(Map<String, Object?> json) =>
      FilesystemChangedData(
        file: decodeString(json, 'file'),
        event: FilesystemChangedDataEvent.fromJson(json['event']),
      );

  final String file;
  final FilesystemChangedDataEvent event;

  Map<String, Object?> toJson() => <String, Object?>{
        'file': file,
        'event': event.wire,
      };
}

/// `FormCancelledData`
final class FormCancelledData {
  const FormCancelledData({
    required this.id,
    required this.sessionID,
  });

  factory FormCancelledData.fromJson(Map<String, Object?> json) =>
      FormCancelledData(
        id: FormID.fromJson(asJsonString(json['id'])),
        sessionID: decodeString(json, 'sessionID'),
      );

  final FormID id;
  final String sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
      };
}

/// `FormCreatedData`
final class FormCreatedData {
  const FormCreatedData({
    required this.form,
  });

  factory FormCreatedData.fromJson(Map<String, Object?> json) =>
      FormCreatedData(
        form: FormInfo.fromJson(asJsonMap(json['form'])),
      );

  final FormInfo form;

  Map<String, Object?> toJson() => <String, Object?>{
        'form': form.toJson(),
      };
}

/// `FormRepliedData`
final class FormRepliedData {
  const FormRepliedData({
    required this.id,
    required this.sessionID,
    required this.answer,
  });

  factory FormRepliedData.fromJson(Map<String, Object?> json) =>
      FormRepliedData(
        id: FormID.fromJson(asJsonString(json['id'])),
        sessionID: decodeString(json, 'sessionID'),
        answer: asJsonMap(json['answer']),
      );

  final FormID id;
  final String sessionID;
  final Map<String, Object?> answer;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'answer': answer,
      };
}

/// `InstallationUpdateAvailableData`
final class InstallationUpdateAvailableData {
  const InstallationUpdateAvailableData({
    required this.version,
  });

  factory InstallationUpdateAvailableData.fromJson(Map<String, Object?> json) =>
      InstallationUpdateAvailableData(
        version: decodeString(json, 'version'),
      );

  final String version;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': version,
      };
}

/// `InstallationUpdatedData`
final class InstallationUpdatedData {
  const InstallationUpdatedData({
    required this.version,
  });

  factory InstallationUpdatedData.fromJson(Map<String, Object?> json) =>
      InstallationUpdatedData(
        version: decodeString(json, 'version'),
      );

  final String version;

  Map<String, Object?> toJson() => <String, Object?>{
        'version': version,
      };
}

/// `McpResourcesChangedData`
final class McpResourcesChangedData {
  const McpResourcesChangedData({
    required this.server,
  });

  factory McpResourcesChangedData.fromJson(Map<String, Object?> json) =>
      McpResourcesChangedData(
        server: decodeString(json, 'server'),
      );

  final String server;

  Map<String, Object?> toJson() => <String, Object?>{
        'server': server,
      };
}

/// `McpStatusChangedData`
final class McpStatusChangedData {
  const McpStatusChangedData({
    required this.server,
  });

  factory McpStatusChangedData.fromJson(Map<String, Object?> json) =>
      McpStatusChangedData(
        server: decodeString(json, 'server'),
      );

  final String server;

  Map<String, Object?> toJson() => <String, Object?>{
        'server': server,
      };
}

/// `PermissionAskedData`
final class PermissionAskedData {
  const PermissionAskedData({
    required this.id,
    required this.sessionID,
    required this.action,
    required this.resources,
    this.save,
    this.metadata,
    this.source,
    this.message,
  });

  factory PermissionAskedData.fromJson(Map<String, Object?> json) =>
      PermissionAskedData(
        id: PermissionID.fromJson(asJsonString(json['id'])),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        action: decodeString(json, 'action'),
        resources: jsonList(json['resources'], (item) => asJsonString(item)),
        save: json['save'] == null
            ? null
            : jsonList(json['save'], (item) => asJsonString(item)),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        source: json['source'] == null
            ? null
            : PermissionSource2.fromJson(asJsonMap(json['source'])),
        message: decodeOptionalString(json, 'message'),
      );

  final PermissionID id;
  final SessionID sessionID;
  final String action;
  final List<String> resources;
  final List<String>? save;
  final Map<String, Object?>? metadata;
  final PermissionSource2? source;
  final String? message;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'sessionID': sessionID,
        'action': action,
        'resources': resources,
        if (save != null) 'save': save!,
        if (metadata != null) 'metadata': metadata!,
        if (source != null) 'source': source!.toJson(),
        if (message != null) 'message': message!,
      };
}

/// `PermissionRepliedData`
final class PermissionRepliedData {
  const PermissionRepliedData({
    required this.sessionID,
    required this.requestID,
    required this.reply,
  });

  factory PermissionRepliedData.fromJson(Map<String, Object?> json) =>
      PermissionRepliedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        requestID: PermissionID.fromJson(asJsonString(json['requestID'])),
        reply: PermissionReply.fromJson(json['reply']),
      );

  final SessionID sessionID;
  final PermissionID requestID;
  final PermissionReply reply;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'requestID': requestID,
        'reply': reply.wire,
      };
}

/// `PersistentPtyAddedData`
final class PersistentPtyAddedData {
  const PersistentPtyAddedData({
    required this.sessionID,
    required this.terminal,
  });

  factory PersistentPtyAddedData.fromJson(Map<String, Object?> json) =>
      PersistentPtyAddedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        terminal: PersistentPtyInfo.fromJson(asJsonMap(json['terminal'])),
      );

  final SessionID sessionID;
  final PersistentPtyInfo terminal;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'terminal': terminal.toJson(),
      };
}

/// `PersistentPtyRemovedData`
final class PersistentPtyRemovedData {
  const PersistentPtyRemovedData({
    required this.sessionID,
    required this.ptyID,
  });

  factory PersistentPtyRemovedData.fromJson(Map<String, Object?> json) =>
      PersistentPtyRemovedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        ptyID: PtyID.fromJson(asJsonString(json['ptyID'])),
      );

  final SessionID sessionID;
  final PtyID ptyID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'ptyID': ptyID,
      };
}

/// `PersistentPtyUpdatedData`
final class PersistentPtyUpdatedData {
  const PersistentPtyUpdatedData({
    required this.sessionID,
    required this.terminal,
  });

  factory PersistentPtyUpdatedData.fromJson(Map<String, Object?> json) =>
      PersistentPtyUpdatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        terminal: PersistentPtyInfo.fromJson(asJsonMap(json['terminal'])),
      );

  final SessionID sessionID;
  final PersistentPtyInfo terminal;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'terminal': terminal.toJson(),
      };
}

/// `ProjectUpdatedData`
final class ProjectUpdatedData {
  const ProjectUpdatedData({
    required this.id,
    required this.canonical,
    this.vcs,
    this.name,
    this.icon,
    this.commands,
    required this.time,
    required this.sandboxes,
  });

  factory ProjectUpdatedData.fromJson(Map<String, Object?> json) =>
      ProjectUpdatedData(
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

/// `PtyCreatedData`
final class PtyCreatedData {
  const PtyCreatedData({
    required this.info,
  });

  factory PtyCreatedData.fromJson(Map<String, Object?> json) => PtyCreatedData(
        info: Pty.fromJson(asJsonMap(json['info'])),
      );

  final Pty info;

  Map<String, Object?> toJson() => <String, Object?>{
        'info': info.toJson(),
      };
}

/// `PtyDeletedData`
final class PtyDeletedData {
  const PtyDeletedData({
    required this.id,
  });

  factory PtyDeletedData.fromJson(Map<String, Object?> json) => PtyDeletedData(
        id: PtyID.fromJson(asJsonString(json['id'])),
      );

  final PtyID id;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
      };
}

/// `PtyExitedData`
final class PtyExitedData {
  const PtyExitedData({
    required this.id,
    required this.exitCode,
  });

  factory PtyExitedData.fromJson(Map<String, Object?> json) => PtyExitedData(
        id: PtyID.fromJson(asJsonString(json['id'])),
        exitCode: decodeInt(json, 'exitCode'),
      );

  final PtyID id;
  final int exitCode;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'exitCode': exitCode,
      };
}

/// `PtyUpdatedData`
final class PtyUpdatedData {
  const PtyUpdatedData({
    required this.info,
  });

  factory PtyUpdatedData.fromJson(Map<String, Object?> json) => PtyUpdatedData(
        info: Pty.fromJson(asJsonMap(json['info'])),
      );

  final Pty info;

  Map<String, Object?> toJson() => <String, Object?>{
        'info': info.toJson(),
      };
}

/// `SessionCompactionDeltaData`
final class SessionCompactionDeltaData {
  const SessionCompactionDeltaData({
    required this.sessionID,
    required this.text,
  });

  factory SessionCompactionDeltaData.fromJson(Map<String, Object?> json) =>
      SessionCompactionDeltaData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        text: decodeString(json, 'text'),
      );

  final SessionID sessionID;
  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'text': text,
      };
}

/// `SessionIdleData`
final class SessionIdleData {
  const SessionIdleData({
    required this.sessionID,
  });

  factory SessionIdleData.fromJson(Map<String, Object?> json) =>
      SessionIdleData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
      );

  final SessionID sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionReasoningDeltaData`
final class SessionReasoningDeltaData {
  const SessionReasoningDeltaData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.ordinal,
    required this.delta,
  });

  factory SessionReasoningDeltaData.fromJson(Map<String, Object?> json) =>
      SessionReasoningDeltaData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        ordinal: decodeInt(json, 'ordinal'),
        delta: decodeString(json, 'delta'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int ordinal;
  final String delta;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'ordinal': ordinal,
        'delta': delta,
      };
}

/// `SessionTextDeltaData`
final class SessionTextDeltaData {
  const SessionTextDeltaData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.ordinal,
    required this.delta,
  });

  factory SessionTextDeltaData.fromJson(Map<String, Object?> json) =>
      SessionTextDeltaData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        ordinal: decodeInt(json, 'ordinal'),
        delta: decodeString(json, 'delta'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final int ordinal;
  final String delta;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'ordinal': ordinal,
        'delta': delta,
      };
}

/// `SessionToolInputDeltaData`
final class SessionToolInputDeltaData {
  const SessionToolInputDeltaData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.delta,
  });

  factory SessionToolInputDeltaData.fromJson(Map<String, Object?> json) =>
      SessionToolInputDeltaData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        delta: decodeString(json, 'delta'),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final String delta;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'delta': delta,
      };
}

/// `SessionToolProgressData`
final class SessionToolProgressData {
  const SessionToolProgressData({
    required this.sessionID,
    required this.assistantMessageID,
    required this.id,
    required this.metadata,
  });

  factory SessionToolProgressData.fromJson(Map<String, Object?> json) =>
      SessionToolProgressData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        assistantMessageID:
            SessionMessageID.fromJson(asJsonString(json['assistantMessageID'])),
        id: decodeString(json, 'id'),
        metadata: asJsonMap(json['metadata']),
      );

  final SessionID sessionID;
  final SessionMessageID assistantMessageID;
  final String id;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'assistantMessageID': assistantMessageID,
        'id': id,
        'metadata': metadata,
      };
}

/// `SessionUsageUpdatedData`
final class SessionUsageUpdatedData {
  const SessionUsageUpdatedData({
    required this.sessionID,
    required this.cost,
    required this.tokens,
  });

  factory SessionUsageUpdatedData.fromJson(Map<String, Object?> json) =>
      SessionUsageUpdatedData(
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        cost: MoneyUSD.fromJson(asJsonDouble(json['cost'])),
        tokens: TokenUsageInfo.fromJson(asJsonMap(json['tokens'])),
      );

  final SessionID sessionID;
  final MoneyUSD cost;
  final TokenUsageInfo tokens;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'cost': cost,
        'tokens': tokens.toJson(),
      };
}

/// `ShellCreatedData`
final class ShellCreatedData {
  const ShellCreatedData({
    required this.info,
  });

  factory ShellCreatedData.fromJson(Map<String, Object?> json) =>
      ShellCreatedData(
        info: ShellInfo.fromJson(asJsonMap(json['info'])),
      );

  final ShellInfo info;

  Map<String, Object?> toJson() => <String, Object?>{
        'info': info.toJson(),
      };
}

/// `ShellDeletedData`
final class ShellDeletedData {
  const ShellDeletedData({
    required this.id,
  });

  factory ShellDeletedData.fromJson(Map<String, Object?> json) =>
      ShellDeletedData(
        id: ShellID.fromJson(asJsonString(json['id'])),
      );

  final ShellID id;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
      };
}

/// `ShellExitedData`
final class ShellExitedData {
  const ShellExitedData({
    required this.id,
    this.exit,
    required this.status,
  });

  factory ShellExitedData.fromJson(Map<String, Object?> json) =>
      ShellExitedData(
        id: ShellID.fromJson(asJsonString(json['id'])),
        exit: decodeOptionalNumber(json, 'exit'),
        status: ShellExitedDataStatus.fromJson(json['status']),
      );

  final ShellID id;
  final double? exit;
  final ShellExitedDataStatus status;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (exit != null) 'exit': exit!,
        'status': status.wire,
      };
}

/// `TuiCommandExecuteData`
final class TuiCommandExecuteData {
  const TuiCommandExecuteData({
    required this.command,
  });

  factory TuiCommandExecuteData.fromJson(Map<String, Object?> json) =>
      TuiCommandExecuteData(
        command: decodeString(json, 'command'),
      );

  final String command;

  Map<String, Object?> toJson() => <String, Object?>{
        'command': command,
      };
}

/// `TuiPromptAppendData`
final class TuiPromptAppendData {
  const TuiPromptAppendData({
    required this.text,
  });

  factory TuiPromptAppendData.fromJson(Map<String, Object?> json) =>
      TuiPromptAppendData(
        text: decodeString(json, 'text'),
      );

  final String text;

  Map<String, Object?> toJson() => <String, Object?>{
        'text': text,
      };
}

/// `TuiSessionSelectData`
final class TuiSessionSelectData {
  const TuiSessionSelectData({
    required this.sessionID,
  });

  factory TuiSessionSelectData.fromJson(Map<String, Object?> json) =>
      TuiSessionSelectData(
        sessionID: json['sessionID'],
      );

  final Object? sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `TuiToastShowData`
final class TuiToastShowData {
  const TuiToastShowData({
    this.title,
    required this.message,
    required this.variant,
    this.duration,
  });

  factory TuiToastShowData.fromJson(Map<String, Object?> json) =>
      TuiToastShowData(
        title: decodeOptionalString(json, 'title'),
        message: decodeString(json, 'message'),
        variant: TuiToastShowDataVariant.fromJson(json['variant']),
        duration: decodeOptionalInt(json, 'duration'),
      );

  final String? title;
  final String message;
  final TuiToastShowDataVariant variant;
  final int? duration;

  Map<String, Object?> toJson() => <String, Object?>{
        if (title != null) 'title': title!,
        'message': message,
        'variant': variant.wire,
        if (duration != null) 'duration': duration!,
      };
}

/// `VcsBranchUpdatedData`
final class VcsBranchUpdatedData {
  const VcsBranchUpdatedData({
    this.branch,
  });

  factory VcsBranchUpdatedData.fromJson(Map<String, Object?> json) =>
      VcsBranchUpdatedData(
        branch: decodeOptionalString(json, 'branch'),
      );

  final String? branch;

  Map<String, Object?> toJson() => <String, Object?>{
        if (branch != null) 'branch': branch!,
      };
}

/// `WorktreeResolvedDurable`
final class WorktreeResolvedDurable {
  const WorktreeResolvedDurable({
    required this.aggregateID,
    required this.seq,
    required this.version,
  });

  factory WorktreeResolvedDurable.fromJson(Map<String, Object?> json) =>
      WorktreeResolvedDurable(
        aggregateID: decodeString(json, 'aggregateID'),
        seq: EventSeq.fromJson(asJsonInt(json['seq'])),
        version: EventVersionEncodedC77c5abcb68d.fromJson(
            asJsonDouble(json['version'])),
      );

  final String aggregateID;
  final EventSeq seq;
  final EventVersionEncodedC77c5abcb68d version;

  Map<String, Object?> toJson() => <String, Object?>{
        'aggregateID': aggregateID,
        'seq': seq,
        'version': version,
      };
}

/// `WorktreeResolvedData`
final class WorktreeResolvedData {
  const WorktreeResolvedData({
    required this.projectID,
    required this.directory,
    required this.previous,
    this.adopted,
  });

  factory WorktreeResolvedData.fromJson(Map<String, Object?> json) =>
      WorktreeResolvedData(
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
        previous: ProjectID.fromJson(asJsonString(json['previous'])),
        adopted: json['adopted'] == null
            ? null
            : jsonList(json['adopted'],
                (item) => ProjectID.fromJson(asJsonString(item))),
      );

  final ProjectID projectID;
  final AbsolutePath directory;
  final ProjectID previous;
  final List<ProjectID>? adopted;

  Map<String, Object?> toJson() => <String, Object?>{
        'projectID': projectID,
        'directory': directory,
        'previous': previous,
        if (adopted != null) 'adopted': adopted!,
      };
}

/// `WorktreeUpdatedData`
final class WorktreeUpdatedData {
  const WorktreeUpdatedData({
    required this.projectID,
  });

  factory WorktreeUpdatedData.fromJson(Map<String, Object?> json) =>
      WorktreeUpdatedData(
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
      );

  final ProjectID projectID;

  Map<String, Object?> toJson() => <String, Object?>{
        'projectID': projectID,
      };
}

/// `DebugHeapDumpResponseMemory`
final class DebugHeapDumpResponseMemory {
  const DebugHeapDumpResponseMemory({
    required this.rss,
    required this.heapTotal,
    required this.heapUsed,
    required this.externalValue,
    required this.arrayBuffers,
  });

  factory DebugHeapDumpResponseMemory.fromJson(Map<String, Object?> json) =>
      DebugHeapDumpResponseMemory(
        rss: json['rss'],
        heapTotal: json['heapTotal'],
        heapUsed: json['heapUsed'],
        externalValue: json['external'],
        arrayBuffers: json['arrayBuffers'],
      );

  final Object? rss;
  final Object? heapTotal;
  final Object? heapUsed;

  /// Wire field: `external`.
  final Object? externalValue;
  final Object? arrayBuffers;

  Map<String, Object?> toJson() => <String, Object?>{
        'rss': rss,
        'heapTotal': heapTotal,
        'heapUsed': heapUsed,
        'external': externalValue,
        'arrayBuffers': arrayBuffers,
      };
}

/// `DebugHeapDumpResponse`
final class DebugHeapDumpResponse {
  const DebugHeapDumpResponse({
    required this.path,
    required this.pid,
    required this.memory,
  });

  factory DebugHeapDumpResponse.fromJson(Map<String, Object?> json) =>
      DebugHeapDumpResponse(
        path: decodeString(json, 'path'),
        pid: decodeInt(json, 'pid'),
        memory: DebugHeapDumpResponseMemory.fromJson(asJsonMap(json['memory'])),
      );

  final String path;
  final int pid;
  final DebugHeapDumpResponseMemory memory;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        'pid': pid,
        'memory': memory.toJson(),
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

  /// Present on every variant (`pool`).
  bool? get pool;

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

/// `ExperimentalPersistentPtyCreateInputSize`
final class ExperimentalPersistentPtyCreateInputSize {
  const ExperimentalPersistentPtyCreateInputSize({
    required this.cols,
    required this.rows,
  });

  factory ExperimentalPersistentPtyCreateInputSize.fromJson(
          Map<String, Object?> json) =>
      ExperimentalPersistentPtyCreateInputSize(
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

/// `ExperimentalPersistentPtyHandoffResponse`
final class ExperimentalPersistentPtyHandoffResponse {
  const ExperimentalPersistentPtyHandoffResponse({
    required this.handoff,
  });

  factory ExperimentalPersistentPtyHandoffResponse.fromJson(
          Map<String, Object?> json) =>
      ExperimentalPersistentPtyHandoffResponse(
        handoff: json['handoff'] == null
            ? null
            : PersistentPtyHandoff.fromJson(asJsonMap(json['handoff'])),
      );

  final PersistentPtyHandoff? handoff;

  Map<String, Object?> toJson() => <String, Object?>{
        if (handoff != null) 'handoff': handoff!.toJson(),
      };
}

/// `ExperimentalPersistentPtyUpdateInputSize`
final class ExperimentalPersistentPtyUpdateInputSize {
  const ExperimentalPersistentPtyUpdateInputSize({
    required this.cols,
    required this.rows,
  });

  factory ExperimentalPersistentPtyUpdateInputSize.fromJson(
          Map<String, Object?> json) =>
      ExperimentalPersistentPtyUpdateInputSize(
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
