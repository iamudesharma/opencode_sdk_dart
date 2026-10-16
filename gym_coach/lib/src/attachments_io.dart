/// Desktop attachment picking: the local path travels as a `file://` URL.
library;

import 'package:file_selector/file_selector.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart'
    show PromptInputFileAttachment;

import 'attachments.dart';

/// Opens the native picker; the bridge turns `file://` URLs into local paths.
Future<PickedAttachment?> pickAttachmentPlatform() async {
  final file = await openFile();
  if (file == null) return null;
  return PickedAttachment(
    attachment: PromptInputFileAttachment(uri: 'file://${file.path}'),
    label: file.name,
  );
}
