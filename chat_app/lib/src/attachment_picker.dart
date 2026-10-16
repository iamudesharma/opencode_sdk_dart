import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// A file chosen for the next prompt.
final class PickedAttachment {
  const PickedAttachment({required this.name, required this.path});

  /// Display name (the file's basename).
  final String name;

  /// The location the OpenCode server can read: an absolute path on desktop,
  /// the LAN host's stored path on the web.
  final String path;
}

/// Raised when a web upload to the LAN host fails.
final class AttachmentUploadException implements Exception {
  const AttachmentUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Picks a file and resolves a path the OpenCode server can read.
///
/// Desktop returns the picked file's absolute path. The web has no filesystem
/// access, so the bytes are posted to the LAN host's same-origin `/_upload`
/// endpoint, which stores the file and returns `{"path": "..."}`.
Future<PickedAttachment?> pickAttachment() async {
  final file = await openFile();
  if (file == null) return null;
  if (!kIsWeb) {
    return PickedAttachment(name: file.name, path: file.path);
  }
  final bytes = await file.readAsBytes();
  final http.Response response;
  try {
    response = await http.post(
      Uri.base.resolve('/_upload'),
      headers: {'x-filename': file.name},
      body: bytes,
    );
  } on Object catch (error) {
    throw AttachmentUploadException('Upload failed: $error');
  }
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw AttachmentUploadException(
      'Upload failed (HTTP ${response.statusCode})',
    );
  }
  Object? decoded;
  try {
    decoded = jsonDecode(response.body);
  } on FormatException {
    throw const AttachmentUploadException('Upload returned invalid JSON');
  }
  final path = decoded is Map ? decoded['path'] : null;
  if (path is! String || path.isEmpty) {
    throw const AttachmentUploadException('Upload returned no path');
  }
  return PickedAttachment(name: file.name, path: path);
}
