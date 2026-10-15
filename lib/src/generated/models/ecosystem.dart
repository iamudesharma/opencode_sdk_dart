// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Model.Ref`
final class ModelRef {
  const ModelRef({
    required this.id,
    required this.providerID,
    this.variant,
  });

  factory ModelRef.fromJson(Map<String, Object?> json) => ModelRef(
        id: decodeString(json, 'id'),
        providerID: ProviderID.fromJson(asJsonString(json['providerID'])),
        variant: decodeOptionalString(json, 'variant'),
      );

  final String id;
  final ProviderID providerID;
  final String? variant;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'providerID': providerID,
        if (variant != null) 'variant': variant!,
      };
}

/// `Provider.Request`
final class ProviderRequest {
  const ProviderRequest({
    required this.settings,
    required this.headers,
    required this.body,
  });

  factory ProviderRequest.fromJson(Map<String, Object?> json) =>
      ProviderRequest(
        settings: ProviderSettings.fromJson(asJsonMap(json['settings'])),
        headers: asJsonMap(json['headers']),
        body: asJsonMap(json['body']),
      );

  final ProviderSettings settings;
  final Map<String, Object?> headers;
  final Map<String, Object?> body;

  Map<String, Object?> toJson() => <String, Object?>{
        'settings': settings.toJson(),
        'headers': headers,
        'body': body,
      };
}

/// `Provider.Settings`
final class ProviderSettings {
  const ProviderSettings({
    this.timeout,
    this.headerTimeout,
    this.chunkTimeout,
    this.compaction,
    this.transport,
    this.encoding,
  });

  factory ProviderSettings.fromJson(Map<String, Object?> json) =>
      ProviderSettings(
        timeout: json['timeout'],
        headerTimeout: json['headerTimeout'],
        chunkTimeout: json['chunkTimeout'],
        compaction: json['compaction'] == null
            ? null
            : ProviderCompaction.fromJson(asJsonMap(json['compaction'])),
        transport: json['transport'] == null
            ? null
            : ProviderTransport.fromJson(json['transport']),
        encoding: json['encoding'] == null
            ? null
            : ProviderEncoding.fromJson(json['encoding']),
      );

  final Object? timeout;
  final Object? headerTimeout;
  final Object? chunkTimeout;
  final ProviderCompaction? compaction;
  final ProviderTransport? transport;
  final ProviderEncoding? encoding;

  Map<String, Object?> toJson() => <String, Object?>{
        if (timeout != null) 'timeout': timeout!,
        if (headerTimeout != null) 'headerTimeout': headerTimeout!,
        if (chunkTimeout != null) 'chunkTimeout': chunkTimeout!,
        if (compaction != null) 'compaction': compaction!.toJson(),
        if (transport != null) 'transport': transport!.wire,
        if (encoding != null) 'encoding': encoding!.wire,
      };
}

/// `Provider.Compaction`
sealed class ProviderCompaction {
  const ProviderCompaction();

  /// Decodes a payload into the matching variant.
  factory ProviderCompaction.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'summary' => ProviderCompactionSummary.fromJson(json),
      'native' => ProviderCompactionNative.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Provider.Compaction discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `ProviderCompactionSummary`
final class ProviderCompactionSummary extends ProviderCompaction {
  const ProviderCompactionSummary();

  factory ProviderCompactionSummary.fromJson(Map<String, Object?> json) =>
      ProviderCompactionSummary();

  /// Always `summary`.
  @override
  String get type => 'summary';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'summary',
      };
}

/// `ProviderCompactionNative`
final class ProviderCompactionNative extends ProviderCompaction {
  const ProviderCompactionNative();

  factory ProviderCompactionNative.fromJson(Map<String, Object?> json) =>
      ProviderCompactionNative();

  /// Always `native`.
  @override
  String get type => 'native';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'native',
      };
}

/// `Model.Compatibility`
final class ModelCompatibility {
  const ModelCompatibility({
    this.reasoningField,
    this.requireReasoning,
    this.maxTokensField,
    this.requireFinishReason,
    this.requireAssistantAfterTool,
    this.supportsPromptCacheKey,
    this.cacheFormat,
    this.supportsThinkingBlockBinding,
    this.supportsEffortUpdates,
  });

  factory ModelCompatibility.fromJson(Map<String, Object?> json) =>
      ModelCompatibility(
        reasoningField: decodeOptionalString(json, 'reasoningField'),
        requireReasoning: decodeOptionalBool(json, 'requireReasoning'),
        maxTokensField: json['maxTokensField'] == null
            ? null
            : ModelMaxTokensField.fromJson(json['maxTokensField']),
        requireFinishReason: decodeOptionalBool(json, 'requireFinishReason'),
        requireAssistantAfterTool:
            decodeOptionalBool(json, 'requireAssistantAfterTool'),
        supportsPromptCacheKey:
            decodeOptionalBool(json, 'supportsPromptCacheKey'),
        cacheFormat: json['cacheFormat'] == null
            ? null
            : ModelCacheFormat.fromJson(json['cacheFormat']),
        supportsThinkingBlockBinding:
            decodeOptionalBool(json, 'supportsThinkingBlockBinding'),
        supportsEffortUpdates:
            decodeOptionalBool(json, 'supportsEffortUpdates'),
      );

  final String? reasoningField;
  final bool? requireReasoning;
  final ModelMaxTokensField? maxTokensField;
  final bool? requireFinishReason;
  final bool? requireAssistantAfterTool;
  final bool? supportsPromptCacheKey;
  final ModelCacheFormat? cacheFormat;
  final bool? supportsThinkingBlockBinding;
  final bool? supportsEffortUpdates;

  Map<String, Object?> toJson() => <String, Object?>{
        if (reasoningField != null) 'reasoningField': reasoningField!,
        if (requireReasoning != null) 'requireReasoning': requireReasoning!,
        if (maxTokensField != null) 'maxTokensField': maxTokensField!.wire,
        if (requireFinishReason != null)
          'requireFinishReason': requireFinishReason!,
        if (requireAssistantAfterTool != null)
          'requireAssistantAfterTool': requireAssistantAfterTool!,
        if (supportsPromptCacheKey != null)
          'supportsPromptCacheKey': supportsPromptCacheKey!,
        if (cacheFormat != null) 'cacheFormat': cacheFormat!.wire,
        if (supportsThinkingBlockBinding != null)
          'supportsThinkingBlockBinding': supportsThinkingBlockBinding!,
        if (supportsEffortUpdates != null)
          'supportsEffortUpdates': supportsEffortUpdates!,
      };
}

/// `Provider.Compatibility`
final class ProviderCompatibility {
  const ProviderCompatibility({
    this.reasoningField,
    this.requireReasoning,
    this.maxTokensField,
    this.requireFinishReason,
    this.requireAssistantAfterTool,
    this.supportsPromptCacheKey,
    this.cacheFormat,
  });

  factory ProviderCompatibility.fromJson(Map<String, Object?> json) =>
      ProviderCompatibility(
        reasoningField: decodeOptionalString(json, 'reasoningField'),
        requireReasoning: decodeOptionalBool(json, 'requireReasoning'),
        maxTokensField: json['maxTokensField'] == null
            ? null
            : ModelMaxTokensField.fromJson(json['maxTokensField']),
        requireFinishReason: decodeOptionalBool(json, 'requireFinishReason'),
        requireAssistantAfterTool:
            decodeOptionalBool(json, 'requireAssistantAfterTool'),
        supportsPromptCacheKey:
            decodeOptionalBool(json, 'supportsPromptCacheKey'),
        cacheFormat: json['cacheFormat'] == null
            ? null
            : ModelCacheFormat.fromJson(json['cacheFormat']),
      );

  final String? reasoningField;
  final bool? requireReasoning;
  final ModelMaxTokensField? maxTokensField;
  final bool? requireFinishReason;
  final bool? requireAssistantAfterTool;
  final bool? supportsPromptCacheKey;
  final ModelCacheFormat? cacheFormat;

  Map<String, Object?> toJson() => <String, Object?>{
        if (reasoningField != null) 'reasoningField': reasoningField!,
        if (requireReasoning != null) 'requireReasoning': requireReasoning!,
        if (maxTokensField != null) 'maxTokensField': maxTokensField!.wire,
        if (requireFinishReason != null)
          'requireFinishReason': requireFinishReason!,
        if (requireAssistantAfterTool != null)
          'requireAssistantAfterTool': requireAssistantAfterTool!,
        if (supportsPromptCacheKey != null)
          'supportsPromptCacheKey': supportsPromptCacheKey!,
        if (cacheFormat != null) 'cacheFormat': cacheFormat!.wire,
      };
}

/// `Connection.CredentialInfo`
final class ConnectionCredentialInfo extends ConnectionInfo {
  const ConnectionCredentialInfo({
    required this.id,
    required this.label,
    required this.method,
    this.status,
  });

  factory ConnectionCredentialInfo.fromJson(Map<String, Object?> json) =>
      ConnectionCredentialInfo(
        id: CredentialID.fromJson(asJsonString(json['id'])),
        label: decodeString(json, 'label'),
        method: ConnectionCredentialInfoMethod.fromJson(json['method']),
        status: json['status'] == null
            ? null
            : ConnectionStatus.fromJson(asJsonMap(json['status'])),
      );

  final CredentialID id;
  final String label;
  final ConnectionCredentialInfoMethod method;
  @override
  final ConnectionStatus? status;

  /// Always `credential`.
  @override
  String get type => 'credential';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'credential',
        'id': id,
        'label': label,
        'method': method.wire,
        if (status != null) 'status': status!.toJson(),
      };
}

/// `Connection.Status`
final class ConnectionStatus {
  const ConnectionStatus({
    required this.message,
    this.url,
  });

  factory ConnectionStatus.fromJson(Map<String, Object?> json) =>
      ConnectionStatus(
        message: decodeString(json, 'message'),
        url: decodeOptionalString(json, 'url'),
      );

  final String message;
  final String? url;

  /// Always `needs_auth`.
  String get status => 'needs_auth';

  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'needs_auth',
        'message': message,
        if (url != null) 'url': url!,
      };
}

/// `Connection.EnvInfo`
final class ConnectionEnvInfo extends ConnectionInfo {
  const ConnectionEnvInfo({
    required this.name,
    this.status,
  });

  factory ConnectionEnvInfo.fromJson(Map<String, Object?> json) =>
      ConnectionEnvInfo(
        name: decodeString(json, 'name'),
        status: json['status'] == null
            ? null
            : ConnectionStatus.fromJson(asJsonMap(json['status'])),
      );

  final String name;
  @override
  final ConnectionStatus? status;

  /// Always `env`.
  @override
  String get type => 'env';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'env',
        'name': name,
        if (status != null) 'status': status!.toJson(),
      };
}

/// `Connection.Info`
sealed class ConnectionInfo {
  const ConnectionInfo();

  /// Decodes a payload into the matching variant.
  factory ConnectionInfo.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'credential' => ConnectionCredentialInfo.fromJson(json),
      'env' => ConnectionEnvInfo.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Connection.Info discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`status`).
  ConnectionStatus? get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Credential.CreateInput`
final class CredentialCreateInput {
  const CredentialCreateInput({
    this.id,
    required this.integrationID,
    this.label,
    required this.value,
    this.activate,
  });

  factory CredentialCreateInput.fromJson(Map<String, Object?> json) =>
      CredentialCreateInput(
        id: json['id'] == null
            ? null
            : CredentialID.fromJson(asJsonString(json['id'])),
        integrationID:
            IntegrationID.fromJson(asJsonString(json['integrationID'])),
        label: decodeOptionalString(json, 'label'),
        value: CredentialValue.fromJson(asJsonMap(json['value'])),
        activate: decodeOptionalBool(json, 'activate'),
      );

  final CredentialID? id;
  final IntegrationID integrationID;
  final String? label;
  final CredentialValue value;
  final bool? activate;

  Map<String, Object?> toJson() => <String, Object?>{
        if (id != null) 'id': id!,
        'integrationID': integrationID,
        if (label != null) 'label': label!,
        'value': value.toJson(),
        if (activate != null) 'activate': activate!,
      };
}

/// `Credential.Value`
sealed class CredentialValue {
  const CredentialValue();

  /// Decodes a payload into the matching variant.
  factory CredentialValue.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'oauth' => CredentialOAuth.fromJson(json),
      'key' => CredentialKey.fromJson(json),
      'external' => CredentialExternal.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Credential.Value discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Present on every variant (`metadata`).
  Map<String, Object?>? get metadata;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Credential.OAuth`
final class CredentialOAuth extends CredentialValue {
  const CredentialOAuth({
    required this.methodID,
    required this.refresh,
    required this.access,
    required this.expires,
    this.metadata,
  });

  factory CredentialOAuth.fromJson(Map<String, Object?> json) =>
      CredentialOAuth(
        methodID: IntegrationMethodID.fromJson(asJsonString(json['methodID'])),
        refresh: decodeString(json, 'refresh'),
        access: decodeString(json, 'access'),
        expires: decodeInt(json, 'expires'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final IntegrationMethodID methodID;
  final String refresh;
  final String access;
  final int expires;
  @override
  final Map<String, Object?>? metadata;

  /// Always `oauth`.
  @override
  String get type => 'oauth';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'oauth',
        'methodID': methodID,
        'refresh': refresh,
        'access': access,
        'expires': expires,
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `Credential.Key`
final class CredentialKey extends CredentialValue {
  const CredentialKey({
    required this.key,
    this.metadata,
    this.configuration,
  });

  factory CredentialKey.fromJson(Map<String, Object?> json) => CredentialKey(
        key: decodeString(json, 'key'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        configuration: json['configuration'] == null
            ? null
            : asJsonMap(json['configuration']),
      );

  final String key;
  @override
  final Map<String, Object?>? metadata;
  final Map<String, Object?>? configuration;

  /// Always `key`.
  @override
  String get type => 'key';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'key',
        'key': key,
        if (metadata != null) 'metadata': metadata!,
        if (configuration != null) 'configuration': configuration!,
      };
}

/// `Credential.External`
final class CredentialExternal extends CredentialValue {
  const CredentialExternal({
    required this.methodID,
    this.metadata,
  });

  factory CredentialExternal.fromJson(Map<String, Object?> json) =>
      CredentialExternal(
        methodID: IntegrationMethodID.fromJson(asJsonString(json['methodID'])),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
      );

  final IntegrationMethodID methodID;
  @override
  final Map<String, Object?>? metadata;

  /// Always `external`.
  @override
  String get type => 'external';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'external',
        'methodID': methodID,
        if (metadata != null) 'metadata': metadata!,
      };
}

/// `Credential.Entry`
final class CredentialEntry {
  const CredentialEntry({
    required this.id,
    required this.integrationID,
    required this.label,
    required this.active,
    required this.value,
  });

  factory CredentialEntry.fromJson(Map<String, Object?> json) =>
      CredentialEntry(
        id: CredentialID.fromJson(asJsonString(json['id'])),
        integrationID:
            IntegrationID.fromJson(asJsonString(json['integrationID'])),
        label: decodeString(json, 'label'),
        active: decodeBool(json, 'active'),
        value: CredentialValue.fromJson(asJsonMap(json['value'])),
      );

  final CredentialID id;
  final IntegrationID integrationID;
  final String label;
  final bool active;
  final CredentialValue value;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'integrationID': integrationID,
        'label': label,
        'active': active,
        'value': value.toJson(),
      };
}

/// `Integration.AttemptEncoded`
final class IntegrationAttemptEncoded {
  const IntegrationAttemptEncoded({
    required this.attemptID,
    required this.url,
    required this.instructions,
    required this.mode,
    required this.time,
  });

  factory IntegrationAttemptEncoded.fromJson(Map<String, Object?> json) =>
      IntegrationAttemptEncoded(
        attemptID:
            IntegrationAttemptID.fromJson(asJsonString(json['attemptID'])),
        url: decodeString(json, 'url'),
        instructions: decodeString(json, 'instructions'),
        mode: IntegrationAttemptEncodedMode.fromJson(json['mode']),
        time: IntegrationAttemptEncodedTime.fromJson(asJsonMap(json['time'])),
      );

  final IntegrationAttemptID attemptID;
  final String url;
  final String instructions;
  final IntegrationAttemptEncodedMode mode;
  final IntegrationAttemptEncodedTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'attemptID': attemptID,
        'url': url,
        'instructions': instructions,
        'mode': mode.wire,
        'time': time.toJson(),
      };
}

/// `Integration.AttemptStatus`
sealed class IntegrationAttemptStatus {
  const IntegrationAttemptStatus();

  /// Decodes a payload into the matching variant.
  factory IntegrationAttemptStatus.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'pending' => IntegrationAttemptStatusPending.fromJson(json),
      'complete' => IntegrationAttemptStatusComplete.fromJson(json),
      'failed' => IntegrationAttemptStatusFailed.fromJson(json),
      'expired' => IntegrationAttemptStatusExpired.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Integration.AttemptStatus discriminator: $value'),
    };
  }

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `IntegrationAttemptStatusPending`
final class IntegrationAttemptStatusPending extends IntegrationAttemptStatus {
  const IntegrationAttemptStatusPending({
    required this.time,
  });

  factory IntegrationAttemptStatusPending.fromJson(Map<String, Object?> json) =>
      IntegrationAttemptStatusPending(
        time: IntegrationAttemptStatusPendingTime.fromJson(
            asJsonMap(json['time'])),
      );

  final IntegrationAttemptStatusPendingTime time;

  /// Always `pending`.
  @override
  String get status => 'pending';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'pending',
        'time': time.toJson(),
      };
}

/// `IntegrationAttemptStatusComplete`
final class IntegrationAttemptStatusComplete extends IntegrationAttemptStatus {
  const IntegrationAttemptStatusComplete({
    required this.time,
  });

  factory IntegrationAttemptStatusComplete.fromJson(
          Map<String, Object?> json) =>
      IntegrationAttemptStatusComplete(
        time: IntegrationAttemptStatusCompleteTime.fromJson(
            asJsonMap(json['time'])),
      );

  final IntegrationAttemptStatusCompleteTime time;

  /// Always `complete`.
  @override
  String get status => 'complete';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'complete',
        'time': time.toJson(),
      };
}

/// `IntegrationAttemptStatusFailed`
final class IntegrationAttemptStatusFailed extends IntegrationAttemptStatus {
  const IntegrationAttemptStatusFailed({
    required this.message,
    required this.time,
  });

  factory IntegrationAttemptStatusFailed.fromJson(Map<String, Object?> json) =>
      IntegrationAttemptStatusFailed(
        message: decodeString(json, 'message'),
        time: IntegrationAttemptStatusFailedTime.fromJson(
            asJsonMap(json['time'])),
      );

  final String message;
  final IntegrationAttemptStatusFailedTime time;

  /// Always `failed`.
  @override
  String get status => 'failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'failed',
        'message': message,
        'time': time.toJson(),
      };
}

/// `IntegrationAttemptStatusExpired`
final class IntegrationAttemptStatusExpired extends IntegrationAttemptStatus {
  const IntegrationAttemptStatusExpired({
    required this.time,
  });

  factory IntegrationAttemptStatusExpired.fromJson(Map<String, Object?> json) =>
      IntegrationAttemptStatusExpired(
        time: IntegrationAttemptStatusExpiredTime.fromJson(
            asJsonMap(json['time'])),
      );

  final IntegrationAttemptStatusExpiredTime time;

  /// Always `expired`.
  @override
  String get status => 'expired';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'expired',
        'time': time.toJson(),
      };
}

/// `Integration.CommandAttempt`
final class IntegrationCommandAttempt {
  const IntegrationCommandAttempt({
    required this.attemptID,
    required this.time,
  });

  factory IntegrationCommandAttempt.fromJson(Map<String, Object?> json) =>
      IntegrationCommandAttempt(
        attemptID:
            IntegrationAttemptID.fromJson(asJsonString(json['attemptID'])),
        time: IntegrationCommandAttemptTime.fromJson(asJsonMap(json['time'])),
      );

  final IntegrationAttemptID attemptID;
  final IntegrationCommandAttemptTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'attemptID': attemptID,
        'time': time.toJson(),
      };
}

/// `Integration.CommandAttemptStatus`
sealed class IntegrationCommandAttemptStatus {
  const IntegrationCommandAttemptStatus();

  /// Decodes a payload into the matching variant.
  factory IntegrationCommandAttemptStatus.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'pending' => IntegrationCommandAttemptStatusPending.fromJson(json),
      'complete' => IntegrationCommandAttemptStatusComplete.fromJson(json),
      'failed' => IntegrationCommandAttemptStatusFailed.fromJson(json),
      'expired' => IntegrationCommandAttemptStatusExpired.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Integration.CommandAttemptStatus discriminator: $value'),
    };
  }

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `IntegrationCommandAttemptStatusPending`
final class IntegrationCommandAttemptStatusPending
    extends IntegrationCommandAttemptStatus {
  const IntegrationCommandAttemptStatusPending({
    this.message,
    required this.time,
  });

  factory IntegrationCommandAttemptStatusPending.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusPending(
        message: decodeOptionalString(json, 'message'),
        time: IntegrationCommandAttemptStatusPendingTime.fromJson(
            asJsonMap(json['time'])),
      );

  final String? message;
  final IntegrationCommandAttemptStatusPendingTime time;

  /// Always `pending`.
  @override
  String get status => 'pending';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'pending',
        if (message != null) 'message': message!,
        'time': time.toJson(),
      };
}

/// `IntegrationCommandAttemptStatusComplete`
final class IntegrationCommandAttemptStatusComplete
    extends IntegrationCommandAttemptStatus {
  const IntegrationCommandAttemptStatusComplete({
    required this.time,
  });

  factory IntegrationCommandAttemptStatusComplete.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusComplete(
        time: IntegrationCommandAttemptStatusCompleteTime.fromJson(
            asJsonMap(json['time'])),
      );

  final IntegrationCommandAttemptStatusCompleteTime time;

  /// Always `complete`.
  @override
  String get status => 'complete';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'complete',
        'time': time.toJson(),
      };
}

/// `IntegrationCommandAttemptStatusFailed`
final class IntegrationCommandAttemptStatusFailed
    extends IntegrationCommandAttemptStatus {
  const IntegrationCommandAttemptStatusFailed({
    required this.message,
    required this.time,
  });

  factory IntegrationCommandAttemptStatusFailed.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusFailed(
        message: decodeString(json, 'message'),
        time: IntegrationCommandAttemptStatusFailedTime.fromJson(
            asJsonMap(json['time'])),
      );

  final String message;
  final IntegrationCommandAttemptStatusFailedTime time;

  /// Always `failed`.
  @override
  String get status => 'failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'failed',
        'message': message,
        'time': time.toJson(),
      };
}

/// `IntegrationCommandAttemptStatusExpired`
final class IntegrationCommandAttemptStatusExpired
    extends IntegrationCommandAttemptStatus {
  const IntegrationCommandAttemptStatusExpired({
    required this.time,
  });

  factory IntegrationCommandAttemptStatusExpired.fromJson(
          Map<String, Object?> json) =>
      IntegrationCommandAttemptStatusExpired(
        time: IntegrationCommandAttemptStatusExpiredTime.fromJson(
            asJsonMap(json['time'])),
      );

  final IntegrationCommandAttemptStatusExpiredTime time;

  /// Always `expired`.
  @override
  String get status => 'expired';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'expired',
        'time': time.toJson(),
      };
}

/// `Integration.CommandMethod`
final class IntegrationCommandMethod extends IntegrationMethod {
  const IntegrationCommandMethod({
    required this.id,
    required this.label,
    required this.command,
  });

  factory IntegrationCommandMethod.fromJson(Map<String, Object?> json) =>
      IntegrationCommandMethod(
        id: IntegrationMethodID.fromJson(asJsonString(json['id'])),
        label: decodeString(json, 'label'),
        command: jsonList(json['command'], (item) => asJsonString(item)),
      );

  final IntegrationMethodID id;
  final String label;
  final List<String> command;

  /// Always `command`.
  @override
  String get type => 'command';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'type': 'command',
        'label': label,
        'command': command,
      };
}

/// `Integration.EnvMethod`
final class IntegrationEnvMethod extends IntegrationMethod {
  const IntegrationEnvMethod({
    required this.names,
  });

  factory IntegrationEnvMethod.fromJson(Map<String, Object?> json) =>
      IntegrationEnvMethod(
        names: jsonList(json['names'], (item) => asJsonString(item)),
      );

  final List<String> names;

  /// Always `env`.
  @override
  String get type => 'env';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'env',
        'names': names,
      };
}

/// `Integration.ExternalMethod`
final class IntegrationExternalMethod extends IntegrationMethod {
  const IntegrationExternalMethod({
    required this.id,
    required this.label,
    this.form,
  });

  factory IntegrationExternalMethod.fromJson(Map<String, Object?> json) =>
      IntegrationExternalMethod(
        id: IntegrationMethodID.fromJson(asJsonString(json['id'])),
        label: decodeString(json, 'label'),
        form: json['form'] == null
            ? null
            : jsonList(
                json['form'], (item) => FormField.fromJson(asJsonMap(item))),
      );

  final IntegrationMethodID id;
  final String label;
  final List<FormField>? form;

  /// Always `external`.
  @override
  String get type => 'external';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'type': 'external',
        'label': label,
        if (form != null) 'form': [for (final item in form!) item.toJson()],
      };
}

/// `Integration.Info`
final class IntegrationInfo {
  const IntegrationInfo({
    required this.id,
    required this.name,
    this.metadata,
    required this.methods,
    required this.connections,
  });

  factory IntegrationInfo.fromJson(Map<String, Object?> json) =>
      IntegrationInfo(
        id: IntegrationID.fromJson(asJsonString(json['id'])),
        name: decodeString(json, 'name'),
        metadata: json['metadata'] == null ? null : asJsonMap(json['metadata']),
        methods: jsonList(json['methods'],
            (item) => IntegrationMethod.fromJson(asJsonMap(item))),
        connections: jsonList(json['connections'],
            (item) => ConnectionInfo.fromJson(asJsonMap(item))),
      );

  final IntegrationID id;
  final String name;
  final Map<String, Object?>? metadata;
  final List<IntegrationMethod> methods;
  final List<ConnectionInfo> connections;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        if (metadata != null) 'metadata': metadata!,
        'methods': [for (final item in methods) item.toJson()],
        'connections': [for (final item in connections) item.toJson()],
      };
}

/// `Integration.Method`
sealed class IntegrationMethod {
  const IntegrationMethod();

  /// Decodes a payload into the matching variant.
  factory IntegrationMethod.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'oauth' => IntegrationOAuthMethod.fromJson(json),
      'command' => IntegrationCommandMethod.fromJson(json),
      'key' => IntegrationKeyMethod.fromJson(json),
      'external' => IntegrationExternalMethod.fromJson(json),
      'env' => IntegrationEnvMethod.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Integration.Method discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `Integration.OAuthMethod`
final class IntegrationOAuthMethod extends IntegrationMethod {
  const IntegrationOAuthMethod({
    required this.id,
    required this.label,
    this.form,
  });

  factory IntegrationOAuthMethod.fromJson(Map<String, Object?> json) =>
      IntegrationOAuthMethod(
        id: IntegrationMethodID.fromJson(asJsonString(json['id'])),
        label: decodeString(json, 'label'),
        form: json['form'] == null
            ? null
            : jsonList(
                json['form'], (item) => FormField.fromJson(asJsonMap(item))),
      );

  final IntegrationMethodID id;
  final String label;
  final List<FormField>? form;

  /// Always `oauth`.
  @override
  String get type => 'oauth';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'type': 'oauth',
        'label': label,
        if (form != null) 'form': [for (final item in form!) item.toJson()],
      };
}

/// `Integration.KeyMethod`
final class IntegrationKeyMethod extends IntegrationMethod {
  const IntegrationKeyMethod({
    this.label,
    this.form,
  });

  factory IntegrationKeyMethod.fromJson(Map<String, Object?> json) =>
      IntegrationKeyMethod(
        label: decodeOptionalString(json, 'label'),
        form: json['form'] == null
            ? null
            : jsonList(
                json['form'], (item) => FormField.fromJson(asJsonMap(item))),
      );

  final String? label;
  final List<FormField>? form;

  /// Always `key`.
  @override
  String get type => 'key';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'key',
        if (label != null) 'label': label!,
        if (form != null) 'form': [for (final item in form!) item.toJson()],
      };
}

/// `Mcp.LocalConfigEncoded`
final class McpLocalConfigEncoded extends ExperimentalMcpAddInputConfig {
  const McpLocalConfigEncoded({
    required this.command,
    this.cwd,
    this.environment,
    this.disabled,
    this.codemode,
    this.timeout,
    this.protocol,
  });

  factory McpLocalConfigEncoded.fromJson(Map<String, Object?> json) =>
      McpLocalConfigEncoded(
        command: jsonList(json['command'], (item) => asJsonString(item)),
        cwd: decodeOptionalString(json, 'cwd'),
        environment:
            json['environment'] == null ? null : asJsonMap(json['environment']),
        disabled: decodeOptionalBool(json, 'disabled'),
        codemode: decodeOptionalBool(json, 'codemode'),
        timeout: json['timeout'] == null
            ? null
            : McpLocalConfigEncodedTimeout.fromJson(asJsonMap(json['timeout'])),
        protocol: json['protocol'] == null
            ? null
            : McpProtocol.fromJson(json['protocol']),
      );

  final List<String> command;
  final String? cwd;
  final Map<String, Object?>? environment;
  @override
  final bool? disabled;
  @override
  final bool? codemode;
  final McpLocalConfigEncodedTimeout? timeout;
  @override
  final McpProtocol? protocol;

  /// Always `local`.
  @override
  String get type => 'local';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'local',
        'command': command,
        if (cwd != null) 'cwd': cwd!,
        if (environment != null) 'environment': environment!,
        if (disabled != null) 'disabled': disabled!,
        if (codemode != null) 'codemode': codemode!,
        if (timeout != null) 'timeout': timeout!.toJson(),
        if (protocol != null) 'protocol': protocol!.wire,
      };
}

/// `Mcp.OAuthConfigEncoded`
final class McpOAuthConfigEncoded {
  const McpOAuthConfigEncoded({
    this.clientId,
    this.clientSecret,
    this.scope,
    this.callbackPort,
    this.redirectUri,
    this.authServerMetadataUrl,
  });

  factory McpOAuthConfigEncoded.fromJson(Map<String, Object?> json) =>
      McpOAuthConfigEncoded(
        clientId: decodeOptionalString(json, 'client_id'),
        clientSecret: decodeOptionalString(json, 'client_secret'),
        scope: decodeOptionalString(json, 'scope'),
        callbackPort: decodeOptionalInt(json, 'callback_port'),
        redirectUri: decodeOptionalString(json, 'redirect_uri'),
        authServerMetadataUrl:
            decodeOptionalString(json, 'auth_server_metadata_url'),
      );

  /// Wire field: `client_id`.
  final String? clientId;

  /// Wire field: `client_secret`.
  final String? clientSecret;
  final String? scope;

  /// Wire field: `callback_port`.
  final int? callbackPort;

  /// Wire field: `redirect_uri`.
  final String? redirectUri;

  /// Wire field: `auth_server_metadata_url`.
  final String? authServerMetadataUrl;

  Map<String, Object?> toJson() => <String, Object?>{
        if (clientId != null) 'client_id': clientId!,
        if (clientSecret != null) 'client_secret': clientSecret!,
        if (scope != null) 'scope': scope!,
        if (callbackPort != null) 'callback_port': callbackPort!,
        if (redirectUri != null) 'redirect_uri': redirectUri!,
        if (authServerMetadataUrl != null)
          'auth_server_metadata_url': authServerMetadataUrl!,
      };
}

/// `Mcp.RemoteConfigEncoded`
final class McpRemoteConfigEncoded extends ExperimentalMcpAddInputConfig {
  const McpRemoteConfigEncoded({
    required this.url,
    this.headers,
    this.oauth,
    this.disabled,
    this.codemode,
    this.timeout,
    this.protocol,
  });

  factory McpRemoteConfigEncoded.fromJson(Map<String, Object?> json) =>
      McpRemoteConfigEncoded(
        url: decodeString(json, 'url'),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        oauth: json['oauth'],
        disabled: decodeOptionalBool(json, 'disabled'),
        codemode: decodeOptionalBool(json, 'codemode'),
        timeout: json['timeout'] == null
            ? null
            : McpRemoteConfigEncodedTimeout.fromJson(
                asJsonMap(json['timeout'])),
        protocol: json['protocol'] == null
            ? null
            : McpProtocol.fromJson(json['protocol']),
      );

  final String url;
  final Map<String, Object?>? headers;
  final Object? oauth;
  @override
  final bool? disabled;
  @override
  final bool? codemode;
  final McpRemoteConfigEncodedTimeout? timeout;
  @override
  final McpProtocol? protocol;

  /// Always `remote`.
  @override
  String get type => 'remote';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'remote',
        'url': url,
        if (headers != null) 'headers': headers!,
        if (oauth != null) 'oauth': oauth!,
        if (disabled != null) 'disabled': disabled!,
        if (codemode != null) 'codemode': codemode!,
        if (timeout != null) 'timeout': timeout!.toJson(),
        if (protocol != null) 'protocol': protocol!.wire,
      };
}

/// `Mcp.Resource`
final class McpResourceInfo {
  const McpResourceInfo({
    required this.server,
    required this.name,
    required this.uri,
    this.description,
    this.mimeType,
  });

  factory McpResourceInfo.fromJson(Map<String, Object?> json) =>
      McpResourceInfo(
        server: decodeString(json, 'server'),
        name: decodeString(json, 'name'),
        uri: decodeString(json, 'uri'),
        description: decodeOptionalString(json, 'description'),
        mimeType: decodeOptionalString(json, 'mimeType'),
      );

  final String server;
  final String name;
  final String uri;
  final String? description;
  final String? mimeType;

  Map<String, Object?> toJson() => <String, Object?>{
        'server': server,
        'name': name,
        'uri': uri,
        if (description != null) 'description': description!,
        if (mimeType != null) 'mimeType': mimeType!,
      };
}

/// `Mcp.ResourceCatalog`
final class McpResourceCatalog {
  const McpResourceCatalog({
    required this.resources,
    required this.templates,
  });

  factory McpResourceCatalog.fromJson(Map<String, Object?> json) =>
      McpResourceCatalog(
        resources: jsonList(json['resources'],
            (item) => McpResourceInfo.fromJson(asJsonMap(item))),
        templates: jsonList(json['templates'],
            (item) => McpResourceTemplate.fromJson(asJsonMap(item))),
      );

  final List<McpResourceInfo> resources;
  final List<McpResourceTemplate> templates;

  Map<String, Object?> toJson() => <String, Object?>{
        'resources': [for (final item in resources) item.toJson()],
        'templates': [for (final item in templates) item.toJson()],
      };
}

/// `Mcp.ResourceTemplate`
final class McpResourceTemplate {
  const McpResourceTemplate({
    required this.server,
    required this.name,
    required this.uriTemplate,
    this.description,
    this.mimeType,
  });

  factory McpResourceTemplate.fromJson(Map<String, Object?> json) =>
      McpResourceTemplate(
        server: decodeString(json, 'server'),
        name: decodeString(json, 'name'),
        uriTemplate: decodeString(json, 'uriTemplate'),
        description: decodeOptionalString(json, 'description'),
        mimeType: decodeOptionalString(json, 'mimeType'),
      );

  final String server;
  final String name;
  final String uriTemplate;
  final String? description;
  final String? mimeType;

  Map<String, Object?> toJson() => <String, Object?>{
        'server': server,
        'name': name,
        'uriTemplate': uriTemplate,
        if (description != null) 'description': description!,
        if (mimeType != null) 'mimeType': mimeType!,
      };
}

/// `Mcp.Server`
final class McpServer {
  const McpServer({
    required this.name,
    required this.status,
    this.integrationID,
  });

  factory McpServer.fromJson(Map<String, Object?> json) => McpServer(
        name: decodeString(json, 'name'),
        status: McpServerStatus.fromJson(asJsonMap(json['status'])),
        integrationID: json['integrationID'] == null
            ? null
            : IntegrationID.fromJson(asJsonString(json['integrationID'])),
      );

  final String name;
  final McpServerStatus status;
  final IntegrationID? integrationID;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'status': status.toJson(),
        if (integrationID != null) 'integrationID': integrationID!,
      };
}

/// `Mcp.Status.Connected`
final class McpStatusConnected extends McpServerStatus {
  const McpStatusConnected();

  factory McpStatusConnected.fromJson(Map<String, Object?> json) =>
      McpStatusConnected();

  /// Always `connected`.
  @override
  String get status => 'connected';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'connected',
      };
}

/// `Mcp.Status.Pending`
final class McpStatusPending extends McpServerStatus {
  const McpStatusPending();

  factory McpStatusPending.fromJson(Map<String, Object?> json) =>
      McpStatusPending();

  /// Always `pending`.
  @override
  String get status => 'pending';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'pending',
      };
}

/// `Mcp.Status.Disabled`
final class McpStatusDisabled extends McpServerStatus {
  const McpStatusDisabled();

  factory McpStatusDisabled.fromJson(Map<String, Object?> json) =>
      McpStatusDisabled();

  /// Always `disabled`.
  @override
  String get status => 'disabled';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'disabled',
      };
}

/// `Mcp.Status.Failed`
final class McpStatusFailed extends McpServerStatus {
  const McpStatusFailed({
    required this.error,
  });

  factory McpStatusFailed.fromJson(Map<String, Object?> json) =>
      McpStatusFailed(
        error: decodeString(json, 'error'),
      );

  final String error;

  /// Always `failed`.
  @override
  String get status => 'failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'failed',
        'error': error,
      };
}

/// `Mcp.Status.NeedsAuth`
final class McpStatusNeedsAuth extends McpServerStatus {
  const McpStatusNeedsAuth({
    required this.error,
  });

  factory McpStatusNeedsAuth.fromJson(Map<String, Object?> json) =>
      McpStatusNeedsAuth(
        error: decodeString(json, 'error'),
      );

  final String error;

  /// Always `needs_auth`.
  @override
  String get status => 'needs_auth';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'needs_auth',
        'error': error,
      };
}

/// `Model.Capabilities`
final class ModelCapabilities {
  const ModelCapabilities({
    required this.tools,
    required this.input,
    required this.output,
  });

  factory ModelCapabilities.fromJson(Map<String, Object?> json) =>
      ModelCapabilities(
        tools: decodeBool(json, 'tools'),
        input: jsonList(json['input'], (item) => asJsonString(item)),
        output: jsonList(json['output'], (item) => asJsonString(item)),
      );

  final bool tools;
  final List<String> input;
  final List<String> output;

  Map<String, Object?> toJson() => <String, Object?>{
        'tools': tools,
        'input': input,
        'output': output,
      };
}

/// `Model.Cost`
final class ModelCost {
  const ModelCost({
    this.tier,
    required this.input,
    required this.output,
    required this.cache,
  });

  factory ModelCost.fromJson(Map<String, Object?> json) => ModelCost(
        tier: json['tier'] == null
            ? null
            : ModelCostTier.fromJson(asJsonMap(json['tier'])),
        input: MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['input'])),
        output: MoneyUSDPerMillionTokens.fromJson(asJsonDouble(json['output'])),
        cache: ModelCostCache.fromJson(asJsonMap(json['cache'])),
      );

  final ModelCostTier? tier;
  final MoneyUSDPerMillionTokens input;
  final MoneyUSDPerMillionTokens output;
  final ModelCostCache cache;

  Map<String, Object?> toJson() => <String, Object?>{
        if (tier != null) 'tier': tier!.toJson(),
        'input': input,
        'output': output,
        'cache': cache.toJson(),
      };
}

/// `Model.Info`
final class ModelInfo {
  const ModelInfo({
    required this.id,
    required this.modelID,
    required this.providerID,
    this.canonical,
    this.family,
    required this.name,
    this.compatibility,
    this.package,
    this.settings,
    this.headers,
    this.body,
    required this.capabilities,
    required this.variants,
    required this.time,
    required this.cost,
    required this.status,
    required this.enabled,
    required this.limit,
  });

  factory ModelInfo.fromJson(Map<String, Object?> json) => ModelInfo(
        id: decodeString(json, 'id'),
        modelID: decodeString(json, 'modelID'),
        providerID: ProviderID.fromJson(asJsonString(json['providerID'])),
        canonical: json['canonical'] == null
            ? null
            : ProviderID.fromJson(asJsonString(json['canonical'])),
        family: decodeOptionalString(json, 'family'),
        name: decodeString(json, 'name'),
        compatibility: json['compatibility'] == null
            ? null
            : ModelCompatibility.fromJson(asJsonMap(json['compatibility'])),
        package: decodeOptionalString(json, 'package'),
        settings: json['settings'] == null
            ? null
            : ModelSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
        capabilities:
            ModelCapabilities.fromJson(asJsonMap(json['capabilities'])),
        variants: jsonList(
            json['variants'], (item) => ModelVariant.fromJson(asJsonMap(item))),
        time: ModelInfoTime.fromJson(asJsonMap(json['time'])),
        cost: jsonList(
            json['cost'], (item) => ModelCost.fromJson(asJsonMap(item))),
        status: ModelInfoStatus.fromJson(json['status']),
        enabled: decodeBool(json, 'enabled'),
        limit: ModelInfoLimit.fromJson(asJsonMap(json['limit'])),
      );

  final String id;
  final String modelID;
  final ProviderID providerID;
  final ProviderID? canonical;
  final String? family;
  final String name;
  final ModelCompatibility? compatibility;
  final String? package;
  final ModelSettings? settings;
  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;
  final ModelCapabilities capabilities;
  final List<ModelVariant> variants;
  final ModelInfoTime time;
  final List<ModelCost> cost;
  final ModelInfoStatus status;
  final bool enabled;
  final ModelInfoLimit limit;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'modelID': modelID,
        'providerID': providerID,
        if (canonical != null) 'canonical': canonical!,
        if (family != null) 'family': family!,
        'name': name,
        if (compatibility != null) 'compatibility': compatibility!.toJson(),
        if (package != null) 'package': package!,
        if (settings != null) 'settings': settings!.toJson(),
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
        'capabilities': capabilities.toJson(),
        'variants': [for (final item in variants) item.toJson()],
        'time': time.toJson(),
        'cost': [for (final item in cost) item.toJson()],
        'status': status.wire,
        'enabled': enabled,
        'limit': limit.toJson(),
      };
}

/// `Model.Settings`
final class ModelSettings {
  const ModelSettings({
    this.compaction,
    this.encoding,
  });

  factory ModelSettings.fromJson(Map<String, Object?> json) => ModelSettings(
        compaction: json['compaction'] == null
            ? null
            : ProviderCompaction.fromJson(asJsonMap(json['compaction'])),
        encoding: json['encoding'] == null
            ? null
            : ProviderEncoding.fromJson(json['encoding']),
      );

  final ProviderCompaction? compaction;
  final ProviderEncoding? encoding;

  Map<String, Object?> toJson() => <String, Object?>{
        if (compaction != null) 'compaction': compaction!.toJson(),
        if (encoding != null) 'encoding': encoding!.wire,
      };
}

/// `Model.Variant`
final class ModelVariant {
  const ModelVariant({
    required this.id,
    this.settings,
    this.headers,
    this.body,
  });

  factory ModelVariant.fromJson(Map<String, Object?> json) => ModelVariant(
        id: decodeString(json, 'id'),
        settings: json['settings'] == null
            ? null
            : ModelSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
      );

  final String id;
  final ModelSettings? settings;
  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (settings != null) 'settings': settings!.toJson(),
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
      };
}

/// `Plugin.Features`
final class PluginFeatures {
  const PluginFeatures();

  factory PluginFeatures.fromJson(Map<String, Object?> json) =>
      PluginFeatures();

  /// Always `true`.
  bool get server => true;

  /// Always `true`.
  bool get tui => true;

  /// Always `true`.
  bool get rpc => true;

  Map<String, Object?> toJson() => <String, Object?>{
        'server': true,
        'tui': true,
        'rpc': true,
      };
}

/// `Plugin.Info`
final class PluginInfo {
  const PluginInfo({
    this.id,
    required this.source,
    required this.features,
    required this.state,
  });

  factory PluginInfo.fromJson(Map<String, Object?> json) => PluginInfo(
        id: decodeOptionalString(json, 'id'),
        source: PluginSource.fromJson(asJsonMap(json['source'])),
        features: PluginFeatures.fromJson(asJsonMap(json['features'])),
        state: PluginState.fromJson(asJsonMap(json['state'])),
      );

  final String? id;
  final PluginSource source;
  final PluginFeatures features;
  final PluginState state;

  Map<String, Object?> toJson() => <String, Object?>{
        if (id != null) 'id': id!,
        'source': source.toJson(),
        'features': features.toJson(),
        'state': state.toJson(),
      };
}

/// `Plugin.Source`
sealed class PluginSource {
  const PluginSource();

  /// Decodes a payload into the matching variant.
  factory PluginSource.fromJson(Map<String, Object?> json) {
    final value = json['type'];
    return switch (value) {
      'builtin' => PluginSourceBuiltin.fromJson(json),
      'package' => PluginSourcePackage.fromJson(json),
      'local' => PluginSourceLocal.fromJson(json),
      'sdk' => PluginSourceSdk.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Plugin.Source discriminator: $value'),
    };
  }

  /// Present on every variant (`type`).
  String get type;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `PluginSourceBuiltin`
final class PluginSourceBuiltin extends PluginSource {
  const PluginSourceBuiltin();

  factory PluginSourceBuiltin.fromJson(Map<String, Object?> json) =>
      PluginSourceBuiltin();

  /// Always `builtin`.
  @override
  String get type => 'builtin';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'builtin',
      };
}

/// `PluginSourcePackage`
final class PluginSourcePackage extends PluginSource {
  const PluginSourcePackage({
    required this.target,
    this.version,
  });

  factory PluginSourcePackage.fromJson(Map<String, Object?> json) =>
      PluginSourcePackage(
        target: decodeString(json, 'target'),
        version: decodeOptionalString(json, 'version'),
      );

  final String target;
  final String? version;

  /// Always `package`.
  @override
  String get type => 'package';

  /// Always `true`.
  bool get outdated => true;

  /// Always `true`.
  bool get updating => true;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'package',
        'target': target,
        if (version != null) 'version': version!,
        'outdated': true,
        'updating': true,
      };
}

/// `PluginSourceLocal`
final class PluginSourceLocal extends PluginSource {
  const PluginSourceLocal({
    required this.path,
  });

  factory PluginSourceLocal.fromJson(Map<String, Object?> json) =>
      PluginSourceLocal(
        path: decodeString(json, 'path'),
      );

  final String path;

  /// Always `local`.
  @override
  String get type => 'local';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'local',
        'path': path,
      };
}

/// `PluginSourceSdk`
final class PluginSourceSdk extends PluginSource {
  const PluginSourceSdk();

  factory PluginSourceSdk.fromJson(Map<String, Object?> json) =>
      PluginSourceSdk();

  /// Always `sdk`.
  @override
  String get type => 'sdk';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'sdk',
      };
}

/// `Plugin.State`
sealed class PluginState {
  const PluginState();

  /// Decodes a payload into the matching variant.
  factory PluginState.fromJson(Map<String, Object?> json) {
    final value = json['status'];
    return switch (value) {
      'active' => PluginStateActive.fromJson(json),
      'failed' => PluginStateFailed.fromJson(json),
      _ => throw OpenCodeDecodeException(
          'Unknown Plugin.State discriminator: $value'),
    };
  }

  /// Present on every variant (`status`).
  String get status;

  /// Encodes this value to JSON.
  Map<String, Object?> toJson();
}

/// `PluginStateActive`
final class PluginStateActive extends PluginState {
  const PluginStateActive();

  factory PluginStateActive.fromJson(Map<String, Object?> json) =>
      PluginStateActive();

  /// Always `active`.
  @override
  String get status => 'active';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'active',
      };
}

/// `PluginStateFailed`
final class PluginStateFailed extends PluginState {
  const PluginStateFailed({
    required this.error,
    this.ref,
  });

  factory PluginStateFailed.fromJson(Map<String, Object?> json) =>
      PluginStateFailed(
        error: decodeString(json, 'error'),
        ref: decodeOptionalString(json, 'ref'),
      );

  final String error;
  final String? ref;

  /// Always `failed`.
  @override
  String get status => 'failed';

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'status': 'failed',
        'error': error,
        if (ref != null) 'ref': ref!,
      };
}

/// `Provider.Info`
final class ProviderInfo {
  const ProviderInfo({
    required this.id,
    this.canonical,
    this.integrationID,
    required this.name,
    required this.activation,
    required this.package,
    this.compatibility,
    this.settings,
    this.headers,
    this.body,
  });

  factory ProviderInfo.fromJson(Map<String, Object?> json) => ProviderInfo(
        id: ProviderID.fromJson(asJsonString(json['id'])),
        canonical: json['canonical'] == null
            ? null
            : ProviderID.fromJson(asJsonString(json['canonical'])),
        integrationID: json['integrationID'] == null
            ? null
            : IntegrationID.fromJson(asJsonString(json['integrationID'])),
        name: decodeString(json, 'name'),
        activation: ProviderInfoActivation.fromJson(json['activation']),
        package: decodeString(json, 'package'),
        compatibility: json['compatibility'] == null
            ? null
            : ProviderCompatibility.fromJson(asJsonMap(json['compatibility'])),
        settings: json['settings'] == null
            ? null
            : ProviderSettings.fromJson(asJsonMap(json['settings'])),
        headers: json['headers'] == null ? null : asJsonMap(json['headers']),
        body: json['body'] == null ? null : asJsonMap(json['body']),
      );

  final ProviderID id;
  final ProviderID? canonical;
  final IntegrationID? integrationID;
  final String name;
  final ProviderInfoActivation activation;
  final String package;
  final ProviderCompatibility? compatibility;
  final ProviderSettings? settings;
  final Map<String, Object?>? headers;
  final Map<String, Object?>? body;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        if (canonical != null) 'canonical': canonical!,
        if (integrationID != null) 'integrationID': integrationID!,
        'name': name,
        'activation': activation.wire,
        'package': package,
        if (compatibility != null) 'compatibility': compatibility!.toJson(),
        if (settings != null) 'settings': settings!.toJson(),
        if (headers != null) 'headers': headers!,
        if (body != null) 'body': body!,
      };
}
