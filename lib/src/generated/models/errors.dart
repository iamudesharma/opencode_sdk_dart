// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `AgentNotFoundErrorEncoded`
final class AgentNotFoundError extends OpenCodeApiException {
  AgentNotFoundError({
    required this.agentID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'AgentNotFoundError', message: message, raw: raw);

  factory AgentNotFoundError.fromJson(Map<String, Object?> json) =>
      AgentNotFoundError(
        agentID: decodeString(json, 'agentID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String agentID;

  Map<String, Object?> toJson() => <String, Object?>{
        'agentID': agentID,
      };
}

/// `CommandExecutionErrorEncoded`
final class CommandExecutionError extends OpenCodeApiException {
  CommandExecutionError({
    required this.command,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'CommandExecutionError', message: message, raw: raw);

  factory CommandExecutionError.fromJson(Map<String, Object?> json) =>
      CommandExecutionError(
        command: decodeString(json, 'command'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String command;

  Map<String, Object?> toJson() => <String, Object?>{
        'command': command,
      };
}

/// `CommandNotFoundErrorEncoded`
final class CommandNotFoundError extends OpenCodeApiException {
  CommandNotFoundError({
    required this.command,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'CommandNotFoundError', message: message, raw: raw);

  factory CommandNotFoundError.fromJson(Map<String, Object?> json) =>
      CommandNotFoundError(
        command: decodeString(json, 'command'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String command;

  Map<String, Object?> toJson() => <String, Object?>{
        'command': command,
      };
}

/// `ConflictErrorEncoded`
final class ConflictError extends OpenCodeApiException {
  ConflictError({
    this.resource,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'ConflictError', message: message, raw: raw);

  factory ConflictError.fromJson(Map<String, Object?> json) => ConflictError(
        resource: decodeOptionalString(json, 'resource'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String? resource;

  Map<String, Object?> toJson() => <String, Object?>{
        if (resource != null) 'resource': resource!,
      };
}

/// `FileNotFoundErrorEncoded`
final class FileNotFoundError extends OpenCodeApiException {
  FileNotFoundError({
    required this.path,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'FileNotFoundError', message: message, raw: raw);

  factory FileNotFoundError.fromJson(Map<String, Object?> json) =>
      FileNotFoundError(
        path: decodeString(json, 'path'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String path;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
      };
}

/// `ForbiddenErrorEncoded`
final class ForbiddenError extends OpenCodeApiException {
  ForbiddenError({
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'ForbiddenError', message: message, raw: raw);

  factory ForbiddenError.fromJson(Map<String, Object?> json) => ForbiddenError(
        message: asJsonString(json['message']),
        raw: json,
      );

  Map<String, Object?> toJson() => <String, Object?>{};
}

/// `FormAlreadySettledErrorEncoded`
final class FormAlreadySettledError extends OpenCodeApiException {
  FormAlreadySettledError({
    required this.id,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'FormAlreadySettledError', message: message, raw: raw);

  factory FormAlreadySettledError.fromJson(Map<String, Object?> json) =>
      FormAlreadySettledError(
        id: decodeString(json, 'id'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String id;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
      };
}

/// `FormInvalidAnswerErrorEncoded`
final class FormInvalidAnswerError extends OpenCodeApiException {
  FormInvalidAnswerError({
    required this.id,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'FormInvalidAnswerError', message: message, raw: raw);

  factory FormInvalidAnswerError.fromJson(Map<String, Object?> json) =>
      FormInvalidAnswerError(
        id: decodeString(json, 'id'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String id;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
      };
}

/// `FormNotFoundErrorEncoded`
final class FormNotFoundError extends OpenCodeApiException {
  FormNotFoundError({
    required this.id,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'FormNotFoundError', message: message, raw: raw);

  factory FormNotFoundError.fromJson(Map<String, Object?> json) =>
      FormNotFoundError(
        id: decodeString(json, 'id'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String id;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
      };
}

/// `InstructionEntryValueTooLargeErrorEncoded`
final class InstructionEntryValueTooLargeError extends OpenCodeApiException {
  InstructionEntryValueTooLargeError({
    required this.actualBytes,
    required this.maxBytes,
    required String message,
    Map<String, Object?>? raw,
  }) : super(
            tag: 'InstructionEntryValueTooLargeError',
            message: message,
            raw: raw);

  factory InstructionEntryValueTooLargeError.fromJson(
          Map<String, Object?> json) =>
      InstructionEntryValueTooLargeError(
        actualBytes: decodeInt(json, 'actualBytes'),
        maxBytes: decodeInt(json, 'maxBytes'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final int actualBytes;
  final int maxBytes;

  Map<String, Object?> toJson() => <String, Object?>{
        'actualBytes': actualBytes,
        'maxBytes': maxBytes,
      };
}

/// `IntegrationAttemptNotFoundErrorEncoded`
final class IntegrationAttemptNotFoundError extends OpenCodeApiException {
  IntegrationAttemptNotFoundError({
    required this.integrationID,
    required this.attemptID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(
            tag: 'IntegrationAttemptNotFoundError', message: message, raw: raw);

  factory IntegrationAttemptNotFoundError.fromJson(Map<String, Object?> json) =>
      IntegrationAttemptNotFoundError(
        integrationID: decodeString(json, 'integrationID'),
        attemptID: decodeString(json, 'attemptID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String integrationID;
  final String attemptID;

  Map<String, Object?> toJson() => <String, Object?>{
        'integrationID': integrationID,
        'attemptID': attemptID,
      };
}

/// `IntegrationMethodNotFoundErrorEncoded`
final class IntegrationMethodNotFoundError extends OpenCodeApiException {
  IntegrationMethodNotFoundError({
    required this.integrationID,
    required this.methodID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'IntegrationMethodNotFoundError', message: message, raw: raw);

  factory IntegrationMethodNotFoundError.fromJson(Map<String, Object?> json) =>
      IntegrationMethodNotFoundError(
        integrationID: decodeString(json, 'integrationID'),
        methodID: decodeString(json, 'methodID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String integrationID;
  final String methodID;

  Map<String, Object?> toJson() => <String, Object?>{
        'integrationID': integrationID,
        'methodID': methodID,
      };
}

/// `IntegrationNotFoundErrorEncoded`
final class IntegrationNotFoundError extends OpenCodeApiException {
  IntegrationNotFoundError({
    required this.integrationID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'IntegrationNotFoundError', message: message, raw: raw);

  factory IntegrationNotFoundError.fromJson(Map<String, Object?> json) =>
      IntegrationNotFoundError(
        integrationID: decodeString(json, 'integrationID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String integrationID;

  Map<String, Object?> toJson() => <String, Object?>{
        'integrationID': integrationID,
      };
}

/// `InvalidCursorErrorEncoded`
final class InvalidCursorError extends OpenCodeApiException {
  InvalidCursorError({
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'InvalidCursorError', message: message, raw: raw);

  factory InvalidCursorError.fromJson(Map<String, Object?> json) =>
      InvalidCursorError(
        message: asJsonString(json['message']),
        raw: json,
      );

  Map<String, Object?> toJson() => <String, Object?>{};
}

/// `InvalidRequestErrorEncoded`
final class InvalidRequestError extends OpenCodeApiException {
  InvalidRequestError({
    this.kind,
    this.field,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'InvalidRequestError', message: message, raw: raw);

  factory InvalidRequestError.fromJson(Map<String, Object?> json) =>
      InvalidRequestError(
        kind: decodeOptionalString(json, 'kind'),
        field: decodeOptionalString(json, 'field'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String? kind;
  final String? field;

  Map<String, Object?> toJson() => <String, Object?>{
        if (kind != null) 'kind': kind!,
        if (field != null) 'field': field!,
      };
}

/// `LocationNotFoundErrorEncoded`
final class LocationNotFoundError extends OpenCodeApiException {
  LocationNotFoundError({
    required this.location,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'LocationNotFoundError', message: message, raw: raw);

  factory LocationNotFoundError.fromJson(Map<String, Object?> json) =>
      LocationNotFoundError(
        location: LocationRef.fromJson(json['location']),
        message: asJsonString(json['message']),
        raw: json,
      );

  final LocationRef location;

  Map<String, Object?> toJson() => <String, Object?>{
        'location': location.toJson(),
      };
}

/// `McpServerNotFoundErrorEncoded`
final class McpServerNotFoundError extends OpenCodeApiException {
  McpServerNotFoundError({
    required this.server,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'McpServerNotFoundError', message: message, raw: raw);

  factory McpServerNotFoundError.fromJson(Map<String, Object?> json) =>
      McpServerNotFoundError(
        server: decodeString(json, 'server'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String server;

  Map<String, Object?> toJson() => <String, Object?>{
        'server': server,
      };
}

/// `MessageNotFoundErrorEncoded`
final class MessageNotFoundError extends OpenCodeApiException {
  MessageNotFoundError({
    required this.sessionID,
    required this.messageID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'MessageNotFoundError', message: message, raw: raw);

  factory MessageNotFoundError.fromJson(Map<String, Object?> json) =>
      MessageNotFoundError(
        sessionID: decodeString(json, 'sessionID'),
        messageID: decodeString(json, 'messageID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String sessionID;
  final String messageID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
        'messageID': messageID,
      };
}

/// `PermissionNotFoundErrorEncoded`
final class PermissionNotFoundError extends OpenCodeApiException {
  PermissionNotFoundError({
    required this.requestID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'PermissionNotFoundError', message: message, raw: raw);

  factory PermissionNotFoundError.fromJson(Map<String, Object?> json) =>
      PermissionNotFoundError(
        requestID: decodeString(json, 'requestID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String requestID;

  Map<String, Object?> toJson() => <String, Object?>{
        'requestID': requestID,
      };
}

/// `ProjectNotFoundErrorEncoded`
final class ProjectNotFoundError extends OpenCodeApiException {
  ProjectNotFoundError({
    required this.projectID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'ProjectNotFoundError', message: message, raw: raw);

  factory ProjectNotFoundError.fromJson(Map<String, Object?> json) =>
      ProjectNotFoundError(
        projectID: decodeString(json, 'projectID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String projectID;

  Map<String, Object?> toJson() => <String, Object?>{
        'projectID': projectID,
      };
}

/// `ProviderNotFoundErrorEncoded`
final class ProviderNotFoundError extends OpenCodeApiException {
  ProviderNotFoundError({
    required this.providerID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'ProviderNotFoundError', message: message, raw: raw);

  factory ProviderNotFoundError.fromJson(Map<String, Object?> json) =>
      ProviderNotFoundError(
        providerID: decodeString(json, 'providerID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String providerID;

  Map<String, Object?> toJson() => <String, Object?>{
        'providerID': providerID,
      };
}

/// `PtyNotFoundErrorEncoded`
final class PtyNotFoundError extends OpenCodeApiException {
  PtyNotFoundError({
    required this.ptyID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'PtyNotFoundError', message: message, raw: raw);

  factory PtyNotFoundError.fromJson(Map<String, Object?> json) =>
      PtyNotFoundError(
        ptyID: decodeString(json, 'ptyID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String ptyID;

  Map<String, Object?> toJson() => <String, Object?>{
        'ptyID': ptyID,
      };
}

/// `RpcErrorEncoded`
final class RpcError extends OpenCodeApiException {
  RpcError({
    required this.type,
    this.data,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'RpcError', message: message, raw: raw);

  factory RpcError.fromJson(Map<String, Object?> json) => RpcError(
        type: decodeString(json, 'type'),
        data: json['data'],
        message: asJsonString(json['message']),
        raw: json,
      );

  final String type;
  final Object? data;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        if (data != null) 'data': data!,
      };
}

/// `RpcInternalErrorEncoded`
final class RpcInternalError extends OpenCodeApiException {
  RpcInternalError({
    required this.type,
    this.data,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'RpcInternalError', message: message, raw: raw);

  factory RpcInternalError.fromJson(Map<String, Object?> json) =>
      RpcInternalError(
        type: RpcInternalErrorType.fromJson(json['type']),
        data: json['data'],
        message: asJsonString(json['message']),
        raw: json,
      );

  final RpcInternalErrorType type;
  final Object? data;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type.wire,
        if (data != null) 'data': data!,
      };
}

/// `ServiceUnavailableErrorEncoded`
final class ServiceUnavailableError extends OpenCodeApiException {
  ServiceUnavailableError({
    this.service,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'ServiceUnavailableError', message: message, raw: raw);

  factory ServiceUnavailableError.fromJson(Map<String, Object?> json) =>
      ServiceUnavailableError(
        service: decodeOptionalString(json, 'service'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String? service;

  Map<String, Object?> toJson() => <String, Object?>{
        if (service != null) 'service': service!,
      };
}

/// `SessionBusyErrorEncoded`
final class SessionBusyError extends OpenCodeApiException {
  SessionBusyError({
    required this.sessionID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'SessionBusyError', message: message, raw: raw);

  factory SessionBusyError.fromJson(Map<String, Object?> json) =>
      SessionBusyError(
        sessionID: decodeString(json, 'sessionID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `SessionNotFoundErrorEncoded`
final class SessionNotFoundError extends OpenCodeApiException {
  SessionNotFoundError({
    required this.sessionID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'SessionNotFoundError', message: message, raw: raw);

  factory SessionNotFoundError.fromJson(Map<String, Object?> json) =>
      SessionNotFoundError(
        sessionID: decodeString(json, 'sessionID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String sessionID;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionID': sessionID,
      };
}

/// `ShellNotFoundErrorEncoded`
final class ShellNotFoundError extends OpenCodeApiException {
  ShellNotFoundError({
    required this.id,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'ShellNotFoundError', message: message, raw: raw);

  factory ShellNotFoundError.fromJson(Map<String, Object?> json) =>
      ShellNotFoundError(
        id: decodeString(json, 'id'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String id;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
      };
}

/// `SkillNotFoundErrorEncoded`
final class SkillNotFoundError extends OpenCodeApiException {
  SkillNotFoundError({
    required this.skill,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'SkillNotFoundError', message: message, raw: raw);

  factory SkillNotFoundError.fromJson(Map<String, Object?> json) =>
      SkillNotFoundError(
        skill: SkillID.fromJson(asJsonString(json['skill'])),
        message: asJsonString(json['message']),
        raw: json,
      );

  final SkillID skill;

  Map<String, Object?> toJson() => <String, Object?>{
        'skill': skill,
      };
}

/// `UnauthorizedErrorEncoded`
final class UnauthorizedError extends OpenCodeApiException {
  UnauthorizedError({
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'UnauthorizedError', message: message, raw: raw);

  factory UnauthorizedError.fromJson(Map<String, Object?> json) =>
      UnauthorizedError(
        message: asJsonString(json['message']),
        raw: json,
      );

  Map<String, Object?> toJson() => <String, Object?>{};
}

/// `UnknownErrorEncoded`
final class UnknownError extends OpenCodeApiException {
  UnknownError({
    this.ref,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'UnknownError', message: message, raw: raw);

  factory UnknownError.fromJson(Map<String, Object?> json) => UnknownError(
        ref: decodeOptionalString(json, 'ref'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String? ref;

  Map<String, Object?> toJson() => <String, Object?>{
        if (ref != null) 'ref': ref!,
      };
}

/// `VcsInitNotSupportedErrorEncoded`
final class VcsInitNotSupportedError extends OpenCodeApiException {
  VcsInitNotSupportedError({
    required this.providerID,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'VcsInitNotSupportedError', message: message, raw: raw);

  factory VcsInitNotSupportedError.fromJson(Map<String, Object?> json) =>
      VcsInitNotSupportedError(
        providerID: decodeString(json, 'providerID'),
        message: asJsonString(json['message']),
        raw: json,
      );

  final String providerID;

  Map<String, Object?> toJson() => <String, Object?>{
        'providerID': providerID,
      };
}

/// `WorktreeErrorEncoded`
final class WorktreeError extends OpenCodeApiException {
  WorktreeError({
    required this.data,
    required String message,
    Map<String, Object?>? raw,
  }) : super(tag: 'WorktreeError', message: message, raw: raw);

  factory WorktreeError.fromJson(Map<String, Object?> json) => WorktreeError(
        data: WorktreeErrorData.fromJson(asJsonMap(json['data'])),
        message: asJsonString(json['message']),
        raw: json,
      );

  final WorktreeErrorData data;

  /// Always `WorktreeError`.
  String get name => 'WorktreeError';

  Map<String, Object?> toJson() => <String, Object?>{
        'name': 'WorktreeError',
        'data': data.toJson(),
      };
}

/// Decodes a structured API error from a response body.
///
/// Returns `null` when the body does not carry a known error.
OpenCodeApiException? decodeOpenCodeException(int statusCode, Object? body) {
  if (body is! Map) return null;
  final json = asJsonMap(body);
  final tag = json['_tag'];
  if (tag is! String) return null;
  return switch (tag) {
    'AgentNotFoundError' => AgentNotFoundError.fromJson(json),
    'CommandExecutionError' => CommandExecutionError.fromJson(json),
    'CommandNotFoundError' => CommandNotFoundError.fromJson(json),
    'ConflictError' => ConflictError.fromJson(json),
    'FileNotFoundError' => FileNotFoundError.fromJson(json),
    'ForbiddenError' => ForbiddenError.fromJson(json),
    'FormAlreadySettledError' => FormAlreadySettledError.fromJson(json),
    'FormInvalidAnswerError' => FormInvalidAnswerError.fromJson(json),
    'FormNotFoundError' => FormNotFoundError.fromJson(json),
    'InstructionEntryValueTooLargeError' =>
      InstructionEntryValueTooLargeError.fromJson(json),
    'IntegrationAttemptNotFoundError' =>
      IntegrationAttemptNotFoundError.fromJson(json),
    'IntegrationMethodNotFoundError' =>
      IntegrationMethodNotFoundError.fromJson(json),
    'IntegrationNotFoundError' => IntegrationNotFoundError.fromJson(json),
    'InvalidCursorError' => InvalidCursorError.fromJson(json),
    'InvalidRequestError' => InvalidRequestError.fromJson(json),
    'LocationNotFoundError' => LocationNotFoundError.fromJson(json),
    'McpServerNotFoundError' => McpServerNotFoundError.fromJson(json),
    'MessageNotFoundError' => MessageNotFoundError.fromJson(json),
    'PermissionNotFoundError' => PermissionNotFoundError.fromJson(json),
    'ProjectNotFoundError' => ProjectNotFoundError.fromJson(json),
    'ProviderNotFoundError' => ProviderNotFoundError.fromJson(json),
    'PtyNotFoundError' => PtyNotFoundError.fromJson(json),
    'RpcError' => RpcError.fromJson(json),
    'RpcInternalError' => RpcInternalError.fromJson(json),
    'ServiceUnavailableError' => ServiceUnavailableError.fromJson(json),
    'SessionBusyError' => SessionBusyError.fromJson(json),
    'SessionNotFoundError' => SessionNotFoundError.fromJson(json),
    'ShellNotFoundError' => ShellNotFoundError.fromJson(json),
    'SkillNotFoundError' => SkillNotFoundError.fromJson(json),
    'UnauthorizedError' => UnauthorizedError.fromJson(json),
    'UnknownError' => UnknownError.fromJson(json),
    'VcsInitNotSupportedError' => VcsInitNotSupportedError.fromJson(json),
    'WorktreeError' => WorktreeError.fromJson(json),
    _ => null,
  };
}
