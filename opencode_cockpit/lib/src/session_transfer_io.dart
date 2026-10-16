/// Desktop session transfer: transcripts live in user-chosen files.
library;

import 'dart:io';

/// Desktop always transfers through filesystem paths.
bool get sessionTransferUsesPaths => true;

/// `~/Downloads/opencode-<id>.json`, matching the previous behavior.
String suggestedExportPath(String sessionID) {
  final home = Platform.environment['HOME'] ?? '.';
  return '$home/Downloads/opencode-$sessionID.json';
}

/// `~/Downloads/opencode-session.json`.
String suggestedImportPath() {
  final home = Platform.environment['HOME'] ?? '.';
  return '$home/Downloads/opencode-session.json';
}

/// Writes [json] to [path] (creating parent directories) and returns the
/// written path. [fileName] is only used by the web implementation.
Future<String> saveSessionJson({
  String? path,
  required String fileName,
  required String json,
}) async {
  final file = File(path ?? fileName);
  await file.parent.create(recursive: true);
  await file.writeAsString(json);
  return file.path;
}

/// Reads the transcript stored at [path]; null when [path] is null.
Future<String?> readSessionJson({String? path}) async {
  if (path == null) return null;
  return File(path).readAsString();
}
