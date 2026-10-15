// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `Vcs.Base`
final class VcsBase {
  const VcsBase({
    required this.name,
    required this.ref,
    required this.source,
  });

  factory VcsBase.fromJson(Map<String, Object?> json) => VcsBase(
        name: decodeString(json, 'name'),
        ref: decodeString(json, 'ref'),
        source: VcsBaseSource.fromJson(json['source']),
      );

  final String name;
  final String ref;
  final VcsBaseSource source;

  Map<String, Object?> toJson() => <String, Object?>{
        'name': name,
        'ref': ref,
        'source': source.wire,
      };
}

/// `Vcs.Branch`
final class VcsBranch {
  const VcsBranch({
    this.current,
    this.defaultValue,
  });

  factory VcsBranch.fromJson(Map<String, Object?> json) => VcsBranch(
        current: decodeOptionalString(json, 'current'),
        defaultValue: decodeOptionalString(json, 'default'),
      );

  final String? current;

  /// Wire field: `default`.
  final String? defaultValue;

  Map<String, Object?> toJson() => <String, Object?>{
        if (current != null) 'current': current!,
        if (defaultValue != null) 'default': defaultValue!,
      };
}

/// `Vcs.FileStatus`
final class VcsFileStatus {
  const VcsFileStatus({
    required this.file,
    required this.additions,
    required this.deletions,
    required this.status,
  });

  factory VcsFileStatus.fromJson(Map<String, Object?> json) => VcsFileStatus(
        file: decodeString(json, 'file'),
        additions: decodeInt(json, 'additions'),
        deletions: decodeInt(json, 'deletions'),
        status: VcsFileStatusStatus.fromJson(json['status']),
      );

  final String file;
  final int additions;
  final int deletions;
  final VcsFileStatusStatus status;

  Map<String, Object?> toJson() => <String, Object?>{
        'file': file,
        'additions': additions,
        'deletions': deletions,
        'status': status.wire,
      };
}

/// `Vcs.Info`
final class VcsInfo {
  const VcsInfo({
    this.provider,
    required this.branch,
  });

  factory VcsInfo.fromJson(Map<String, Object?> json) => VcsInfo(
        provider: decodeOptionalString(json, 'provider'),
        branch: VcsBranch.fromJson(asJsonMap(json['branch'])),
      );

  final String? provider;
  final VcsBranch branch;

  Map<String, Object?> toJson() => <String, Object?>{
        if (provider != null) 'provider': provider!,
        'branch': branch.toJson(),
      };
}

/// `Worktree.CreateInput`
final class WorktreeCreateInput {
  const WorktreeCreateInput({
    required this.projectID,
    this.from,
    this.branch,
    this.directory,
    this.name,
  });

  factory WorktreeCreateInput.fromJson(Map<String, Object?> json) =>
      WorktreeCreateInput(
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        from: json['from'] == null
            ? null
            : AbsolutePath.fromJson(asJsonString(json['from'])),
        branch: decodeOptionalString(json, 'branch'),
        directory: json['directory'] == null
            ? null
            : AbsolutePath.fromJson(asJsonString(json['directory'])),
        name: decodeOptionalString(json, 'name'),
      );

  final ProjectID projectID;
  final AbsolutePath? from;
  final String? branch;
  final AbsolutePath? directory;
  final String? name;

  Map<String, Object?> toJson() => <String, Object?>{
        'projectID': projectID,
        if (from != null) 'from': from!,
        if (branch != null) 'branch': branch!,
        if (directory != null) 'directory': directory!,
        if (name != null) 'name': name!,
      };
}

/// `Worktree.Directory`
final class WorktreeDirectory {
  const WorktreeDirectory({
    required this.directory,
    this.strategy,
  });

  factory WorktreeDirectory.fromJson(Map<String, Object?> json) =>
      WorktreeDirectory(
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
        strategy: decodeOptionalString(json, 'strategy'),
      );

  final AbsolutePath directory;
  final String? strategy;

  Map<String, Object?> toJson() => <String, Object?>{
        'directory': directory,
        if (strategy != null) 'strategy': strategy!,
      };
}

/// `Worktree.Info`
final class WorktreeInfo {
  const WorktreeInfo({
    required this.directory,
  });

  factory WorktreeInfo.fromJson(Map<String, Object?> json) => WorktreeInfo(
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
      );

  final AbsolutePath directory;

  Map<String, Object?> toJson() => <String, Object?>{
        'directory': directory,
      };
}

/// `Worktree.RemoveInput`
final class WorktreeRemoveInput {
  const WorktreeRemoveInput({
    required this.projectID,
    required this.directory,
    required this.force,
  });

  factory WorktreeRemoveInput.fromJson(Map<String, Object?> json) =>
      WorktreeRemoveInput(
        projectID: ProjectID.fromJson(asJsonString(json['projectID'])),
        directory: AbsolutePath.fromJson(asJsonString(json['directory'])),
        force: decodeBool(json, 'force'),
      );

  final ProjectID projectID;
  final AbsolutePath directory;
  final bool force;

  Map<String, Object?> toJson() => <String, Object?>{
        'projectID': projectID,
        'directory': directory,
        'force': force,
      };
}
