// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Provider.Transport`
enum ProviderTransport {
  http('http'),
  websocket('websocket');

  const ProviderTransport(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ProviderTransport fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ProviderTransport fromWire(String value) => switch (value) {
        'http' => http,
        'websocket' => websocket,
        _ => throw OpenCodeDecodeException(
            'Unknown ProviderTransport value: $value'),
      };
}

/// `Provider.Encoding`
enum ProviderEncoding {
  zstd('zstd'),
  gzip('gzip'),
  none('none');

  const ProviderEncoding(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ProviderEncoding fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ProviderEncoding fromWire(String value) => switch (value) {
        'zstd' => zstd,
        'gzip' => gzip,
        'none' => none,
        _ => throw OpenCodeDecodeException(
            'Unknown ProviderEncoding value: $value'),
      };
}

/// `AgentInfoMode`
enum AgentInfoMode {
  subagent('subagent'),
  primary('primary'),
  all('all');

  const AgentInfoMode(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static AgentInfoMode fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static AgentInfoMode fromWire(String value) => switch (value) {
        'subagent' => subagent,
        'primary' => primary,
        'all' => all,
        _ =>
          throw OpenCodeDecodeException('Unknown AgentInfoMode value: $value'),
      };
}

/// `Permission.Effect`
enum PermissionEffect {
  allow('allow'),
  deny('deny'),
  ask('ask');

  const PermissionEffect(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static PermissionEffect fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static PermissionEffect fromWire(String value) => switch (value) {
        'allow' => allow,
        'deny' => deny,
        'ask' => ask,
        _ => throw OpenCodeDecodeException(
            'Unknown PermissionEffect value: $value'),
      };
}

/// `ConfigAgentEncodedMode`
enum ConfigAgentEncodedMode {
  subagent('subagent'),
  primary('primary'),
  all('all');

  const ConfigAgentEncodedMode(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigAgentEncodedMode fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigAgentEncodedMode fromWire(String value) => switch (value) {
        'subagent' => subagent,
        'primary' => primary,
        'all' => all,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigAgentEncodedMode value: $value'),
      };
}

/// `ConfigInfoEncodedUpdate`
enum ConfigInfoEncodedUpdate {
  disable('disable'),
  notify('notify'),
  auto('auto');

  const ConfigInfoEncodedUpdate(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedUpdate fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedUpdate fromWire(String value) => switch (value) {
        'disable' => disable,
        'notify' => notify,
        'auto' => auto,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigInfoEncodedUpdate value: $value'),
      };
}

/// `ConfigInfoEncodedShare`
enum ConfigInfoEncodedShare {
  manual('manual'),
  auto('auto'),
  disabled('disabled');

  const ConfigInfoEncodedShare(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedShare fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedShare fromWire(String value) => switch (value) {
        'manual' => manual,
        'auto' => auto,
        'disabled' => disabled,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigInfoEncodedShare value: $value'),
      };
}

/// `ConfigInfoEncodedPoliciesAction`
enum ConfigInfoEncodedPoliciesAction {
  providerUse('provider.use'),
  toolUse('tool.use'),
  integrationUse('integration.use');

  const ConfigInfoEncodedPoliciesAction(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedPoliciesAction fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedPoliciesAction fromWire(String value) =>
      switch (value) {
        'provider.use' => providerUse,
        'tool.use' => toolUse,
        'integration.use' => integrationUse,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigInfoEncodedPoliciesAction value: $value'),
      };
}

/// `ConfigInfoEncodedPoliciesEffect`
enum ConfigInfoEncodedPoliciesEffect {
  allow('allow'),
  deny('deny');

  const ConfigInfoEncodedPoliciesEffect(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedPoliciesEffect fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedPoliciesEffect fromWire(String value) =>
      switch (value) {
        'allow' => allow,
        'deny' => deny,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigInfoEncodedPoliciesEffect value: $value'),
      };
}

/// `ConfigInfoEncodedExperimentalPoliciesAction`
enum ConfigInfoEncodedExperimentalPoliciesAction {
  providerUse('provider.use'),
  toolUse('tool.use'),
  integrationUse('integration.use');

  const ConfigInfoEncodedExperimentalPoliciesAction(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedExperimentalPoliciesAction fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedExperimentalPoliciesAction fromWire(String value) =>
      switch (value) {
        'provider.use' => providerUse,
        'tool.use' => toolUse,
        'integration.use' => integrationUse,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigInfoEncodedExperimentalPoliciesAction value: $value'),
      };
}

/// `ConfigInfoEncodedExperimentalPoliciesEffect`
enum ConfigInfoEncodedExperimentalPoliciesEffect {
  allow('allow'),
  deny('deny');

  const ConfigInfoEncodedExperimentalPoliciesEffect(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedExperimentalPoliciesEffect fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConfigInfoEncodedExperimentalPoliciesEffect fromWire(String value) =>
      switch (value) {
        'allow' => allow,
        'deny' => deny,
        _ => throw OpenCodeDecodeException(
            'Unknown ConfigInfoEncodedExperimentalPoliciesEffect value: $value'),
      };
}

/// `Model.MaxTokensField`
enum ModelMaxTokensField {
  maxCompletionTokens('max_completion_tokens'),
  maxTokens('max_tokens');

  const ModelMaxTokensField(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ModelMaxTokensField fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ModelMaxTokensField fromWire(String value) => switch (value) {
        'max_completion_tokens' => maxCompletionTokens,
        'max_tokens' => maxTokens,
        _ => throw OpenCodeDecodeException(
            'Unknown ModelMaxTokensField value: $value'),
      };
}

/// `Model.CacheFormat`
enum ModelCacheFormat {
  anthropic('anthropic'),
  alibaba('alibaba');

  const ModelCacheFormat(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ModelCacheFormat fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ModelCacheFormat fromWire(String value) => switch (value) {
        'anthropic' => anthropic,
        'alibaba' => alibaba,
        _ => throw OpenCodeDecodeException(
            'Unknown ModelCacheFormat value: $value'),
      };
}

/// `ConnectionCredentialInfoMethod`
enum ConnectionCredentialInfoMethod {
  key('key'),
  oauth('oauth'),
  externalValue('external');

  const ConnectionCredentialInfoMethod(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ConnectionCredentialInfoMethod fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ConnectionCredentialInfoMethod fromWire(String value) =>
      switch (value) {
        'key' => key,
        'oauth' => oauth,
        'external' => externalValue,
        _ => throw OpenCodeDecodeException(
            'Unknown ConnectionCredentialInfoMethod value: $value'),
      };
}

/// `FileDiffInfoStatus`
enum FileDiffInfoStatus {
  added('added'),
  deleted('deleted'),
  modified('modified');

  const FileDiffInfoStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static FileDiffInfoStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static FileDiffInfoStatus fromWire(String value) => switch (value) {
        'added' => added,
        'deleted' => deleted,
        'modified' => modified,
        _ => throw OpenCodeDecodeException(
            'Unknown FileDiffInfoStatus value: $value'),
      };
}

/// `FileSystemEntryType`
enum FileSystemEntryType {
  file('file'),
  directory('directory');

  const FileSystemEntryType(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static FileSystemEntryType fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static FileSystemEntryType fromWire(String value) => switch (value) {
        'file' => file,
        'directory' => directory,
        _ => throw OpenCodeDecodeException(
            'Unknown FileSystemEntryType value: $value'),
      };
}

/// `FormWhenOp`
enum FormWhenOp {
  eq('eq'),
  neq('neq');

  const FormWhenOp(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static FormWhenOp fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static FormWhenOp fromWire(String value) => switch (value) {
        'eq' => eq,
        'neq' => neq,
        _ => throw OpenCodeDecodeException('Unknown FormWhenOp value: $value'),
      };
}

/// `FormStringFieldFormat`
enum FormStringFieldFormat {
  email('email'),
  uri('uri'),
  date('date'),
  dateTime('date-time');

  const FormStringFieldFormat(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static FormStringFieldFormat fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static FormStringFieldFormat fromWire(String value) => switch (value) {
        'email' => email,
        'uri' => uri,
        'date' => date,
        'date-time' => dateTime,
        _ => throw OpenCodeDecodeException(
            'Unknown FormStringFieldFormat value: $value'),
      };
}

/// `IntegrationAttemptEncodedMode`
enum IntegrationAttemptEncodedMode {
  auto('auto'),
  code('code');

  const IntegrationAttemptEncodedMode(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static IntegrationAttemptEncodedMode fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static IntegrationAttemptEncodedMode fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'code' => code,
        _ => throw OpenCodeDecodeException(
            'Unknown IntegrationAttemptEncodedMode value: $value'),
      };
}

/// `Mcp.Protocol`
enum McpProtocol {
  legacy('legacy'),
  auto('auto'),
  v20260728('2026-07-28');

  const McpProtocol(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static McpProtocol fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static McpProtocol fromWire(String value) => switch (value) {
        'legacy' => legacy,
        'auto' => auto,
        '2026-07-28' => v20260728,
        _ => throw OpenCodeDecodeException('Unknown McpProtocol value: $value'),
      };
}

/// `ModelInfoStatus`
enum ModelInfoStatus {
  alpha('alpha'),
  beta('beta'),
  deprecated('deprecated'),
  active('active');

  const ModelInfoStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ModelInfoStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ModelInfoStatus fromWire(String value) => switch (value) {
        'alpha' => alpha,
        'beta' => beta,
        'deprecated' => deprecated,
        'active' => active,
        _ => throw OpenCodeDecodeException(
            'Unknown ModelInfoStatus value: $value'),
      };
}

/// `Permission.Reply`
enum PermissionReply {
  once('once'),
  always('always'),
  reject('reject');

  const PermissionReply(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static PermissionReply fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static PermissionReply fromWire(String value) => switch (value) {
        'once' => once,
        'always' => always,
        'reject' => reject,
        _ => throw OpenCodeDecodeException(
            'Unknown PermissionReply value: $value'),
      };
}

/// `PersistentPtyInfoStatus`
enum PersistentPtyInfoStatus {
  running('running'),
  exited('exited');

  const PersistentPtyInfoStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static PersistentPtyInfoStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static PersistentPtyInfoStatus fromWire(String value) => switch (value) {
        'running' => running,
        'exited' => exited,
        _ => throw OpenCodeDecodeException(
            'Unknown PersistentPtyInfoStatus value: $value'),
      };
}

/// `ProviderInfoActivation`
enum ProviderInfoActivation {
  auto('auto'),
  enabled('enabled'),
  disabled('disabled');

  const ProviderInfoActivation(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ProviderInfoActivation fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ProviderInfoActivation fromWire(String value) => switch (value) {
        'auto' => auto,
        'enabled' => enabled,
        'disabled' => disabled,
        _ => throw OpenCodeDecodeException(
            'Unknown ProviderInfoActivation value: $value'),
      };
}

/// `PtyStatus`
enum PtyStatus {
  running('running'),
  exited('exited');

  const PtyStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static PtyStatus fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static PtyStatus fromWire(String value) => switch (value) {
        'running' => running,
        'exited' => exited,
        _ => throw OpenCodeDecodeException('Unknown PtyStatus value: $value'),
      };
}

/// `RpcInternalErrorType`
enum RpcInternalErrorType {
  rpcInternal('rpc.internal'),
  rpcInvalidOutput('rpc.invalid_output');

  const RpcInternalErrorType(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static RpcInternalErrorType fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static RpcInternalErrorType fromWire(String value) => switch (value) {
        'rpc.internal' => rpcInternal,
        'rpc.invalid_output' => rpcInvalidOutput,
        _ => throw OpenCodeDecodeException(
            'Unknown RpcInternalErrorType value: $value'),
      };
}

/// `Session.Inbox.Delivery`
enum SessionInboxDelivery {
  steer('steer'),
  queue('queue');

  const SessionInboxDelivery(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionInboxDelivery fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionInboxDelivery fromWire(String value) => switch (value) {
        'steer' => steer,
        'queue' => queue,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionInboxDelivery value: $value'),
      };
}

/// `SessionInfoOutcome`
enum SessionInfoOutcome {
  succeeded('succeeded'),
  failed('failed'),
  interrupted('interrupted');

  const SessionInfoOutcome(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionInfoOutcome fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionInfoOutcome fromWire(String value) => switch (value) {
        'succeeded' => succeeded,
        'failed' => failed,
        'interrupted' => interrupted,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionInfoOutcome value: $value'),
      };
}

/// `SessionMessageAssistantFinish`
enum SessionMessageAssistantFinish {
  stop('stop'),
  length('length'),
  toolCalls('tool-calls'),
  contentFilter('content-filter'),
  error('error'),
  unknown('unknown');

  const SessionMessageAssistantFinish(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageAssistantFinish fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageAssistantFinish fromWire(String value) =>
      switch (value) {
        'stop' => stop,
        'length' => length,
        'tool-calls' => toolCalls,
        'content-filter' => contentFilter,
        'error' => error,
        'unknown' => unknown,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageAssistantFinish value: $value'),
      };
}

/// `SessionMessageCompactionRunningReason`
enum SessionMessageCompactionRunningReason {
  auto('auto'),
  manual('manual');

  const SessionMessageCompactionRunningReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageCompactionRunningReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageCompactionRunningReason fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'manual' => manual,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageCompactionRunningReason value: $value'),
      };
}

/// `SessionMessageCompactionCompletedReason`
enum SessionMessageCompactionCompletedReason {
  auto('auto'),
  manual('manual');

  const SessionMessageCompactionCompletedReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageCompactionCompletedReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageCompactionCompletedReason fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'manual' => manual,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageCompactionCompletedReason value: $value'),
      };
}

/// `SessionMessageCompactionFailedReason`
enum SessionMessageCompactionFailedReason {
  auto('auto'),
  manual('manual');

  const SessionMessageCompactionFailedReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageCompactionFailedReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageCompactionFailedReason fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'manual' => manual,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageCompactionFailedReason value: $value'),
      };
}

/// `SessionMessageIdleOutcome`
enum SessionMessageIdleOutcome {
  succeeded('succeeded'),
  failed('failed'),
  interrupted('interrupted');

  const SessionMessageIdleOutcome(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageIdleOutcome fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageIdleOutcome fromWire(String value) => switch (value) {
        'succeeded' => succeeded,
        'failed' => failed,
        'interrupted' => interrupted,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageIdleOutcome value: $value'),
      };
}

/// `SessionMessageShellStatus`
enum SessionMessageShellStatus {
  running('running'),
  exited('exited'),
  timeout('timeout'),
  killed('killed');

  const SessionMessageShellStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageShellStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageShellStatus fromWire(String value) => switch (value) {
        'running' => running,
        'exited' => exited,
        'timeout' => timeout,
        'killed' => killed,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageShellStatus value: $value'),
      };
}

/// `ShellInfoStatus`
enum ShellInfoStatus {
  running('running'),
  exited('exited'),
  timeout('timeout'),
  killed('killed');

  const ShellInfoStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ShellInfoStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ShellInfoStatus fromWire(String value) => switch (value) {
        'running' => running,
        'exited' => exited,
        'timeout' => timeout,
        'killed' => killed,
        _ => throw OpenCodeDecodeException(
            'Unknown ShellInfoStatus value: $value'),
      };
}

/// `VcsBaseSource`
enum VcsBaseSource {
  reflog('reflog'),
  defaultValue('default');

  const VcsBaseSource(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static VcsBaseSource fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static VcsBaseSource fromWire(String value) => switch (value) {
        'reflog' => reflog,
        'default' => defaultValue,
        _ =>
          throw OpenCodeDecodeException('Unknown VcsBaseSource value: $value'),
      };
}

/// `VcsFileStatusStatus`
enum VcsFileStatusStatus {
  added('added'),
  deleted('deleted'),
  modified('modified');

  const VcsFileStatusStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static VcsFileStatusStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static VcsFileStatusStatus fromWire(String value) => switch (value) {
        'added' => added,
        'deleted' => deleted,
        'modified' => modified,
        _ => throw OpenCodeDecodeException(
            'Unknown VcsFileStatusStatus value: $value'),
      };
}

/// `Vcs.Mode`
enum VcsMode {
  working('working'),
  branch('branch'),
  committed('committed');

  const VcsMode(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static VcsMode fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static VcsMode fromWire(String value) => switch (value) {
        'working' => working,
        'branch' => branch,
        'committed' => committed,
        _ => throw OpenCodeDecodeException('Unknown VcsMode value: $value'),
      };
}

/// `FsFindType`
enum FsFindType {
  file('file'),
  directory('directory');

  const FsFindType(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static FsFindType fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static FsFindType fromWire(String value) => switch (value) {
        'file' => file,
        'directory' => directory,
        _ => throw OpenCodeDecodeException('Unknown FsFindType value: $value'),
      };
}

/// `ProjectListArchived`
enum ProjectListArchived {
  trueValue('true'),
  falseValue('false');

  const ProjectListArchived(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ProjectListArchived fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ProjectListArchived fromWire(String value) => switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown ProjectListArchived value: $value'),
      };
}

/// `SessionListOrder`
enum SessionListOrder {
  asc('asc'),
  desc('desc');

  const SessionListOrder(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionListOrder fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionListOrder fromWire(String value) => switch (value) {
        'asc' => asc,
        'desc' => desc,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionListOrder value: $value'),
      };
}

/// `ExperimentalSessionStatsTools`
enum ExperimentalSessionStatsTools {
  none('none'),
  summary('summary'),
  detail('detail');

  const ExperimentalSessionStatsTools(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ExperimentalSessionStatsTools fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ExperimentalSessionStatsTools fromWire(String value) =>
      switch (value) {
        'none' => none,
        'summary' => summary,
        'detail' => detail,
        _ => throw OpenCodeDecodeException(
            'Unknown ExperimentalSessionStatsTools value: $value'),
      };
}

/// `ExperimentalSessionExportSanitize`
enum ExperimentalSessionExportSanitize {
  trueValue('true'),
  falseValue('false');

  const ExperimentalSessionExportSanitize(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ExperimentalSessionExportSanitize fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ExperimentalSessionExportSanitize fromWire(String value) =>
      switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown ExperimentalSessionExportSanitize value: $value'),
      };
}

/// `SessionLogFollow`
enum SessionLogFollow {
  trueValue('true'),
  falseValue('false');

  const SessionLogFollow(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionLogFollow fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionLogFollow fromWire(String value) => switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionLogFollow value: $value'),
      };
}

/// `SessionInterruptResume`
enum SessionInterruptResume {
  trueValue('true'),
  falseValue('false');

  const SessionInterruptResume(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionInterruptResume fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionInterruptResume fromWire(String value) => switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionInterruptResume value: $value'),
      };
}

/// `SessionMessageListOrder`
enum SessionMessageListOrder {
  asc('asc'),
  desc('desc');

  const SessionMessageListOrder(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageListOrder fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageListOrder fromWire(String value) => switch (value) {
        'asc' => asc,
        'desc' => desc,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageListOrder value: $value'),
      };
}

/// `SessionMessageListType`
enum SessionMessageListType {
  agentSwitched('agent-switched'),
  modelSwitched('model-switched'),
  locationSwitched('location-switched'),
  user('user'),
  synthetic('synthetic'),
  system('system'),
  skill('skill'),
  shell('shell'),
  assistant('assistant'),
  compaction('compaction');

  const SessionMessageListType(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionMessageListType fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionMessageListType fromWire(String value) => switch (value) {
        'agent-switched' => agentSwitched,
        'model-switched' => modelSwitched,
        'location-switched' => locationSwitched,
        'user' => user,
        'synthetic' => synthetic,
        'system' => system,
        'skill' => skill,
        'shell' => shell,
        'assistant' => assistant,
        'compaction' => compaction,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageListType value: $value'),
      };
}
