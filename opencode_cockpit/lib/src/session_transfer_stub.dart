/// Fallback session transfer implementation for unsupported platforms.
library;

/// Whether transfer goes through filesystem paths.
bool get sessionTransferUsesPaths => true;

/// Suggested export destination (unsupported platforms have no suggestion).
String suggestedExportPath(String sessionID) => 'opencode-$sessionID.json';

/// Suggested import source (unsupported platforms have no suggestion).
String suggestedImportPath() => 'opencode-session.json';

/// Unsupported: writing transcripts requires `dart:io` or a browser.
Future<String> saveSessionJson({
  String? path,
  required String fileName,
  required String json,
}) {
  throw UnsupportedError('Session transfer is not supported on this platform');
}

/// Unsupported: reading transcripts requires `dart:io` or a browser.
Future<String?> readSessionJson({String? path}) {
  throw UnsupportedError('Session transfer is not supported on this platform');
}
