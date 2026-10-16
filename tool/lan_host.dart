// ignore_for_file: avoid_print
/// LAN host + reverse proxy for the Flutter Web builds of this monorepo.
///
/// Serves the three apps and proxies the OpenCode API so phones on the same
/// Wi-Fi can use them without any build-time configuration:
///
/// ```sh
/// dart run tool/lan_host.dart [--port 8080] [--host 0.0.0.0]
/// ```
///
/// * `/openfit/` -> `gym_coach/build/web`
/// * `/chat/`    -> `chat_app/build/web`
/// * `/cockpit/` -> `opencode_cockpit/build/web`
/// * `/api/...`  -> the local OpenCode service, with Basic auth injected
/// * `/_upload`  -> raw bytes + `x-filename` -> a server-local temp file
///
/// The OpenCode service is discovered with `OpenCodeService.ensure()` (and
/// started when missing); this host never stops it.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:path/path.dart' as p;
import 'package:qr/qr.dart';

/// The path prefix every SDK call uses (read from
/// `lib/src/generated/resources/*.dart` and `lib/src/service/service_io.dart`).
const String _apiPrefix = '/api/';

/// Headers that belong to one hop and must not be forwarded.
const Set<String> _hopByHopHeaders = <String>{
  'connection',
  'keep-alive',
  'proxy-authenticate',
  'proxy-authorization',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
  'host',
  'expect',
  'accept-encoding',
};

/// One static app mount served under a URL prefix.
final class AppMount {
  /// Creates a mount.
  const AppMount({
    required this.prefix,
    required this.directory,
    required this.label,
    required this.buildCommand,
  });

  /// URL prefix, for example `/chat`.
  final String prefix;

  /// Build output directory, relative to the repository root.
  final String directory;

  /// Human-readable name for the index page.
  final String label;

  /// The exact command that produces the build.
  final String buildCommand;
}

const List<AppMount> _apps = <AppMount>[
  AppMount(
    prefix: '/openfit',
    directory: 'gym_coach/build/web',
    label: 'OpenFit (gym_coach)',
    buildCommand: 'flutter build web --release --base-href /openfit/',
  ),
  AppMount(
    prefix: '/chat',
    directory: 'chat_app/build/web',
    label: 'OpenCode Chat (chat_app)',
    buildCommand: 'flutter build web --release --base-href /chat/',
  ),
  AppMount(
    prefix: '/cockpit',
    directory: 'opencode_cockpit/build/web',
    label: 'OpenCode Cockpit (opencode_cockpit)',
    buildCommand: 'flutter build web --release --base-href /cockpit/',
  ),
];

Future<void> main(List<String> args) async {
  final options = _parseArgs(args);
  if (options == null) return;

  final repository = p.dirname(p.dirname(Platform.script.toFilePath()));

  // Discover (or start) the local OpenCode service; never stop it.
  print('Looking for the local OpenCode service...');
  final endpoint = await OpenCodeService.ensure(
    options: EnsureOptions(
      onStart: (reason, previous) =>
          print('Starting the OpenCode service ($reason, previous: $previous)'),
    ),
  );
  final authHeaders = OpenCodeService.headers(endpoint);

  final client = OpenCodeClient(baseUrl: endpoint.url, headers: authHeaders);
  String version;
  try {
    version = (await client.server.info()).version;
  } finally {
    client.close();
  }

  final server = await HttpServer.bind(options.host, options.port);
  // Effectively disables idle eviction so a phone can hold an SSE stream
  // open for as long as it likes.
  server.idleTimeout = const Duration(hours: 12);

  final host = _LanHost(
    repository: repository,
    endpoint: endpoint,
    authHeaders: authHeaders,
    version: version,
    upstream: HttpClient()
      ..autoUncompress = false
      ..idleTimeout = const Duration(hours: 12)
      ..connectionTimeout = const Duration(seconds: 10),
  );

  print('');
  print('OpenCode service: ${endpoint.url} (v$version)');
  print('LAN host:         http://${options.host}:${server.port}');
  print('');

  final addresses = await _lanAddresses(options.host);
  final base = 'http://${addresses.first}:${server.port}';
  print('Open these on your phone (same Wi-Fi):');
  print('  ${'$base/'.padRight(42)}(index)');
  for (final app in _apps) {
    print('  ${'$base${app.prefix}/'.padRight(42)}${app.label}');
  }
  print('');
  print('Scan to open the index:');
  _printQr('http://${addresses.first}:${server.port}/');
  print('');
  print('Keep this host running while you use the apps on your phone.');

  // Print the exact commands for builds that are missing.
  for (final app in _apps) {
    if (!await Directory(p.join(repository, app.directory)).exists()) {
      print('Missing build: ${app.directory}');
      print(
        '  cd ${p.split(app.directory).first} && ${app.buildCommand}',
      );
    }
  }

  // Shut the host down cleanly; the OpenCode service keeps running.
  void shutdown() {
    print('\nShutting down the LAN host (the OpenCode service keeps running).');
    unawaited(server.close(force: true));
  }

  ProcessSignal.sigint.watch().listen((_) => shutdown());
  ProcessSignal.sigterm.watch().listen((_) => shutdown());

  await for (final request in server) {
    unawaited(host.handle(request));
  }
  print('LAN host stopped.');
}

/// Parses the command line, printing usage and returning null on errors.
_LanHostOptions? _parseArgs(List<String> args) {
  var port = 8080;
  var host = '0.0.0.0';
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '--port':
        if (i + 1 >= args.length) {
          print('Missing value for --port');
          return null;
        }
        final parsed = int.tryParse(args[++i]);
        if (parsed == null || parsed < 0 || parsed > 65535) {
          print('Invalid port: ${args[i]}');
          return null;
        }
        port = parsed;
      case '--host':
        if (i + 1 >= args.length) {
          print('Missing value for --host');
          return null;
        }
        host = args[++i];
      case '--help':
      case '-h':
        print('Usage: dart run tool/lan_host.dart '
            '[--port 8080] [--host 0.0.0.0]');
        return null;
      default:
        print('Unknown argument: $arg');
        print('Usage: dart run tool/lan_host.dart '
            '[--port 8080] [--host 0.0.0.0]');
        return null;
    }
  }
  return _LanHostOptions(host: host, port: port);
}

final class _LanHostOptions {
  const _LanHostOptions({required this.host, required this.port});

  final String host;
  final int port;
}

/// One running LAN host.
final class _LanHost {
  _LanHost({
    required this.repository,
    required this.endpoint,
    required this.authHeaders,
    required this.version,
    required this.upstream,
  });

  final String repository;
  final ServiceEndpoint endpoint;
  final Map<String, String> authHeaders;
  final String version;
  final HttpClient upstream;
  final Set<String> _announcedMissingBuilds = <String>{};

  Future<void> handle(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        if (_isApiPath(path)) {
          await _proxyWebSocket(request);
        } else {
          await _notFound(request);
        }
        return;
      }
      if (request.method == 'POST' && path == '/_upload') {
        await _handleUpload(request);
        return;
      }
      if (path == '/' || path == '/index.html') {
        await _serveIndex(request);
        return;
      }
      if (_isApiPath(path)) {
        await _proxyApi(request);
        return;
      }
      for (final app in _apps) {
        if (path == app.prefix || path.startsWith('${app.prefix}/')) {
          await _serveApp(request, app);
          return;
        }
      }
      await _notFound(request);
    } on Object catch (error) {
      // The client may already be gone; answering is best effort.
      try {
        final response = request.response;
        response.statusCode = HttpStatus.internalServerError;
        response.headers.contentType = ContentType.text;
        response.write('LAN host error: $error');
        await response.close();
      } on Object {
        // Nothing more we can do.
      }
    }
  }

  static bool _isApiPath(String path) =>
      path == '/api' || path.startsWith(_apiPrefix);

  // ---------------------------------------------------------------------------
  // Index and static apps
  // ---------------------------------------------------------------------------

  Future<void> _serveIndex(HttpRequest request) async {
    final buffer = StringBuffer()
      ..writeln('<!doctype html>')
      ..writeln('<html lang="en"><head><meta charset="utf-8">')
      ..writeln('<meta name="viewport" content="width=device-width, '
          'initial-scale=1">')
      ..writeln('<title>OpenCode LAN host</title>')
      ..writeln('<style>body{font-family:system-ui,sans-serif;margin:2rem;'
          'max-width:40rem}code{background:#eee;padding:.1rem .3rem;'
          'border-radius:.2rem}li{margin:.4rem 0}</style>')
      ..writeln('</head><body>')
      ..writeln('<h1>OpenCode LAN host</h1>')
      ..writeln('<p>OpenCode service <code>${endpoint.url}</code> '
          '(v$version), Basic auth injected for the apps below.</p>')
      ..writeln('<ul>');
    for (final app in _apps) {
      buffer.writeln('<li><a href="${app.prefix}/">${app.label}</a></li>');
    }
    buffer
      ..writeln('</ul>')
      ..writeln('<p>Attachments: <code>POST /_upload</code> with the raw '
          'bytes and an <code>x-filename</code> header returns '
          '<code>{"path": "..."}</code>, a server-local path the OpenCode '
          'server can read.</p>')
      ..writeln('</body></html>');
    await _sendText(request, HttpStatus.ok, buffer.toString());
  }

  Future<void> _serveApp(HttpRequest request, AppMount app) async {
    if (request.method != 'GET' && request.method != 'HEAD') {
      await _sendText(
          request, HttpStatus.methodNotAllowed, 'Method not allowed');
      return;
    }
    final root = p.normalize(p.join(repository, app.directory));
    final index = File(p.join(root, 'index.html'));
    if (!await Directory(root).exists()) {
      await _servePlaceholder(request, app);
      return;
    }

    var relative = request.uri.path.substring(app.prefix.length);
    while (relative.startsWith('/')) {
      relative = relative.substring(1);
    }
    // Decode each segment separately so an encoded slash cannot smuggle a
    // path separator past the containment check below.
    final segments = <String>[];
    for (final segment in relative.split('/')) {
      if (segment.isEmpty) continue;
      try {
        segments.add(Uri.decodeComponent(segment));
      } on FormatException {
        await _notFound(request);
        return;
      }
    }
    final relativePath = segments.join('/');
    final resolved = p.normalize(p.join(root, relativePath));
    final withinRoot = resolved == root || p.isWithin(root, resolved);
    final candidate = withinRoot ? File(resolved) : null;
    if (candidate != null && await candidate.exists()) {
      await _sendFile(request, candidate);
      return;
    }
    // SPA fallback: extension-less subpaths resolve to the app shell; a
    // missing asset keeps a 404 so build problems are visible.
    if (!p.basename(relativePath).contains('.') && await index.exists()) {
      await _sendFile(request, index);
      return;
    }
    await _notFound(request);
  }

  Future<void> _servePlaceholder(HttpRequest request, AppMount app) async {
    final command = 'cd ${p.split(app.directory).first} && ${app.buildCommand}';
    if (_announcedMissingBuilds.add(app.directory)) {
      print('Missing build: ${app.directory}');
      print('  run: $command');
    }
    final html = '<!doctype html><html lang="en"><head>'
        '<meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        '<title>${app.label} — build missing</title>'
        '<style>body{font-family:system-ui,sans-serif;margin:2rem;'
        'max-width:40rem}pre{background:#111;color:#eee;padding:1rem;'
        'border-radius:.4rem;overflow-x:auto}</style></head><body>'
        '<h1>${app.label}</h1>'
        '<p>The web build is missing. Build it from the repository root '
        'with:</p>'
        '<pre>$command</pre>'
        '<p>then reload this page.</p>'
        '</body></html>';
    await _sendText(request, HttpStatus.ok, html);
  }

  Future<void> _notFound(HttpRequest request) =>
      _sendText(request, HttpStatus.notFound, 'Not found');

  Future<void> _sendText(
    HttpRequest request,
    int status,
    String body,
  ) async {
    final response = request.response;
    response.statusCode = status;
    response.headers.contentType = ContentType.html;
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    if (request.method == 'HEAD') {
      await response.close();
      return;
    }
    response.write(body);
    await response.close();
  }

  Future<void> _sendFile(HttpRequest request, File file) async {
    final response = request.response;
    response.statusCode = HttpStatus.ok;
    response.headers.contentType = _contentTypeFor(file.path);
    if (p.basename(file.path) == 'index.html') {
      response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
    }
    if (request.method == 'HEAD') {
      response.contentLength = await file.length();
      await response.close();
      return;
    }
    response.bufferOutput = false;
    await response.addStream(file.openRead());
    await response.close();
  }

  // ---------------------------------------------------------------------------
  // OpenCode API reverse proxy
  // ---------------------------------------------------------------------------

  Future<void> _proxyApi(HttpRequest request) async {
    final target = endpoint.url.replace(
      path: request.uri.path,
      query: request.uri.hasQuery ? request.uri.query : null,
    );
    final upstreamRequest = await upstream.openUrl(request.method, target);
    request.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (_hopByHopHeaders.contains(lower)) return;
      if (lower == HttpHeaders.contentLengthHeader) return;
      for (final value in values) {
        upstreamRequest.headers.add(name, value);
      }
    });
    // Inject the service credentials; never forward a client-provided one.
    for (final entry in authHeaders.entries) {
      upstreamRequest.headers.set(entry.key, entry.value);
    }

    final contentLength = request.headers.contentLength;
    if (request.method != 'GET' && request.method != 'HEAD') {
      if (contentLength >= 0) {
        upstreamRequest.contentLength = contentLength;
      } else {
        upstreamRequest.headers.chunkedTransferEncoding = true;
      }
      await upstreamRequest.addStream(request);
    }
    final upstreamResponse = await upstreamRequest.close();

    final response = request.response;
    response.statusCode = upstreamResponse.statusCode;
    response.reasonPhrase = upstreamResponse.reasonPhrase;
    upstreamResponse.headers.forEach((name, values) {
      final lower = name.toLowerCase();
      if (_hopByHopHeaders.contains(lower)) return;
      for (final value in values) {
        response.headers.add(name, value);
      }
    });
    // SSE must stream immediately: no buffering anywhere along the pipe.
    response.bufferOutput = false;
    await response.addStream(upstreamResponse);
    await response.close();
  }

  // ---------------------------------------------------------------------------
  // PTY WebSocket proxy
  // ---------------------------------------------------------------------------

  Future<void> _proxyWebSocket(HttpRequest request) async {
    final WebSocket local;
    try {
      local = await WebSocketTransformer.upgrade(request);
    } on Object {
      return;
    }
    final uri = Uri(
      scheme: endpoint.url.scheme == 'https' ? 'wss' : 'ws',
      host: endpoint.url.host,
      port: endpoint.url.port,
      path: request.uri.path,
      query: request.uri.hasQuery ? request.uri.query : null,
    );
    final WebSocket upstreamSocket;
    try {
      upstreamSocket = await WebSocket.connect(
        uri.toString(),
        headers: authHeaders,
      );
    } on Object {
      await local.close(
        WebSocketStatus.internalServerError,
        'OpenCode service unavailable',
      );
      return;
    }
    _bridgeWebSockets(local, upstreamSocket);
  }

  static void _bridgeWebSockets(WebSocket left, WebSocket right) {
    var closed = false;
    void closeAll() {
      if (closed) return;
      closed = true;
      unawaited(left.close());
      unawaited(right.close());
    }

    left.listen(
      right.add,
      onDone: closeAll,
      onError: (Object _) => closeAll(),
      cancelOnError: true,
    );
    right.listen(
      left.add,
      onDone: closeAll,
      onError: (Object _) => closeAll(),
      cancelOnError: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Uploads
  // ---------------------------------------------------------------------------

  Future<void> _handleUpload(HttpRequest request) async {
    final name = _sanitizeFilename(
      request.headers.value('x-filename') ?? 'upload.bin',
    );
    final directory = Directory(
      p.join(Directory.systemTemp.path, 'openfit-uploads'),
    );
    await directory.create(recursive: true);
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    final random = _random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    final file = File(p.join(directory.path, '$stamp-$random-$name'));
    final sink = file.openWrite();
    try {
      await sink.addStream(request);
    } finally {
      await sink.close();
    }
    final response = request.response;
    response.statusCode = HttpStatus.ok;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(<String, String>{'path': file.absolute.path}));
    await response.close();
  }

  static final Random _random = Random();

  /// Keeps only the base name and a conservative character set.
  static String _sanitizeFilename(String value) {
    final base = value.split(RegExp(r'[/\\]')).last;
    var cleaned = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    while (cleaned.startsWith('.')) {
      cleaned = cleaned.substring(1);
    }
    if (cleaned.isEmpty) cleaned = 'upload.bin';
    return cleaned.length > 120 ? cleaned.substring(0, 120) : cleaned;
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

/// Content type for [path], or `application/octet-stream`.
ContentType _contentTypeFor(String path) {
  switch (p.extension(path).toLowerCase()) {
    case '.html':
      return ContentType.html;
    case '.js':
      return ContentType('text', 'javascript', charset: 'utf-8');
    case '.css':
      return ContentType('text', 'css', charset: 'utf-8');
    case '.json':
    case '.map':
      return ContentType.json;
    case '.wasm':
      return ContentType('application', 'wasm');
    case '.txt':
      return ContentType.text;
    case '.xml':
      return ContentType('application', 'xml');
    case '.svg':
      return ContentType('image', 'svg+xml');
    case '.png':
      return ContentType('image', 'png');
    case '.jpg':
    case '.jpeg':
      return ContentType('image', 'jpeg');
    case '.gif':
      return ContentType('image', 'gif');
    case '.webp':
      return ContentType('image', 'webp');
    case '.ico':
      return ContentType('image', 'x-icon');
    case '.ttf':
      return ContentType('font', 'ttf');
    case '.otf':
      return ContentType('font', 'otf');
    case '.woff':
      return ContentType('font', 'woff');
    case '.woff2':
      return ContentType('font', 'woff2');
    case '.mp3':
      return ContentType('audio', 'mpeg');
    case '.wav':
      return ContentType('audio', 'wav');
    case '.mp4':
      return ContentType('video', 'mp4');
    case '.webm':
      return ContentType('video', 'webm');
    case '.pdf':
      return ContentType('application', 'pdf');
    default:
      return ContentType.binary;
  }
}

/// Candidate LAN addresses, preferring 192.168.x, 10.x and 172.16-31.x.
Future<List<String>> _lanAddresses(String bindHost) async {
  if (bindHost != '0.0.0.0' && bindHost != '::' && bindHost.isNotEmpty) {
    return <String>[bindHost];
  }
  final addresses = <InternetAddress>[];
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
    for (final interface in interfaces) {
      addresses.addAll(interface.addresses);
    }
  } on Object {
    // Fall through to the loopback fallback.
  }
  int score(InternetAddress address) {
    final text = address.address;
    if (text.startsWith('192.168.')) return 0;
    if (text.startsWith('10.')) return 1;
    if (RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(text)) return 2;
    return 3;
  }

  addresses.sort(
    (left, right) => score(left).compareTo(score(right)),
  );
  if (addresses.isEmpty) return <String>['127.0.0.1'];
  return addresses.map((address) => address.address).toList();
}

/// Renders [data] as an ASCII QR code using half-height blocks.
void _printQr(String data) {
  final code = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );
  final image = QrImage(code);
  const quiet = 2;
  final size = code.moduleCount;
  bool dark(int row, int col) {
    final r = row - quiet;
    final c = col - quiet;
    if (r < 0 || c < 0 || r >= size || c >= size) return false;
    return image.isDark(r, c);
  }

  final full = size + quiet * 2;
  for (var row = 0; row < full; row += 2) {
    final buffer = StringBuffer();
    for (var col = 0; col < full; col++) {
      final top = dark(row, col);
      final bottom = row + 1 < full && dark(row + 1, col);
      buffer.write(
        top && bottom
            ? '\u2588' // full block
            : top
                ? '\u2580' // upper half block
                : bottom
                    ? '\u2584' // lower half block
                    : ' ',
      );
    }
    print(buffer.toString());
  }
}
