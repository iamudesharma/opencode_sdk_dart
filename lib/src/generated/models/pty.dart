// GENERATED CODE - DO NOT MODIFY BY HAND
part of '../models.dart';
// ignore_for_file: prefer_if_null_operators, unnecessary_lambdas, use_super_parameters

/// `PersistentPty.CreateInput`
final class PersistentPtyCreateInput {
  const PersistentPtyCreateInput({
    this.command,
    required this.args,
    this.cwd,
    required this.title,
    required this.env,
    this.size,
  });

  factory PersistentPtyCreateInput.fromJson(Map<String, Object?> json) =>
      PersistentPtyCreateInput(
        command: decodeOptionalString(json, 'command'),
        args: jsonList(json['args'], (item) => asJsonString(item)),
        cwd: decodeOptionalString(json, 'cwd'),
        title: decodeString(json, 'title'),
        env: asJsonMap(json['env']),
        size: json['size'] == null
            ? null
            : PersistentPtyCreateInputSize.fromJson(asJsonMap(json['size'])),
      );

  final String? command;
  final List<String> args;
  final String? cwd;
  final String title;
  final Map<String, Object?> env;
  final PersistentPtyCreateInputSize? size;

  Map<String, Object?> toJson() => <String, Object?>{
        if (command != null) 'command': command!,
        'args': args,
        if (cwd != null) 'cwd': cwd!,
        'title': title,
        'env': env,
        if (size != null) 'size': size!.toJson(),
      };
}

/// `PersistentPty.Handoff`
final class PersistentPtyHandoff {
  const PersistentPtyHandoff({
    required this.directory,
    required this.instanceID,
    required this.ticket,
    required this.expiresAt,
  });

  factory PersistentPtyHandoff.fromJson(Map<String, Object?> json) =>
      PersistentPtyHandoff(
        directory: decodeString(json, 'directory'),
        instanceID: decodeString(json, 'instanceID'),
        ticket: decodeString(json, 'ticket'),
        expiresAt: json['expiresAt'],
      );

  final String directory;
  final String instanceID;
  final String ticket;
  final Object? expiresAt;

  Map<String, Object?> toJson() => <String, Object?>{
        'directory': directory,
        'instanceID': instanceID,
        'ticket': ticket,
        'expiresAt': expiresAt,
      };
}

/// `PersistentPty.Info`
final class PersistentPtyInfo {
  const PersistentPtyInfo({
    required this.id,
    required this.title,
    required this.command,
    required this.args,
    required this.cwd,
    required this.status,
    required this.pid,
    this.exitCode,
    required this.sessionID,
    required this.foregroundProcess,
    required this.size,
    required this.output,
  });

  factory PersistentPtyInfo.fromJson(Map<String, Object?> json) =>
      PersistentPtyInfo(
        id: PtyID.fromJson(asJsonString(json['id'])),
        title: decodeString(json, 'title'),
        command: decodeString(json, 'command'),
        args: jsonList(json['args'], (item) => asJsonString(item)),
        cwd: decodeString(json, 'cwd'),
        status: PersistentPtyInfoStatus.fromJson(json['status']),
        pid: decodeInt(json, 'pid'),
        exitCode: decodeOptionalInt(json, 'exitCode'),
        sessionID: SessionID.fromJson(asJsonString(json['sessionID'])),
        foregroundProcess: decodeOptionalString(json, 'foregroundProcess'),
        size: PersistentPtyInfoSize.fromJson(asJsonMap(json['size'])),
        output: PersistentPtyInfoOutput.fromJson(asJsonMap(json['output'])),
      );

  final PtyID id;
  final String title;
  final String command;
  final List<String> args;
  final String cwd;
  final PersistentPtyInfoStatus status;
  final int pid;
  final int? exitCode;
  final SessionID sessionID;
  final String? foregroundProcess;
  final PersistentPtyInfoSize size;
  final PersistentPtyInfoOutput output;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'command': command,
        'args': args,
        'cwd': cwd,
        'status': status.wire,
        'pid': pid,
        if (exitCode != null) 'exitCode': exitCode!,
        'sessionID': sessionID,
        if (foregroundProcess != null) 'foregroundProcess': foregroundProcess!,
        'size': size.toJson(),
        'output': output.toJson(),
      };
}

/// `PersistentPty.ReadResult`
final class PersistentPtyReadResult {
  const PersistentPtyReadResult({
    required this.ptyID,
    required this.title,
    required this.cwd,
    required this.foregroundProcess,
    required this.screen,
  });

  factory PersistentPtyReadResult.fromJson(Map<String, Object?> json) =>
      PersistentPtyReadResult(
        ptyID: PtyID.fromJson(asJsonString(json['ptyID'])),
        title: decodeString(json, 'title'),
        cwd: decodeString(json, 'cwd'),
        foregroundProcess: decodeOptionalString(json, 'foregroundProcess'),
        screen:
            PersistentPtyReadResultScreen.fromJson(asJsonMap(json['screen'])),
      );

  final PtyID ptyID;
  final String title;
  final String cwd;
  final String? foregroundProcess;
  final PersistentPtyReadResultScreen screen;

  Map<String, Object?> toJson() => <String, Object?>{
        'ptyID': ptyID,
        'title': title,
        'cwd': cwd,
        if (foregroundProcess != null) 'foregroundProcess': foregroundProcess!,
        'screen': screen.toJson(),
      };
}

/// `PersistentPty.Snapshot`
final class PersistentPtySnapshot {
  const PersistentPtySnapshot({
    required this.info,
    required this.text,
    required this.checkpoint,
    required this.cursor,
  });

  factory PersistentPtySnapshot.fromJson(Map<String, Object?> json) =>
      PersistentPtySnapshot(
        info: PersistentPtyInfo.fromJson(asJsonMap(json['info'])),
        text: decodeString(json, 'text'),
        checkpoint: decodeString(json, 'checkpoint'),
        cursor: PersistentPtySnapshotCursor.fromJson(asJsonMap(json['cursor'])),
      );

  final PersistentPtyInfo info;
  final String text;
  final String checkpoint;
  final PersistentPtySnapshotCursor cursor;

  Map<String, Object?> toJson() => <String, Object?>{
        'info': info.toJson(),
        'text': text,
        'checkpoint': checkpoint,
        'cursor': cursor.toJson(),
      };
}

/// `PersistentPty.UpdateInput`
final class PersistentPtyUpdateInput {
  const PersistentPtyUpdateInput({
    this.attachmentID,
    required this.size,
  });

  factory PersistentPtyUpdateInput.fromJson(Map<String, Object?> json) =>
      PersistentPtyUpdateInput(
        attachmentID: decodeOptionalString(json, 'attachmentID'),
        size: PersistentPtyUpdateInputSize.fromJson(asJsonMap(json['size'])),
      );

  final String? attachmentID;
  final PersistentPtyUpdateInputSize size;

  Map<String, Object?> toJson() => <String, Object?>{
        if (attachmentID != null) 'attachmentID': attachmentID!,
        'size': size.toJson(),
      };
}

/// `Pty`
final class Pty {
  const Pty({
    required this.id,
    required this.title,
    required this.command,
    required this.args,
    required this.cwd,
    required this.status,
    required this.pid,
    this.exitCode,
  });

  factory Pty.fromJson(Map<String, Object?> json) => Pty(
        id: PtyID.fromJson(asJsonString(json['id'])),
        title: decodeString(json, 'title'),
        command: decodeString(json, 'command'),
        args: jsonList(json['args'], (item) => asJsonString(item)),
        cwd: decodeString(json, 'cwd'),
        status: PtyStatus.fromJson(json['status']),
        pid: decodeInt(json, 'pid'),
        exitCode: decodeOptionalInt(json, 'exitCode'),
      );

  final PtyID id;
  final String title;
  final String command;
  final List<String> args;
  final String cwd;
  final PtyStatus status;
  final int pid;
  final int? exitCode;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'command': command,
        'args': args,
        'cwd': cwd,
        'status': status.wire,
        'pid': pid,
        if (exitCode != null) 'exitCode': exitCode!,
      };
}
