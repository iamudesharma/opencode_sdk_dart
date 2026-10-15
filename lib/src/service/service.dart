/// Local background service management with platform-aware availability.
library;

export 'service_endpoint.dart';
export 'service_stub.dart' if (dart.library.io) 'service_io.dart';
