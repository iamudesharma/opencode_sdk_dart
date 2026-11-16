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

/// `Artifact.Capability`
enum ArtifactCapability {
  staticValue('static'),
  serverCode('server-code'),
  sqlite('sqlite'),
  durableObjects('durable-objects');

  const ArtifactCapability(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ArtifactCapability fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ArtifactCapability fromWire(String value) => switch (value) {
        'static' => staticValue,
        'server-code' => serverCode,
        'sqlite' => sqlite,
        'durable-objects' => durableObjects,
        _ => throw OpenCodeDecodeException(
            'Unknown ArtifactCapability value: $value'),
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
  integrationConnect('integration.connect'),
  integrationUse('integration.use'),
  mcpUse('mcp.use'),
  skillUse('skill.use'),
  pluginUse('plugin.use'),
  websearchUse('websearch.use');

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
        'integration.connect' => integrationConnect,
        'integration.use' => integrationUse,
        'mcp.use' => mcpUse,
        'skill.use' => skillUse,
        'plugin.use' => pluginUse,
        'websearch.use' => websearchUse,
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
  integrationConnect('integration.connect'),
  integrationUse('integration.use'),
  mcpUse('mcp.use'),
  skillUse('skill.use'),
  pluginUse('plugin.use'),
  websearchUse('websearch.use');

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
        'integration.connect' => integrationConnect,
        'integration.use' => integrationUse,
        'mcp.use' => mcpUse,
        'skill.use' => skillUse,
        'plugin.use' => pluginUse,
        'websearch.use' => websearchUse,
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

/// `Tool.FreeformFormat`
enum ToolFreeformFormat {
  text('text'),
  regex('regex'),
  lark('lark');

  const ToolFreeformFormat(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ToolFreeformFormat fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ToolFreeformFormat fromWire(String value) => switch (value) {
        'text' => text,
        'regex' => regex,
        'lark' => lark,
        _ => throw OpenCodeDecodeException(
            'Unknown ToolFreeformFormat value: $value'),
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

/// `Model.MediaInput`
enum ModelMediaInput {
  assets('assets'),
  state('state'),
  root('root');

  const ModelMediaInput(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ModelMediaInput fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ModelMediaInput fromWire(String value) => switch (value) {
        'assets' => assets,
        'state' => state,
        'root' => root,
        _ => throw OpenCodeDecodeException(
            'Unknown ModelMediaInput value: $value'),
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

/// `Job.Status`
enum JobStatus {
  running('running'),
  completed('completed'),
  error('error'),
  cancelled('cancelled');

  const JobStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static JobStatus fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static JobStatus fromWire(String value) => switch (value) {
        'running' => running,
        'completed' => completed,
        'error' => error,
        'cancelled' => cancelled,
        _ => throw OpenCodeDecodeException('Unknown JobStatus value: $value'),
      };
}

/// `Job.Kind`
enum JobKind {
  shell('shell'),
  subagent('subagent'),
  image('image');

  const JobKind(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static JobKind fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static JobKind fromWire(String value) => switch (value) {
        'shell' => shell,
        'subagent' => subagent,
        'image' => image,
        _ => throw OpenCodeDecodeException('Unknown JobKind value: $value'),
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

/// `ProviderRequestErrorReason`
enum ProviderRequestErrorReason {
  authentication('authentication'),
  rateLimit('rate_limit'),
  contentFilter('content_filter'),
  invalidRequest('invalid_request'),
  overloaded('overloaded'),
  provider('provider');

  const ProviderRequestErrorReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ProviderRequestErrorReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ProviderRequestErrorReason fromWire(String value) => switch (value) {
        'authentication' => authentication,
        'rate_limit' => rateLimit,
        'content_filter' => contentFilter,
        'invalid_request' => invalidRequest,
        'overloaded' => overloaded,
        'provider' => provider,
        _ => throw OpenCodeDecodeException(
            'Unknown ProviderRequestErrorReason value: $value'),
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

/// `Schedule.Status`
enum ScheduleStatus {
  active('active'),
  paused('paused'),
  done('done');

  const ScheduleStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ScheduleStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ScheduleStatus fromWire(String value) => switch (value) {
        'active' => active,
        'paused' => paused,
        'done' => done,
        _ =>
          throw OpenCodeDecodeException('Unknown ScheduleStatus value: $value'),
      };
}

/// `Schedule.Outcome`
enum ScheduleOutcome {
  fired('fired'),
  lateValue('late'),
  checked('checked'),
  expired('expired'),
  skipped('skipped'),
  disabled('disabled'),
  failed('failed');

  const ScheduleOutcome(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ScheduleOutcome fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ScheduleOutcome fromWire(String value) => switch (value) {
        'fired' => fired,
        'late' => lateValue,
        'checked' => checked,
        'expired' => expired,
        'skipped' => skipped,
        'disabled' => disabled,
        'failed' => failed,
        _ => throw OpenCodeDecodeException(
            'Unknown ScheduleOutcome value: $value'),
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

/// `SessionExecutionInterruptedDataReason`
enum SessionExecutionInterruptedDataReason {
  user('user'),
  shutdown('shutdown'),
  superseded('superseded'),
  inactivity('inactivity');

  const SessionExecutionInterruptedDataReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionExecutionInterruptedDataReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionExecutionInterruptedDataReason fromWire(String value) =>
      switch (value) {
        'user' => user,
        'shutdown' => shutdown,
        'superseded' => superseded,
        'inactivity' => inactivity,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionExecutionInterruptedDataReason value: $value'),
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

/// `SessionStepEndedDataFinish`
enum SessionStepEndedDataFinish {
  stop('stop'),
  length('length'),
  toolCalls('tool-calls'),
  contentFilter('content-filter'),
  error('error'),
  unknown('unknown');

  const SessionStepEndedDataFinish(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionStepEndedDataFinish fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionStepEndedDataFinish fromWire(String value) => switch (value) {
        'stop' => stop,
        'length' => length,
        'tool-calls' => toolCalls,
        'content-filter' => contentFilter,
        'error' => error,
        'unknown' => unknown,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionStepEndedDataFinish value: $value'),
      };
}

/// `SessionCompactionStartedDataReason`
enum SessionCompactionStartedDataReason {
  auto('auto'),
  manual('manual');

  const SessionCompactionStartedDataReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionCompactionStartedDataReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionCompactionStartedDataReason fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'manual' => manual,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionCompactionStartedDataReason value: $value'),
      };
}

/// `SessionCompactionEndedDataReason`
enum SessionCompactionEndedDataReason {
  auto('auto'),
  manual('manual');

  const SessionCompactionEndedDataReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionCompactionEndedDataReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionCompactionEndedDataReason fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'manual' => manual,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionCompactionEndedDataReason value: $value'),
      };
}

/// `SessionCompactionFailedDataReason`
enum SessionCompactionFailedDataReason {
  auto('auto'),
  manual('manual');

  const SessionCompactionFailedDataReason(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionCompactionFailedDataReason fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionCompactionFailedDataReason fromWire(String value) =>
      switch (value) {
        'auto' => auto,
        'manual' => manual,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionCompactionFailedDataReason value: $value'),
      };
}

/// `SessionUsageRecordedDataSource`
enum SessionUsageRecordedDataSource {
  title('title'),
  compaction('compaction'),
  generate('generate');

  const SessionUsageRecordedDataSource(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionUsageRecordedDataSource fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionUsageRecordedDataSource fromWire(String value) =>
      switch (value) {
        'title' => title,
        'compaction' => compaction,
        'generate' => generate,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionUsageRecordedDataSource value: $value'),
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

/// `UsageLimitsBudgetScope`
enum UsageLimitsBudgetScope {
  each('each'),
  combined('combined');

  const UsageLimitsBudgetScope(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static UsageLimitsBudgetScope fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static UsageLimitsBudgetScope fromWire(String value) => switch (value) {
        'each' => each,
        'combined' => combined,
        _ => throw OpenCodeDecodeException(
            'Unknown UsageLimitsBudgetScope value: $value'),
      };
}

/// `UsageLimitsBudgetPer`
enum UsageLimitsBudgetPer {
  set('set'),
  model('model');

  const UsageLimitsBudgetPer(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static UsageLimitsBudgetPer fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static UsageLimitsBudgetPer fromWire(String value) => switch (value) {
        'set' => set,
        'model' => model,
        _ => throw OpenCodeDecodeException(
            'Unknown UsageLimitsBudgetPer value: $value'),
      };
}

/// `UsageLimitsBudgetCoverage`
enum UsageLimitsBudgetCoverage {
  all('all'),
  models('models');

  const UsageLimitsBudgetCoverage(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static UsageLimitsBudgetCoverage fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static UsageLimitsBudgetCoverage fromWire(String value) => switch (value) {
        'all' => all,
        'models' => models,
        _ => throw OpenCodeDecodeException(
            'Unknown UsageLimitsBudgetCoverage value: $value'),
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

/// `Vcs.Untracked`
enum VcsUntracked {
  files('files'),
  folders('folders');

  const VcsUntracked(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static VcsUntracked fromJson(Object? value) => fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static VcsUntracked fromWire(String value) => switch (value) {
        'files' => files,
        'folders' => folders,
        _ =>
          throw OpenCodeDecodeException('Unknown VcsUntracked value: $value'),
      };
}

/// `VoiceTransportType`
enum VoiceTransportType {
  webrtc('webrtc'),
  websocket('websocket');

  const VoiceTransportType(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static VoiceTransportType fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static VoiceTransportType fromWire(String value) => switch (value) {
        'webrtc' => webrtc,
        'websocket' => websocket,
        _ => throw OpenCodeDecodeException(
            'Unknown VoiceTransportType value: $value'),
      };
}

/// `FilesystemChangedDataEvent`
enum FilesystemChangedDataEvent {
  add('add'),
  change('change'),
  unlink('unlink');

  const FilesystemChangedDataEvent(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static FilesystemChangedDataEvent fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static FilesystemChangedDataEvent fromWire(String value) => switch (value) {
        'add' => add,
        'change' => change,
        'unlink' => unlink,
        _ => throw OpenCodeDecodeException(
            'Unknown FilesystemChangedDataEvent value: $value'),
      };
}

/// `ShellExitedDataStatus`
enum ShellExitedDataStatus {
  running('running'),
  exited('exited'),
  timeout('timeout'),
  killed('killed');

  const ShellExitedDataStatus(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ShellExitedDataStatus fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ShellExitedDataStatus fromWire(String value) => switch (value) {
        'running' => running,
        'exited' => exited,
        'timeout' => timeout,
        'killed' => killed,
        _ => throw OpenCodeDecodeException(
            'Unknown ShellExitedDataStatus value: $value'),
      };
}

/// `TuiToastShowDataVariant`
enum TuiToastShowDataVariant {
  info('info'),
  success('success'),
  warning('warning'),
  error('error');

  const TuiToastShowDataVariant(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static TuiToastShowDataVariant fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static TuiToastShowDataVariant fromWire(String value) => switch (value) {
        'info' => info,
        'success' => success,
        'warning' => warning,
        'error' => error,
        _ => throw OpenCodeDecodeException(
            'Unknown TuiToastShowDataVariant value: $value'),
      };
}

/// `ExperimentalJobListDescendants`
enum ExperimentalJobListDescendants {
  trueValue('true'),
  falseValue('false');

  const ExperimentalJobListDescendants(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ExperimentalJobListDescendants fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ExperimentalJobListDescendants fromWire(String value) =>
      switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown ExperimentalJobListDescendants value: $value'),
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

/// `SessionListArchived`
enum SessionListArchived {
  trueValue('true'),
  falseValue('false');

  const SessionListArchived(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static SessionListArchived fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static SessionListArchived fromWire(String value) => switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionListArchived value: $value'),
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

/// `ExperimentalSessionLogFollow`
enum ExperimentalSessionLogFollow {
  trueValue('true'),
  falseValue('false');

  const ExperimentalSessionLogFollow(this.wire);

  /// The wire value.
  final String wire;

  /// Decodes a wire value into an enum member.
  static ExperimentalSessionLogFollow fromJson(Object? value) =>
      fromWire(asJsonString(value));

  /// Decodes a wire value into an enum member.
  static ExperimentalSessionLogFollow fromWire(String value) => switch (value) {
        'true' => trueValue,
        'false' => falseValue,
        _ => throw OpenCodeDecodeException(
            'Unknown ExperimentalSessionLogFollow value: $value'),
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
  compaction('compaction'),
  idle('idle');

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
        'idle' => idle,
        _ => throw OpenCodeDecodeException(
            'Unknown SessionMessageListType value: $value'),
      };
}
