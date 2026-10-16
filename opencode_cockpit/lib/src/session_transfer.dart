/// Session export/import primitives with platform-aware transfer.
///
/// Desktop builds transfer transcripts through filesystem paths; the web build
/// downloads a Blob and reads through the browser's file picker instead. The
/// controller and shell talk to this facade so `dart:io` never leaks into the
/// shared code.
library;

export 'session_transfer_stub.dart'
    if (dart.library.io) 'session_transfer_io.dart'
    if (dart.library.js_interop) 'session_transfer_web.dart';
