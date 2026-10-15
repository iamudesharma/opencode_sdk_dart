/// Background service discovery and lifecycle for `dart:io` platforms.
///
/// This mirrors the reference `@opencode/client/service` implementation:
///
/// * `discover()` returns a healthy registered endpoint without starting a
///   process;
/// * `ensure()` returns a compatible service, starting one when needed;
/// * `stop()` stops the exact registered service instance (SIGTERM, then
///   SIGKILL);
/// * `headers(endpoint)` creates the Basic authentication headers.
///
/// Persistent terminal handoff (`OPENCODE_PTY_HANDOFF`) is ported as well so
/// replacements can preserve persistent terminals.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../core/json_utils.dart';
import 'service_endpoint.dart';

/// Entry point for background service management.
abstract final class OpenCodeService {
  /// Returns a healthy registered endpoint without starting a process.
  ///
  /// Returns `null` when no registration exists, the service is not ready,
  /// the health protocol is not understood, or the version constraint does
  /// not match.
  static Future<ServiceEndpoint?> discover({
    EnsureOptions options = const EnsureOptions(),
  }) async {
    final probe =
        await _probeRegistration(options.file, options.requestTimeout);
    final service = probe.service;
    if (service == null) return null;
    if (service.state != ServiceState.ready) return null;
    if (!service.compatible) return null;
    if (!_matchesVersion(service.version, options.version)) return null;
    return service.endpoint;
  }

  /// Returns a compatible service, starting one when needed.
  ///
  /// Mirrors the reference implementation: poll the registration file, probe
  /// health, replace a service that fails the version constraint, recover from
  /// an unresponsive registration, and spawn `opencode serve --service`
  /// (configurable through [EnsureOptions.command]) when nothing is
  /// registered.
  static Future<ServiceEndpoint> ensure({
    EnsureOptions options = const EnsureOptions(),
  }) async {
    final deadline = DateTime.now().add(options.promiseTimeout);
    var announced = false;
    void announce(ServiceStartReason reason, String? previousVersion) {
      if (announced) return;
      announced = true;
      options.onStart?.call(reason, previousVersion);
    }

    var spawnDelay = options.spawnDelay;
    var lastSpawn = DateTime.fromMillisecondsSinceEpoch(0);
    var timeoutCount = 0;
    ServiceInfo? timedOutInfo;

    while (true) {
      if (DateTime.now().isAfter(deadline)) {
        throw StateError(
          'Timed out waiting for the background service to start',
        );
      }
      final probe = await _probeRegistration(
        options.file,
        options.requestTimeout,
      );
      final probeInfo = probe.info;
      if (probe.timedOut && probeInfo != null) {
        timeoutCount =
            timedOutInfo != null && _sameInfo(timedOutInfo, probeInfo)
                ? timeoutCount + 1
                : 1;
        timedOutInfo = probeInfo;
        if (timeoutCount >= 3) {
          announce(ServiceStartReason.missing, null);
          await _clearPtyHandoff(options.file);
          await _terminate(probeInfo, options);
          timedOutInfo = null;
          timeoutCount = 0;
        }
      } else {
        timedOutInfo = null;
        timeoutCount = 0;
      }

      final service = probe.service;
      if (service != null) {
        if (!_matchesVersion(service.version, options.version)) {
          announce(ServiceStartReason.versionMismatch, service.version);
          await _preparePtyHandoff(options.file, service.info, options)
              .catchError((Object _) {});
          await _terminate(service.info, options);
        } else if (!service.compatible) {
          throw StateError(
            'Background service uses an incompatible health protocol. '
            'Update this client or explicitly restart the service.',
          );
        } else if (service.state == ServiceState.ready) {
          await _completePtyHandoff(options.file, service.info);
          return service.endpoint;
        } else if (service.state == ServiceState.failed) {
          throw StateError('Background service failed to start');
        }
      } else {
        final now = DateTime.now();
        if (now.difference(lastSpawn) >= spawnDelay) {
          announce(ServiceStartReason.missing, null);
          await _spawn(options);
          lastSpawn = now;
          final doubled = spawnDelay * 2;
          spawnDelay =
              doubled > options.maxSpawnDelay ? options.maxSpawnDelay : doubled;
        }
      }
      await Future<void>.delayed(options.pollInterval);
    }
  }

  /// Stops the exact registered service instance.
  static Future<void> stop({
    EnsureOptions options = const EnsureOptions(),
  }) async {
    final info = await _readRegistration(options.file);
    if (info == null) return;
    await _terminate(info, options);
  }

  /// Creates the authentication headers for [endpoint].
  static Map<String, String> headers(ServiceEndpoint endpoint) =>
      endpoint.headers();

  /// The default registration file path.
  static String defaultFile() => _defaultServiceFile();

  // ---------------------------------------------------------------------------
  // Registration file handling
  // ---------------------------------------------------------------------------

  static Future<ServiceInfo?> _readRegistration(String? file) async {
    final handle = File(file ?? _defaultServiceFile());
    if (!await handle.exists()) return null;
    try {
      final text = await handle.readAsString();
      if (text.isEmpty) return null;
      return ServiceInfo.parse(jsonDecode(text));
    } on Object {
      return null;
    }
  }

  static Future<void> _deleteIfSame(String? file, ServiceInfo info) async {
    final latest = await _readRegistration(file);
    if (latest == null || !_sameInfo(latest, info)) return;
    final handle = File(file ?? _defaultServiceFile());
    try {
      await handle.delete();
    } on Object {
      // Another client may have removed the file first.
    }
  }

  static bool _sameInfo(ServiceInfo left, ServiceInfo right) =>
      left.id == right.id &&
      left.version == right.version &&
      left.url == right.url &&
      left.pid == right.pid;

  static bool _matchesVersion(
    String? version,
    ServiceVersionConstraint? constraint,
  ) {
    if (constraint == null) return true;
    if (version == null) return false;
    return constraint.matches(version);
  }

  // ---------------------------------------------------------------------------
  // Health probes
  // ---------------------------------------------------------------------------

  static Future<_ProbeResult> _probeRegistration(
    String? file,
    Duration timeout,
  ) async {
    final info = await _readRegistration(file);
    if (info == null) {
      return const _ProbeResult(info: null, service: null, timedOut: false);
    }
    return _probe(info, timeout);
  }

  static Future<_ProbeResult> _probe(ServiceInfo info, Duration timeout) async {
    final endpoint = info.endpoint;
    final client = http.Client();
    try {
      final response = await client
          .get(_infoUrl(info.url), headers: endpoint.headers())
          .timeout(timeout);
      if (response.statusCode == 404) {
        return _ProbeResult(
          info: info,
          timedOut: false,
          service: RegisteredService(
            info: info,
            endpoint: endpoint,
            version: info.version,
            state: ServiceState.ready,
            compatible: false,
          ),
        );
      }
      Object? decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = null;
      }
      final version = decoded is Map ? decoded['version'] : null;
      final pid = decoded is Map ? decoded['pid'] : null;
      if (version is! String || pid is! int || pid < 0) {
        return _ProbeResult(info: info, service: null, timedOut: false);
      }
      if (pid != info.pid) {
        return _ProbeResult(info: info, service: null, timedOut: false);
      }
      if (info.version != null && info.version != version) {
        return _ProbeResult(info: info, service: null, timedOut: false);
      }
      final state = response.statusCode >= 200 && response.statusCode < 300
          ? ServiceState.ready
          : response.statusCode == 500
              ? ServiceState.failed
              : ServiceState.waiting;
      return _ProbeResult(
        info: info,
        timedOut: false,
        service: RegisteredService(
          info: info,
          endpoint: endpoint,
          version: version,
          state: state,
          compatible: true,
        ),
      );
    } on TimeoutException {
      return _ProbeResult(info: info, service: null, timedOut: true);
    } on Object {
      return _ProbeResult(info: info, service: null, timedOut: false);
    } finally {
      client.close();
    }
  }

  static Uri _infoUrl(String url) {
    final parsed = Uri.parse(url);
    return parsed.replace(path: '/api/info', query: null, fragment: null);
  }

  // ---------------------------------------------------------------------------
  // Spawning and terminating
  // ---------------------------------------------------------------------------

  static Future<void> _spawn(EnsureOptions options) async {
    final command =
        options.command ?? const <String>['opencode', 'serve', '--service'];
    if (command.isEmpty) {
      throw StateError('Missing service command');
    }
    final handoffEnvironment = await _ptyHandoffEnvironment(options.file);
    try {
      await Process.start(
        command.first,
        command.sublist(1),
        mode: ProcessStartMode.detached,
        environment: <String, String>{
          ...?options.env,
          ...handoffEnvironment,
        },
      );
    } on ProcessException catch (error) {
      throw StateError('Failed to start server: $error');
    }
  }

  static void _kill(int pid, ProcessSignal signal) {
    try {
      Process.killPid(pid, signal);
    } on Object {
      // The process may already be gone.
    }
  }

  static Future<bool> _isStopped(int pid) async {
    if (Platform.isWindows) {
      try {
        final result = await Process.run(
          'tasklist',
          <String>['/FI', 'PID eq $pid', '/NH'],
        );
        return !result.stdout.toString().contains('$pid');
      } on Object {
        return true;
      }
    }
    try {
      final result = await Process.run('kill', <String>['-0', '$pid']);
      return result.exitCode != 0;
    } on Object {
      return true;
    }
  }

  static Future<bool> _waitUntilStopped(
    int pid,
    EnsureOptions options,
  ) async {
    for (var attempt = 0; attempt <= options.stopPollAttempts; attempt++) {
      if (await _isStopped(pid)) return true;
      if (attempt < options.stopPollAttempts) {
        await Future<void>.delayed(options.stopPollInterval);
      }
    }
    return false;
  }

  static Future<void> _terminate(
    ServiceInfo info,
    EnsureOptions options,
  ) async {
    final current = await _readRegistration(options.file);
    if (current == null || !_sameInfo(current, info)) return;
    _kill(info.pid, ProcessSignal.sigterm);
    if (!await _waitUntilStopped(info.pid, options)) {
      _kill(info.pid, ProcessSignal.sigkill);
      if (!await _waitUntilStopped(info.pid, options)) {
        throw StateError('Server process ${info.pid} is still running');
      }
    }
    await _deleteIfSame(options.file, info);
  }

  // ---------------------------------------------------------------------------
  // Persistent terminal handoff
  // ---------------------------------------------------------------------------

  static String _handoffFile(String? file) =>
      '${file ?? _defaultServiceFile()}.pty-handoff';

  static String _defaultServiceFile() {
    final xdg = Platform.environment['XDG_STATE_HOME'];
    if (xdg != null && xdg.isNotEmpty) {
      return p.join(xdg, 'opencode', 'service.json');
    }
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null || home.isEmpty) {
      throw StateError(
        'Cannot resolve the service file: HOME is not set',
      );
    }
    return p.join(home, '.local', 'state', 'opencode', 'service.json');
  }

  static Future<_PtyHandoffRecord?> _readPtyHandoff(String? file) async {
    final handle = File(_handoffFile(file));
    if (!await handle.exists()) return null;
    try {
      final value = jsonDecode(await handle.readAsString());
      if (value is! Map) return null;
      final map = asJsonMap(value);
      final source = map['source'];
      final expiresAt = map['expiresAt'];
      if (source is! Map || expiresAt is! num) return null;
      final sourceMap = asJsonMap(source);
      final pid = sourceMap['pid'];
      final url = sourceMap['url'];
      if (pid is! int || url is! String) return null;
      final id = sourceMap['id'];
      final handoff = map['handoff'];
      if (handoff != null && handoff is! Map) return null;
      return _PtyHandoffRecord(
        sourceID: id is String ? id : null,
        sourcePid: pid,
        sourceUrl: url,
        handoff: handoff is Map ? asJsonMap(handoff) : null,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          expiresAt.toInt(),
          isUtc: true,
        ),
      );
    } on Object {
      return null;
    }
  }

  static bool _sameSource(_PtyHandoffRecord record, ServiceInfo info) =>
      record.sourceID == info.id &&
      record.sourcePid == info.pid &&
      record.sourceUrl == info.url;

  static Future<Map<String, String>> _ptyHandoffEnvironment(
    String? file,
  ) async {
    final record = await _readPtyHandoff(file);
    if (record == null) return const <String, String>{};
    if (!record.expiresAt.isAfter(DateTime.now().toUtc())) {
      return const <String, String>{};
    }
    final current = await _readRegistration(file);
    if (current != null && !_sameSource(record, current)) {
      return const <String, String>{};
    }
    final handoff = record.handoff;
    if (handoff == null) return const <String, String>{};
    return <String, String>{'OPENCODE_PTY_HANDOFF': jsonEncode(handoff)};
  }

  /// Requests a persistent terminal handoff from the registered service and
  /// publishes it for the next spawned service. Best effort: failures leave
  /// the existing handoff file untouched. Mirrors the reference `prepare`.
  static Future<void> _preparePtyHandoff(
    String? file,
    ServiceInfo info,
    EnsureOptions options,
  ) async {
    final existing = await _readPtyHandoff(file);
    if (existing != null &&
        existing.expiresAt.isAfter(DateTime.now().toUtc()) &&
        _sameSource(existing, info)) {
      return;
    }
    final endpoint = info.endpoint;
    final client = http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(info.url).replace(
              path: '/api/experimental/persistent-pty/handoff',
              query: null,
              fragment: null,
            ),
            headers: endpoint.headers(),
          )
          .timeout(options.requestTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body is Map) {
          final handoff = body['handoff'];
          if (handoff is Map) {
            await _publishPtyHandoff(file, info, asJsonMap(handoff));
            return;
          }
          if (handoff == null) {
            await _publishPtyHandoff(file, info, null);
            return;
          }
        }
      }
      throw const FormatException('Invalid handoff response');
    } on Object {
      final concurrent = await _readPtyHandoff(file);
      if (concurrent != null &&
          concurrent.expiresAt.isAfter(DateTime.now().toUtc()) &&
          _sameSource(concurrent, info)) {
        return;
      }
      try {
        await client
            .post(
              Uri.parse(info.url).replace(
                path: '/api/experimental/persistent-pty/shutdown',
                query: null,
                fragment: null,
              ),
              headers: endpoint.headers(),
            )
            .timeout(options.requestTimeout);
      } on Object {
        // Best effort: the service is being replaced anyway.
      }
    } finally {
      client.close();
    }
  }

  static Future<void> _publishPtyHandoff(
    String? file,
    ServiceInfo info,
    JsonMap? handoff,
  ) async {
    final target = _handoffFile(file);
    final temporary = '$target.${DateTime.now().microsecondsSinceEpoch}.tmp';
    final payload = <String, Object?>{
      'source': <String, Object?>{
        'id': info.id,
        'pid': info.pid,
        'url': info.url,
      },
      'handoff': handoff,
      'expiresAt': handoff != null && handoff['expiresAt'] is num
          ? handoff['expiresAt']
          : DateTime.now().toUtc().millisecondsSinceEpoch + 30000,
    };
    try {
      await File(temporary).writeAsString(jsonEncode(payload), flush: true);
      await File(temporary).rename(target);
    } on Object {
      try {
        await File(temporary).delete();
      } on Object {
        // Ignore cleanup failures.
      }
    }
  }

  static Future<void> _completePtyHandoff(
    String? file,
    ServiceInfo info,
  ) async {
    final record = await _readPtyHandoff(file);
    if (record != null && !_sameSource(record, info)) {
      await _clearPtyHandoff(file);
    }
  }

  static Future<void> _clearPtyHandoff(String? file) async {
    try {
      await File(_handoffFile(file)).delete();
    } on Object {
      // Nothing to clear.
    }
  }
}

final class _ProbeResult {
  const _ProbeResult({
    required this.info,
    required this.service,
    required this.timedOut,
  });

  final ServiceInfo? info;
  final RegisteredService? service;
  final bool timedOut;
}

final class _PtyHandoffRecord {
  const _PtyHandoffRecord({
    required this.sourceID,
    required this.sourcePid,
    required this.sourceUrl,
    required this.handoff,
    required this.expiresAt,
  });

  final String? sourceID;
  final int sourcePid;
  final String sourceUrl;
  final JsonMap? handoff;
  final DateTime expiresAt;
}
