/// Picking a file to send to the server with a plan or chat turn.
library;

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart'
    show PromptInputFileAttachment;

import 'attachments_stub.dart'
    if (dart.library.io) 'attachments_io.dart'
    if (dart.library.js_interop) 'attachments_web.dart';

/// A file the athlete picked, ready to attach to a prompt.
final class PickedAttachment {
  /// Creates an attachment.
  const PickedAttachment({required this.attachment, required this.label});

  /// The server attachment: a `file://` URL on desktop, the path returned by
  /// the host's upload proxy on the web.
  final PromptInputFileAttachment attachment;

  /// A short human-readable label, e.g. the file name.
  final String label;
}

/// Opens the platform file picker and prepares the chosen file.
///
/// Returns null when the athlete cancels or the file cannot be prepared (for
/// example when the web upload endpoint is unavailable).
Future<PickedAttachment?> pickAttachment() => pickAttachmentPlatform();
