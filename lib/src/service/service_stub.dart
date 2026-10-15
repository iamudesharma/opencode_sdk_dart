/// Background service discovery on platforms without process support.
///
/// The web has no access to the local process table or registration file, so
/// [OpenCodeService] only supports [OpenCodeService.headers]; the remaining
/// members throw [UnsupportedError].
library;

import 'service_endpoint.dart';

/// Entry point for background service management.
///
/// On the web, discovery, spawning, and stopping are unsupported. Connect to a
/// reachable OpenCode server directly instead.
abstract final class OpenCodeService {
  /// Unsupported on the web.
  static Future<ServiceEndpoint?> discover({
    EnsureOptions options = const EnsureOptions(),
  }) {
    throw UnsupportedError(
      'Local service discovery is not supported on this platform',
    );
  }

  /// Unsupported on the web.
  static Future<ServiceEndpoint> ensure({
    EnsureOptions options = const EnsureOptions(),
  }) {
    throw UnsupportedError(
      'Local service management is not supported on this platform',
    );
  }

  /// Unsupported on the web.
  static Future<void> stop({
    EnsureOptions options = const EnsureOptions(),
  }) {
    throw UnsupportedError(
      'Local service management is not supported on this platform',
    );
  }

  /// Creates the authentication headers for [endpoint].
  static Map<String, String> headers(ServiceEndpoint endpoint) =>
      endpoint.headers();

  /// Unsupported on the web.
  static String defaultFile() {
    throw UnsupportedError(
      'Local service discovery is not supported on this platform',
    );
  }
}
