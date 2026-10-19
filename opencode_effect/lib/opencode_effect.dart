/// Effect-based adapter for `opencode_sdk_dart`, built on `effect_core`.
///
/// The bridge turns every OpenCode SDK operation into a lazy, typed,
/// interruptible effect with one sealed error family ([OpenCodeError]):
///
/// * [EffectOpenCodeClient.call] binds any generated resource method;
/// * [EffectOpenCodeClient.events] / [EffectOpenCodeClient.turnStream] are pull
///   streams with scope-bound cancellation;
/// * [openCodeClientLayer] owns the client lifetime as a scoped resource;
/// * [discoverOpenCodeService] and friends manage the local background
///   service;
/// * [withReadRetry] retries transient read failures with an effect
///   [Schedule].
///
/// ```dart
/// import 'package:effect_core/effect_core.dart';
/// import 'package:opencode_effect/opencode_effect.dart';
/// import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
///
/// Future<void> main() async {
///   final runtime = Runtime<Unit>(Unit.value);
///   final effect = openCodeClientService
///       .effect<OpenCodeError>()
///       .flatMap(
///         (client) => client
///             .read((options) => client.sdk.server.info(options: options))
///             .map((info) => 'OpenCode ${info.version}'),
///       );
///   final version = await runtime.runFuture(withOpenCodeClient(effect));
///   print(version);
///   await runtime.shutdown();
/// }
/// ```
library;

export 'src/call.dart';
export 'src/client.dart';
export 'src/errors.dart';
export 'src/layer.dart';
