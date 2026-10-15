/// Event modeling and the shared, lazily connected event multiplexer.
///
/// All event subscriptions created through [EventMultiplexer] share a single
/// upstream connection. Constructing a subscription opens nothing; consuming
/// it starts the connection. Removing the last subscriber closes it. The
/// multiplexer is live-only: a source failure ends current subscriptions and a
/// later subscription establishes a fresh connection.
library;

import 'dart:async';
import 'dart:collection';

import 'errors.dart';
import 'json_utils.dart';
import 'request_options.dart';

/// A single decoded OpenCode event.
///
/// Native events carry their `type` in the payload (for example
/// `session.updated`, `message.updated`, or the `server.connected` marker
/// replayed to late subscribers). Plugin RPC events use the prefixed type
/// `rpc.<rpcID>.<event>`.
final class OpenCodeEvent {
  const OpenCodeEvent({
    required this.type,
    required this.data,
    required this.raw,
    this.location,
  });

  /// Decodes an event payload.
  ///
  /// [fallbackType] is used when the payload does not carry a `type` field.
  factory OpenCodeEvent.fromJson(JsonMap json, {String? fallbackType}) {
    final type = json['type'];
    final data = json['data'];
    final location = json['location'];
    return OpenCodeEvent(
      type: type is String ? type : (fallbackType ?? 'unknown'),
      data: data is Map ? asJsonMap(data) : const <String, Object?>{},
      location: location == null ? null : LocationRef.fromJson(location),
      raw: json,
    );
  }

  /// The event name, for example `session.updated` or `rpc.acme.updated`.
  final String type;

  /// The event payload carried under `data`, when present.
  final JsonMap data;

  /// The location this event belongs to, when the server reports one.
  final LocationRef? location;

  /// The complete, undecoded JSON payload.
  final JsonMap raw;

  /// Whether this is the connection marker sent when a stream subscribes.
  bool get isServerConnected => type == 'server.connected';

  /// For `rpc.<rpcID>.<event>` types, the RPC identifier.
  String? get rpcID {
    if (!type.startsWith('rpc.')) return null;
    final parts = type.split('.');
    return parts.length >= 2 ? parts[1] : null;
  }

  /// For `rpc.<rpcID>.<event>` types, the local event name.
  String? get rpcEvent {
    if (!type.startsWith('rpc.')) return null;
    final parts = type.split('.');
    return parts.length >= 3 ? parts.sublist(2).join('.') : null;
  }

  @override
  String toString() => 'OpenCodeEvent($type)';
}

/// Opens a raw event source. The multiplexer calls this at most once per
/// active connection and cancels [token] to close it.
typedef EventSource = Stream<OpenCodeEvent> Function(
  CancellationToken token,
  void Function() onActivity,
);

/// Shares one lazy event connection between many subscribers.
final class EventMultiplexer {
  /// Creates a multiplexer over [connect].
  EventMultiplexer(this.connect);

  /// The factory used to open the shared connection.
  final EventSource connect;

  _Connection? _current;
  bool _disposed = false;

  /// Whether a shared connection is currently active.
  bool get isConnected => _current != null;

  /// Subscribes to the shared event stream.
  ///
  /// [onActivity] fires for every chunk received from the server while this
  /// subscription is active. [filter] limits which events this subscriber
  /// receives.
  Stream<OpenCodeEvent> subscribe({
    void Function()? onActivity,
    bool Function(OpenCodeEvent event)? filter,
  }) {
    late final StreamController<OpenCodeEvent> controller;
    _Subscriber? subscriber;
    _Connection? connection;
    var listening = false;

    void start() {
      if (_disposed) {
        controller.addError(
          OpenCodeStreamException('The event multiplexer has been disposed'),
        );
        unawaited(controller.close());
        return;
      }
      var active = _current;
      if (active == null) {
        _Connection? created;
        created = _Connection(connect, onClosed: () {
          if (identical(_current, created)) _current = null;
        });
        active = created;
        _current = created;
        created.start();
      }
      connection = active;
      subscriber = active.addSubscriber(
        onActivity: onActivity,
        filter: filter,
      );
      subscriber!.attach(controller);
    }

    controller = StreamController<OpenCodeEvent>(
      onListen: () {
        if (listening) return;
        listening = true;
        start();
      },
      onResume: () => subscriber?.flush(),
      onCancel: () {
        final active = subscriber;
        subscriber = null;
        if (active == null) return;
        connection?.removeSubscriber(active);
      },
    );
    return controller.stream;
  }

  /// Closes the shared connection. Subsequent subscriptions fail.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final current = _current;
    _current = null;
    current?._abort();
  }
}

const int _subscriberCapacity = 4096;

final class _Connection {
  _Connection(this._connect, {required this.onClosed});

  final EventSource _connect;
  final void Function() onClosed;
  final Set<_Subscriber> _subscribers = <_Subscriber>{};
  final CancellationToken _token = CancellationToken();
  OpenCodeEvent? _connectedMarker;
  bool _finished = false;

  void start() {
    unawaited(_run());
  }

  Future<void> _run() async {
    try {
      await for (final event in _connect(_token, _activity)) {
        if (event.isServerConnected) _connectedMarker = event;
        for (final subscriber in List<_Subscriber>.of(_subscribers)) {
          subscriber.push(event);
        }
      }
      _finish(null, null);
    } catch (error, stackTrace) {
      if (_token.isCancelled) {
        _finish(null, null);
      } else {
        _finish(error, stackTrace);
      }
    }
  }

  void _activity() {
    for (final subscriber in List<_Subscriber>.of(_subscribers)) {
      subscriber.onActivity?.call();
    }
  }

  _Subscriber addSubscriber({
    void Function()? onActivity,
    bool Function(OpenCodeEvent event)? filter,
  }) {
    final subscriber = _Subscriber(onActivity: onActivity, filter: filter);
    subscriber.onDetached = () => removeSubscriber(subscriber);
    _subscribers.add(subscriber);
    final marker = _connectedMarker;
    if (marker != null) subscriber.push(marker);
    return subscriber;
  }

  void removeSubscriber(_Subscriber subscriber) {
    if (!_subscribers.remove(subscriber)) return;
    subscriber.detach();
    if (_subscribers.isEmpty && !_finished) {
      _abort();
    }
  }

  void _finish(Object? error, StackTrace? stackTrace) {
    if (_finished) return;
    _finished = true;
    onClosed();
    final subscribers = List<_Subscriber>.of(_subscribers);
    _subscribers.clear();
    for (final subscriber in subscribers) {
      subscriber.finish(error, stackTrace);
    }
  }

  void _abort() {
    _token.cancel();
    _finish(null, null);
  }
}

final class _Subscriber {
  _Subscriber({this.onActivity, this.filter});

  final void Function()? onActivity;
  final bool Function(OpenCodeEvent event)? filter;
  final Queue<OpenCodeEvent> _queue = Queue<OpenCodeEvent>();
  StreamController<OpenCodeEvent>? _controller;
  void Function()? onDetached;
  bool _finished = false;
  bool _detached = false;

  void attach(StreamController<OpenCodeEvent> controller) {
    _controller = controller;
    flush();
  }

  bool _accepts(OpenCodeEvent event) {
    final filter = this.filter;
    if (filter == null) return true;
    return filter(event);
  }

  void push(OpenCodeEvent event) {
    if (_finished || _detached) return;
    if (!_accepts(event)) return;
    final controller = _controller;
    if (controller == null || controller.isPaused) {
      _enqueue(event);
      return;
    }
    controller.add(event);
  }

  void _enqueue(OpenCodeEvent event) {
    if (_queue.length >= _subscriberCapacity) {
      fail(
        OpenCodeStreamException(
          'Event subscriber exceeded its $_subscriberCapacity-event capacity',
        ),
        null,
      );
      return;
    }
    _queue.add(event);
  }

  void flush() {
    final controller = _controller;
    if (controller == null || _finished || _detached) return;
    while (!controller.isPaused && _queue.isNotEmpty) {
      controller.add(_queue.removeFirst());
    }
  }

  void finish(Object? error, StackTrace? stackTrace) {
    if (_finished) return;
    _finished = true;
    final controller = _controller;
    if (controller == null) return;
    if (error != null) {
      controller.addError(error, stackTrace);
    }
    unawaited(controller.close());
  }

  void fail(Object error, StackTrace? stackTrace) {
    if (_finished || _detached) return;
    finish(error, stackTrace);
    detach();
  }

  void detach() {
    if (_detached) return;
    _detached = true;
    _controller = null;
    _queue.clear();
    onDetached?.call();
  }
}
