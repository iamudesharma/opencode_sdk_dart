/// Client lifetime, configuration and local service management as effects.
///
/// [openCodeClientLayer] acquires an [EffectOpenCodeClient] once per enclosing
/// scope and closes it when the scope ends, after every scoped child has
/// stopped. Everything that needs a client only asks for it through
/// [openCodeClientService]:
///
/// ```dart
/// final runtime = Runtime<Unit>(Unit.value);
/// final effect = openCodeClientKey.effect<OpenCodeError>().flatMap(
///   (client) => client.call((options) => client.sdk.server.info(options: options)),
/// );
/// final version = await runtime.runFuture(
///   openCodeClientLayer().use(effect.provide(Unit.value)),
/// );
/// ```
library;

import 'package:effect_core/effect_core.dart';
import 'package:http/http.dart' as http;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'client.dart';
import 'errors.dart';

/// How an [EffectOpenCodeClient] is acquired.
final class OpenCodeEffectConfig {
  /// Creates a configuration.
  ///
  /// Pass [baseUrl] for a known server. When it is omitted, acquisition
  /// performs local service management (discovery, then start) using
  /// [ensure]; on the web that path throws and [baseUrl] is required.
  ///
  /// [headers], [httpClient] and [clientFactory] are forwarded to
  /// `OpenCodeClient` when [baseUrl] is set; [headers] are additionally sent
  /// on every request.
  const OpenCodeEffectConfig({
    this.baseUrl,
    this.headers,
    this.httpClient,
    this.clientFactory,
    this.ensure = const EnsureOptions(),
  });

  /// The server to connect to, or `null` to discover/start the local service.
  final Uri? baseUrl;

  /// Headers sent with every request.
  final Map<String, String>? headers;

  /// Reuses an existing HTTP client (the caller keeps ownership), forwarded
  /// to `OpenCodeClient`.
  final http.Client? httpClient;

  /// Creates a dedicated HTTP client per request when non-null.
  final http.Client Function()? clientFactory;

  /// Options for local service discovery/start when [baseUrl] is `null`.
  final EnsureOptions ensure;
}

/// The service key under which the client layer provides
/// [EffectOpenCodeClient].
final ServiceKey<EffectOpenCodeClient> openCodeClientService =
    ServiceKey<EffectOpenCodeClient>('OpenCodeClient');

/// Acquires an [EffectOpenCodeClient] as a scoped effect.
///
/// With [OpenCodeEffectConfig.baseUrl] set this only constructs the client
/// (no network I/O). Otherwise it discovers the local background service and
/// starts one when none is running. Cancellation after acquisition but before
/// the scope takes ownership closes the client, so nothing leaks.
///
/// Failures: SDK exceptions map to their typed variants; environment failures
/// (process start, platform support) map to [OpenCodeServiceError].
Effect<EffectOpenCodeClient, OpenCodeError, Context> acquireOpenCodeClient(
  OpenCodeEffectConfig config,
) => Effect.asyncExit<EffectOpenCodeClient, OpenCodeError, Context>((
  context,
) async {
  if (context.token.isCancelled) return const Failure(Interrupted());
  try {
    final baseUrl = config.baseUrl;
    final sdk = baseUrl != null
        ? OpenCodeClient(
            baseUrl: baseUrl,
            headers: config.headers,
            httpClient: config.httpClient,
            clientFactory: config.clientFactory,
          )
        : await OpenCodeClient.connectLocal(options: config.ensure);
    if (context.token.isCancelled) {
      sdk.close();
      return const Failure(Interrupted());
    }
    return Success(EffectOpenCodeClient(sdk));
  } on OpenCodeApiException catch (error) {
    return Failure(Expected(OpenCodeApiError(error)));
  } on OpenCodeTransportException catch (error) {
    return Failure(Expected(OpenCodeTransportError(error)));
  } on OpenCodeStreamException catch (error) {
    return Failure(Expected(OpenCodeStreamError(error)));
  } on Object catch (error) {
    return Failure(
      Expected(
        OpenCodeServiceError(
          'Could not acquire an OpenCode client',
          cause: error,
        ),
      ),
    );
  }
});

/// A layer providing an [EffectOpenCodeClient] for an enclosing scope.
///
/// All acquisitions in the scope are memoized (`Layer` semantics), so one
/// client serves every dependency. Closing the scope closes the client:
/// scoped children stop first, then the shared event connection and the HTTP
/// pool are released.
Layer<OpenCodeError> openCodeClientLayer([
  OpenCodeEffectConfig config = const OpenCodeEffectConfig(),
]) => Layer.resource(
  openCodeClientService,
  acquireOpenCodeClient(config),
  (client) =>
      Effect.sync<Object?, OpenCodeError, Context>(() => client.close()),
);

/// Runs [effect] with a client provided by [openCodeClientLayer].
///
/// The returned effect requires no environment ([Unit]): the layer supplies
/// the services and the effect runs inside a scope that closes — releasing
/// the client — when it completes.
///
/// ```dart
/// final runtime = Runtime<Unit>(Unit.value);
/// final version = await runtime.runFuture(
///   withOpenCodeClient(
///     openCodeClientService
///         .effect<OpenCodeError>()
///         .flatMap(
///           (client) => client.call(
///             (options) => client.sdk.server.info(options: options),
///           ),
///         ),
///   ),
/// );
/// ```
Effect<A, OpenCodeError, Unit> withOpenCodeClient<A>(
  Effect<A, OpenCodeError, Context> effect, {
  OpenCodeEffectConfig config = const OpenCodeEffectConfig(),
}) => openCodeClientLayer(config).use(effect).provide(Context());

/// Discovers a running local background service without starting one.
///
/// Resolves `null` when no reachable instance is registered. On the web this
/// fails with [OpenCodeServiceError] (unsupported platform).
Effect<ServiceEndpoint?, OpenCodeError, R> discoverOpenCodeService<R>({
  EnsureOptions options = const EnsureOptions(),
}) => _serviceTask(
  () => OpenCodeService.discover(options: options),
  'Discovery of the local OpenCode service failed',
);

/// Discovers or starts the local background service.
Effect<ServiceEndpoint, OpenCodeError, R> ensureOpenCodeService<R>({
  EnsureOptions options = const EnsureOptions(),
}) => _serviceTask(
  () => OpenCodeService.ensure(options: options),
  'Starting the local OpenCode service failed',
);

/// Stops the exact service instance described by the options/registration.
Effect<Unit, OpenCodeError, R> stopOpenCodeService<R>({
  EnsureOptions options = const EnsureOptions(),
}) => _serviceTask(() async {
  await OpenCodeService.stop(options: options);
  return Unit.value;
}, 'Stopping the local OpenCode service failed');

Effect<A, OpenCodeError, R> _serviceTask<A, R>(
  Future<A> Function() run,
  String failureMessage,
) => Effect.asyncExit<A, OpenCodeError, R>((context) async {
  if (context.token.isCancelled) return const Failure(Interrupted());
  try {
    final value = await run();
    if (context.token.isCancelled) return const Failure(Interrupted());
    return Success(value);
  } on OpenCodeApiException catch (error) {
    return Failure(Expected(OpenCodeApiError(error)));
  } on OpenCodeTransportException catch (error) {
    return Failure(Expected(OpenCodeTransportError(error)));
  } on Object catch (error) {
    return Failure(
      Expected(OpenCodeServiceError(failureMessage, cause: error)),
    );
  }
});
