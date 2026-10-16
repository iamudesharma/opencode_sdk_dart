/// Web attachment picking: upload the bytes through the host's proxy.
library;

import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart'
    show PromptInputFileAttachment;

import 'attachments.dart';

/// Picks a file, POSTs its bytes to `/_upload`, and uses the returned path.
///
/// The browser cannot hand the server a local path, so a LAN host proxies
/// uploads: the response's `path` is what the OpenCode server can read.
Future<PickedAttachment?> pickAttachmentPlatform() async {
  try {
    final file = await openFile();
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final response = await http.post(
      Uri.base.resolve('/_upload'),
      headers: {'x-filename': file.name},
      body: bytes,
    );
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return null;
    final path = decoded['path'];
    if (path is! String || path.isEmpty) return null;
    return PickedAttachment(
      attachment: PromptInputFileAttachment(uri: path),
      label: file.name,
    );
  } on Object {
    // A cancelled dialog or a missing upload endpoint: nothing to attach.
    return null;
  }
}
