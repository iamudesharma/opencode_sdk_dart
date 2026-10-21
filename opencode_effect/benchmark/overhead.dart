// ignore_for_file: avoid_print
import 'package:effect_core/effect_core.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// Measures the effect bridge's per-call overhead relative to the plain SDK.
///
/// Two modes:
///
/// * default — in-process `MockClient`, no network: this isolates the
///   framework cost (interpreter frames, per-run cancellation token, error
///   mapping) from transport time;
/// * `--live` — read-only `GET /api/info` against the discovered local
///   service: the realistic end-to-end picture, where HTTP dominates.
///
/// Run from the `opencode_effect/` directory:
///
/// ```sh
/// dart run benchmark/overhead.dart          # 5000 iterations, in-process
/// dart run benchmark/overhead.dart 200 --live
/// ```
Future<void> main(List<String> arguments) async {
  final live = arguments.contains('--live');
  final numbers = arguments.where((a) => !a.startsWith('--')).toList();
  final iterations = numbers.isEmpty ? 5000 : int.parse(numbers.first);

  if (live) {
    await _runLive(iterations);
  } else {
    await _runInProcess(iterations);
  }
}

Future<void> _runInProcess(int iterations) async {
  final mock = MockClient((request) async => _serverInfoResponse);
  final sdk = OpenCodeClient(
    baseUrl: Uri.parse('http://bench.local:1234'),
    httpClient: mock,
    clientFactory: () => mock,
  );
  final client = EffectOpenCodeClient(sdk);
  final runtime = Runtime<Unit>(Unit.value);

  Future<ServerInfo> raw() async => sdk.server.info();
  Future<ServerInfo> bridged() => runtime.runOpenCode(
    client.call<ServerInfo, Unit>(
      (options) => sdk.server.info(options: options),
    ),
  );

  // Warm-up so JIT compilation does not skew the first samples.
  for (var i = 0; i < 500; i++) {
    await raw();
    await bridged();
  }

  final rawStats = await _measure(iterations, raw);
  final bridgeStats = await _measure(iterations, bridged);
  _report('in-process (MockClient, no network)', rawStats, bridgeStats);
  await runtime.shutdown();
}

Future<void> _runLive(int iterations) async {
  final endpoint = await OpenCodeService.discover();
  if (endpoint == null) {
    print('No local OpenCode service is registered; skipping the live run.');
    return;
  }
  final sdk = OpenCodeClient(
    baseUrl: endpoint.url,
    headers: OpenCodeService.headers(endpoint),
  );
  sdk.transport.retry = null;
  final client = EffectOpenCodeClient(sdk);
  final runtime = Runtime<Unit>(Unit.value);

  Future<ServerInfo> raw() async => sdk.server.info();
  Future<ServerInfo> bridged() => runtime.runOpenCode(
    client.call<ServerInfo, Unit>(
      (options) => sdk.server.info(options: options),
    ),
  );
  // Same effect machinery with the supported pooled mode: `abortable: false`
  // skips the per-run token, so the SDK keeps using its shared HTTP client.
  Future<ServerInfo> bridgedShared() => runtime.runOpenCode(
    client.call<ServerInfo, Unit>(
      (options) => sdk.server.info(options: options),
      abortable: false,
    ),
  );

  for (var i = 0; i < 20; i++) {
    await raw();
    await bridged();
    await bridgedShared();
  }

  final rawStats = await _measure(iterations, raw);
  final bridgeStats = await _measure(iterations, bridged);
  final sharedStats = await _measure(iterations, bridgedShared);
  _report('live (GET /api/info, ${endpoint.url})', rawStats, bridgeStats);
  _report('live, shared client (no per-call token)', rawStats, sharedStats);
  client.close();
  await runtime.shutdown();
}

final http.Response _serverInfoResponse = http.Response(
  '{"version":"2.0.99","pid":1,"urls":["http://bench.local:1234"],'
  '"paths":{"tmp":"/tmp"}}',
  200,
  headers: {'content-type': 'application/json'},
);

Future<_Stats> _measure(
  int iterations,
  Future<ServerInfo> Function() call,
) async {
  final samples = <int>[];
  final total = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    final watch = Stopwatch()..start();
    await call();
    watch.stop();
    samples.add(watch.elapsedMicroseconds);
  }
  total.stop();
  samples.sort();
  return _Stats(
    // Mean from the outer wall clock (no per-call timer overhead).
    total.elapsedMicroseconds / iterations,
    samples[samples.length ~/ 2],
    samples[(samples.length * 95) ~/ 100],
  );
}

void _report(String label, _Stats raw, _Stats bridged) {
  final delta = bridged.meanUs - raw.meanUs;
  final percent = raw.meanUs == 0 ? 0.0 : delta / raw.meanUs * 100;
  print('mode        : $label');
  print(
    'raw SDK     : ${raw.meanUs.toStringAsFixed(1)} us/call '
    '(median ${raw.medianUs} us, p95 ${raw.p95Us} us)',
  );
  print(
    'via bridge  : ${bridged.meanUs.toStringAsFixed(1)} us/call '
    '(median ${bridged.medianUs} us, p95 ${bridged.p95Us} us)',
  );
  print(
    'overhead    : ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} us/call '
    '(${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%)',
  );
}

final class _Stats {
  const _Stats(this.meanUs, this.medianUs, this.p95Us);

  /// Mean microseconds per call, from wall-clock totals.
  final double meanUs;

  /// Median microseconds per call.
  final int medianUs;

  /// 95th percentile microseconds per call.
  final int p95Us;
}
