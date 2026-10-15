/// Data types for the local OpenCode background service.
library;

import 'dart:convert';

import '../core/json_utils.dart';

/// Lifecycle state of a registered service instance.
enum ServiceState {
  /// Responds to health probes and can be reused.
  ready,

  /// Reachable but not finished starting.
  waiting,

  /// Started and reported a failure.
  failed,
}

/// Authentication for a service endpoint.
final class ServiceAuth {
  const ServiceAuth({
    required this.username,
    required this.password,
  });

  /// Basic auth user name. OpenCode registers `opencode`.
  final String username;

  /// The generated password.
  final String password;
}

/// A reachable service endpoint plus its credentials.
final class ServiceEndpoint {
  const ServiceEndpoint({required this.url, this.auth});

  /// The base URL of the service.
  final Uri url;

  /// Credentials, when the service requires authentication.
  final ServiceAuth? auth;

  /// The authorization headers for this endpoint, as the reference client
  /// produces them.
  Map<String, String> headers() {
    final auth = this.auth;
    if (auth == null) return const <String, String>{};
    final encoded =
        base64.encode(utf8.encode('${auth.username}:${auth.password}'));
    return <String, String>{'authorization': 'Basic $encoded'};
  }

  @override
  String toString() => 'ServiceEndpoint($url)';
}

/// The registration record written to `service.json`.
final class ServiceInfo {
  const ServiceInfo({
    required this.url,
    required this.pid,
    this.id,
    this.version,
    this.password,
  });

  /// Parses a registration record, returning `null` when invalid.
  static ServiceInfo? parse(Object? json) {
    if (json is! Map) return null;
    final map = asJsonMap(json);
    final url = map['url'];
    final pid = map['pid'];
    if (url is! String || pid is! int || pid < 0) return null;
    final id = map['id'];
    final version = map['version'];
    final password = map['password'];
    return ServiceInfo(
      url: url,
      pid: pid,
      id: id is String ? id : null,
      version: version is String ? version : null,
      password: password is String ? password : null,
    );
  }

  /// The base URL the service listens on.
  final String url;

  /// The process id of the service.
  final int pid;

  /// A unique instance id.
  final String? id;

  /// The server version.
  final String? version;

  /// The generated password, when authentication is enabled.
  final String? password;

  /// The endpoint derived from this registration.
  ServiceEndpoint get endpoint => ServiceEndpoint(
        url: Uri.parse(url),
        auth: password == null
            ? null
            : ServiceAuth(username: 'opencode', password: password!),
      );

  @override
  String toString() => 'ServiceInfo($url, pid: $pid)';
}

/// A probed registration record.
final class RegisteredService {
  const RegisteredService({
    required this.info,
    required this.endpoint,
    required this.version,
    required this.state,
    required this.compatible,
  });

  /// The raw registration record.
  final ServiceInfo info;

  /// The endpoint to talk to.
  final ServiceEndpoint endpoint;

  /// The version reported by the health endpoint.
  final String? version;

  /// The lifecycle state derived from the health probe.
  final ServiceState state;

  /// Whether the health protocol is understood by this client.
  final bool compatible;

  @override
  String toString() => 'RegisteredService(${info.url}, $state)';
}

/// A version constraint for service compatibility.
sealed class ServiceVersionConstraint {
  const ServiceVersionConstraint();

  /// Matches an exact version string.
  const factory ServiceVersionConstraint.exact(String version) =
      ExactServiceVersion;

  /// Matches any version accepted by [predicate].
  const factory ServiceVersionConstraint.matches(
    bool Function(String) predicate,
  ) = PredicateServiceVersion;

  /// Whether [version] satisfies this constraint.
  bool matches(String? version);
}

/// An exact version constraint.
final class ExactServiceVersion extends ServiceVersionConstraint {
  const ExactServiceVersion(this.version);

  final String version;

  @override
  bool matches(String? candidate) => candidate == version;
}

/// A predicate version constraint.
final class PredicateServiceVersion extends ServiceVersionConstraint {
  const PredicateServiceVersion(this.predicate);

  final bool Function(String version) predicate;

  @override
  bool matches(String? candidate) => candidate != null && predicate(candidate);
}

/// Why the service was started.
enum ServiceStartReason {
  /// No registration file was present.
  missing,

  /// A registered service did not satisfy the version constraint.
  versionMismatch,
}

/// Options for discovering, ensuring, and stopping the background service.
final class EnsureOptions {
  const EnsureOptions({
    this.file,
    this.version,
    this.command,
    this.env,
    this.onStart,
    this.pollInterval = const Duration(milliseconds: 25),
    this.requestTimeout = const Duration(seconds: 2),
    this.promiseTimeout = const Duration(seconds: 120),
    this.spawnDelay = const Duration(seconds: 5),
    this.maxSpawnDelay = const Duration(seconds: 30),
    this.stopPollInterval = const Duration(milliseconds: 50),
    this.stopPollAttempts = 100,
  });

  /// Registration file path. Defaults to the standard location
  /// (`$XDG_STATE_HOME/opencode/service.json` or
  /// `~/.local/state/opencode/service.json`).
  final String? file;

  /// Version constraint the service must satisfy.
  final ServiceVersionConstraint? version;

  /// The command used to start the service.
  /// Defaults to `opencode serve --service`.
  final List<String>? command;

  /// Extra environment variables for a spawned service.
  final Map<String, String>? env;

  /// Called once when the service is started.
  final void Function(ServiceStartReason reason, String? previousVersion)?
      onStart;

  /// Delay between registration poll attempts.
  final Duration pollInterval;

  /// Timeout for a single health probe.
  final Duration requestTimeout;

  /// Overall deadline for [OpenCodeService.ensure].
  final Duration promiseTimeout;

  /// Initial delay before respawning an exited service.
  final Duration spawnDelay;

  /// Upper bound for the respawn delay.
  final Duration maxSpawnDelay;

  /// Poll interval while waiting for a process to stop.
  final Duration stopPollInterval;

  /// Maximum stop poll attempts before escalating.
  final int stopPollAttempts;
}
