/// Web session transfer: transcripts download as Blobs and import through the
/// browser's file picker.
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The web build uses browser downloads and file picks, not paths.
bool get sessionTransferUsesPaths => false;

/// Plain file name; the browser decides the download directory.
String suggestedExportPath(String sessionID) => 'opencode-$sessionID.json';

/// Plain file name; the picker decides the source directory.
String suggestedImportPath() => 'opencode-session.json';

/// Triggers a Blob download of [json] named [fileName] and returns that name.
Future<String> saveSessionJson({
  String? path,
  required String fileName,
  required String json,
}) async {
  final blob = web.Blob(
    [json.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return fileName;
}

/// Opens an `<input type="file">` picker and resolves with the selected
/// transcript text; null when the user cancels.
Future<String?> readSessionJson({String? path}) {
  final completer = Completer<String?>();
  void complete(String? text) {
    if (!completer.isCompleted) completer.complete(text);
  }

  final input = web.document.createElement('input') as web.HTMLInputElement
    ..type = 'file'
    ..accept = '.json,application/json';
  input.onchange = ((web.Event event) {
    final files = input.files;
    final file = files == null || files.length == 0 ? null : files.item(0);
    if (file == null) {
      complete(null);
      return;
    }
    file.text().toDart.then(
      (text) => complete(text.toDart),
      onError: (Object error) => complete(null),
    );
  }).toJS;
  input.oncancel = ((web.Event event) {
    complete(null);
  }).toJS;
  input.click();
  return completer.future;
}
