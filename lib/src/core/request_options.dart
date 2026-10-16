/// Per-request options, cancellation, and location references.
library;

import 'dart:async';

import 'json_utils.dart';
import 'retry.dart';

/// Identifies the working directory ("location") an operation targets.
///
/// Passing a [LocationRef] with a directory pins the call to that directory;
/// passing one without a directory (or omitting the option entirely) follows
/// the server default, matching the `location[directory]` query parameter of
/// the OpenCode HTTP API.
///
/// This type is also used for the wire shape `Location.PublicRef` returned by
/// the server.
final class LocationRef {
  /// Creates a reference to [directory], or to the server default when
  /// [directory] is omitted.
  const LocationRef([this.directory]);

  /// Creates a reference to a concrete directory.
  const LocationRef.directory(String this.directory);

  /// Decodes a `Location.PublicRef` payload.
  factory LocationRef.fromJson(Object? json) {
    final map = asJsonMap(json);
    final directory = map['directory'];
    return LocationRef(
      directory == null
          ? null
          : asJsonString(directory, path: 'location.directory'),
    );
  }

  /// The absolute directory path, when pinned.
  final String? directory;

  /// Encodes this reference to JSON, omitting an absent directory.
  JsonMap toJson() => <String, Object?>{
        if (directory != null) 'directory': directory,
      };

  @override
  bool operator ==(Object other) =>
      other is LocationRef && other.directory == directory;

  @override
  int get hashCode => directory.hashCode;

  @override
  String toString() =>
      directory == null ? 'LocationRef()' : 'LocationRef(${directory!})';
}

/// A cooperative cancellation token for in-flight requests and streams.
///
/// Call [cancel] to abort every request that received this token. Cancelled
/// requests complete with an `OpenCodeCancelledException`.
final class CancellationToken {
  bool _cancelled = false;
  final List<void Function()> _listeners = <void Function()>[];

  /// Whether [cancel] has been called.
  bool get isCancelled => _cancelled;

  /// Cancels the token and notifies every listener.
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    final listeners = List<void Function()>.of(_listeners);
    _listeners.clear();
    for (final listener in listeners) {
      listener();
    }
  }

  /// Registers a listener that fires once when the token is cancelled.
  ///
  /// When the token is already cancelled the listener fires synchronously.
  void addListener(void Function() listener) {
    if (_cancelled) {
      listener();
      return;
    }
    _listeners.add(listener);
  }

  /// Removes a previously registered listener.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// A future that completes when the token is cancelled.
  Future<void> get whenCancelled {
    if (_cancelled) return Future<void>.value();
    final completer = Completer<void>();
    addListener(completer.complete);
    return completer.future;
  }
}

/// Options accepted by every API call.
final class RequestOptions {
  const RequestOptions({
    this.location,
    this.headers,
    this.cancelToken,
    this.retry,
  });

  /// The working directory this request targets, when a specific one is
  /// needed. Omit to use the server default location.
  final LocationRef? location;

  /// Additional headers for this call, overriding client defaults and
  /// operation headers with the same name.
  final Map<String, String>? headers;

  /// Aborts the request when cancelled.
  final CancellationToken? cancelToken;

  /// Overrides the transport's [RetryPolicy] for this call.
  final RetryPolicy? retry;

  @override
  String toString() =>
      'RequestOptions(location: $location, headers: $headers, '
      'retry: $retry)';
}
