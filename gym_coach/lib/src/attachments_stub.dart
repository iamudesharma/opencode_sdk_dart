/// Fallback attachment picking for platforms with no picker.
library;

import 'attachments.dart';

/// There is no file picker on this platform.
Future<PickedAttachment?> pickAttachmentPlatform() async => null;
