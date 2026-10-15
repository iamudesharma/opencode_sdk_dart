// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Permission.Rule`
final class PermissionRule {
  const PermissionRule({
    required this.action,
    required this.resource,
    required this.effect,
  });

  factory PermissionRule.fromJson(Map<String, Object?> json) => PermissionRule(
        action: decodeString(json, 'action'),
        resource: decodeString(json, 'resource'),
        effect: PermissionEffect.fromJson(json['effect']),
      );

  final String action;
  final String resource;
  final PermissionEffect effect;

  Map<String, Object?> toJson() => <String, Object?>{
        'action': action,
        'resource': resource,
        'effect': effect.wire,
      };
}

/// `Permission.Request`
final class PermissionRequest {
  const PermissionRequest({
    required this.id,
    required this.sessionID,
    required this.action,
    required this.resources,
    this.save,
    this.metadata,
    this.source,
    this.message,
  });

  factory PermissionRequest.fromJson(Map<String, Object?> json) =>
      PermissionRequest(
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

/// `PermissionSaved.Info`
final class PermissionSavedInfo {
  const PermissionSavedInfo({
    required this.id,
    required this.projectID,
    required this.action,
    required this.resource,
    required this.time,
  });

  factory PermissionSavedInfo.fromJson(Map<String, Object?> json) =>
      PermissionSavedInfo(
        id: PermissionSavedID.fromJson(asJsonString(json['id'])),
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        action: decodeString(json, 'action'),
        resource: decodeString(json, 'resource'),
        time: PermissionSavedInfoTime.fromJson(asJsonMap(json['time'])),
      );

  final PermissionSavedID id;
  final ProjectID projectID;
  final String action;
  final String resource;
  final PermissionSavedInfoTime time;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'projectID': projectID,
        'action': action,
        'resource': resource,
        'time': time.toJson(),
      };
}
