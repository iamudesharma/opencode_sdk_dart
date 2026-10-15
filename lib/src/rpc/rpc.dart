/// Typed client for OpenCode plugin RPC.
///
/// A plugin exposes custom methods and events from the server. Call methods
/// through [RpcSubClient.call] and subscribe to events through
/// [RpcSubClient.subscribe] or [RpcSubClient.on].
library;

import 'dart:async';

import '../core/errors.dart';
import '../core/events.dart';
import '../core/json_utils.dart';
import '../core/query.dart';
import '../core/request_options.dart';
import '../core/transport.dart';

/// A decoded plugin RPC event.
final class RpcEvent<T> {
  const RpcEvent({
    required this.name,
    required this.type,
    required this.data,
    required this.raw,
    this.location,
  });

  /// The local event name, for example `updated`.
  final String name;

  /// The prefixed wire type, for example `rpc.acme.updated`.
  final String type;

  /// The decoded event payload.
  final T data;

  /// The complete, undecoded JSON payload.
  final JsonMap raw;

  /// The location the event was emitted from, when the server reports one.
  final LocationRef? location;

  @override
  String toString() => 'RpcEvent($type)';
}

/// A subclient bound to a single RPC identifier.
///
/// Create one through `OpenCodeClient.rpc(id)`.
final class RpcSubClient {
  /// Creates a subclient. Prefer `OpenCodeClient.rpc`.
  RpcSubClient({
    required this.id,
    required OpenCodeTransport transport,
    required EventMultiplexer events,
  })  : _transport = transport,
        _events = events;

  /// The RPC identifier as registered by the plugin.
  final String id;

  final OpenCodeTransport _transport;
  final EventMultiplexer _events;

  /// Calls [method] and returns the raw `output` value.
  ///
  /// When the method declares no output, the result is `null`.
  Future<Object?> callJson(
    String method, {
    Object? input,
    RequestOptions? options,
  }) async {
    final result = await _transport.jsonRequest(
      method: 'POST',
      path:
          '/api/rpc/${Uri.encodeComponent(id)}/${Uri.encodeComponent(method)}',
      query: locationQuery(options?.location, options),
      body: <String, Object?>{'input': input},
      successStatus: 200,
      options: options,
    );
    final map = asJsonMap(result, path: 'rpc.$id.$method');
    return map['output'];
  }

  /// Calls [method] and decodes the response with [decode].
  ///
  /// [decode] receives the raw `output` value and should return the typed
  /// result. Declared RPC errors surface as `RpcErrorException` with the
  /// error `type` and `data`; framework failures surface as
  /// `RpcInternalErrorException`.
  Future<O> call<O>(
    String method, {
    Object? input,
    required O Function(Object? output) decode,
    RequestOptions? options,
  }) async {
    final output = await callJson(method, input: input, options: options);
    try {
      return decode(output);
    } on OpenCodeDecodeException catch (error) {
      throw OpenCodeDecodeException(
        error.message,
        path: error.path == null
            ? 'rpc.$id.$method'
            : 'rpc.$id.$method.${error.path}',
      );
    }
  }

  /// Subscribes to [event], decoding each payload with [decode].
  ///
  /// Events are delivered from every location, matching the reference client;
  /// inspect [RpcEvent.location] to filter when needed. Subscriptions are
  /// live-only and share the client's single event connection.
  Stream<RpcEvent<T>> subscribe<T>(
    String event, {
    required T Function(Object? data) decode,
    void Function()? onActivity,
  }) {
    final fullType = 'rpc.$id.$event';
    return _events
        .subscribe(
          onActivity: onActivity,
          filter: (candidate) => candidate.type == fullType,
        )
        .map(
          (candidate) => RpcEvent<T>(
            name: event,
            type: candidate.type,
            data: decode(candidate.data),
            raw: candidate.raw,
            location: candidate.location,
          ),
        );
  }

  /// Registers [listener] for [event] and returns an unsubscribe callback.
  ///
  /// Async listeners are awaited sequentially: the underlying subscription is
  /// paused while [listener] runs. A listener error or source failure ends
  /// this listener.
  void Function() on<T>(
    String event,
    FutureOr<void> Function(RpcEvent<T> event) listener, {
    required T Function(Object? data) decode,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    var closed = false;
    late StreamSubscription<RpcEvent<T>> subscription;
    late void Function() unsubscribe;

    void stop() {
      if (closed) return;
      closed = true;
      unawaited(subscription.cancel());
    }

    unsubscribe = stop;
    subscription = subscribe<T>(event, decode: decode).listen(
      (rpcEvent) {
        if (closed) return;
        subscription.pause();
        unawaited(() async {
          try {
            await listener(rpcEvent);
          } on Object catch (error, stackTrace) {
            onError?.call(error, stackTrace);
            unsubscribe();
          } finally {
            if (!closed) subscription.resume();
          }
        }());
      },
      onError: (Object error, StackTrace stackTrace) {
        onError?.call(error, stackTrace);
        unsubscribe();
      },
      onDone: () => unsubscribe(),
    );

    return unsubscribe;
  }
}
