import 'dart:async';

import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:xterm/xterm.dart';

import 'pty_frames.dart';

/// Owns one PTY session plus its terminal emulation state.
///
/// The OpenCode PTY protocol (verified against a live server):
///
/// * `POST /api/pty` creates the session for a location;
/// * the WebSocket streams **text** frames with shell output and **binary**
///   frames carrying `{"cursor":<offset>}` resume markers;
/// * input is sent back as text frames;
/// * viewport size is updated through `PUT /api/pty/{id}` (scoped to the same
///   location), debounced here;
/// * reconnecting with the last cursor resumes output without duplication.
///
/// All server work runs as interruptible effects: the socket is acquired with
/// `Effect.acquireUseRelease`, its text is consumed by a forked fiber
/// (`ptyFrames`), and the release (`ptyClose`) runs whenever the fiber stops —
/// including interruption from [restart], [dispose], or an enclosing
/// teardown, so a socket can never outlive its consumer.
class TerminalSession {
  TerminalSession({this.maxLines = 10000}) {
    terminal = Terminal(
      maxLines: maxLines,
      onOutput: (data) => _socket?.sendInput(data),
      onResize: (width, height, _, _) => _scheduleResize(width, height),
    );
  }

  final int maxLines;

  /// The xterm emulator rendered by the UI.
  late final Terminal terminal;

  EffectOpenCodeClient? _client;
  Runtime<Unit>? _runtime;
  LocationRef? _location;
  PtySocket? _socket;
  Fiber<Unit, OpenCodeError>? _consumer;
  int _generation = 0;

  /// The PTY session id, when one exists.
  PtyID? ptyID;

  /// Byte offset of the last emitted output, used to resume.
  int cursor = 0;

  /// Lifecycle state for the UI.
  TerminalStatus status = TerminalStatus.idle;

  /// Human readable failure, when [status] is [TerminalStatus.failed].
  String? error;

  var _resizeTimer = Timer(Duration.zero, () {});
  int _pendingCols = 80;
  int _pendingRows = 24;
  var _disposed = false;

  /// Starts a new shell for [location].
  Future<void> start(
    EffectOpenCodeClient client,
    Runtime<Unit> runtime, {
    required LocationRef location,
    String? title,
    String? command,
  }) async {
    await _teardownSocket();
    _client = client;
    _runtime = runtime;
    _location = location;
    cursor = 0;
    status = TerminalStatus.starting;
    error = null;
    try {
      if (ptyID == null) {
        final created = await runtime.runOpenCode(
          client.call(
            (options) => client.sdk.pty.create(
              location: location,
              title: title ?? 'cockpit',
              command: command,
              options: options,
            ),
          ),
        );
        ptyID = created.data.id;
      }
      await _connect(resume: false);
    } on OpenCodeApiError catch (failure) {
      // The typed bridge error preserves the server message, exactly like the
      // `OpenCodeApiException` caught before the migration.
      _setFailure(failure.message);
    } on Object catch (failure) {
      _setFailure('$failure');
    }
  }

  Future<void> _connect({required bool resume}) async {
    final client = _client;
    final runtime = _runtime;
    final id = ptyID;
    if (client == null || runtime == null || id == null || _disposed) return;
    final generation = ++_generation;
    final ready = Completer<void>();
    final fiber = runtime.fork(
      Effect.acquireUseRelease<PtySocket, Unit, OpenCodeError, Unit>(
        client.ptyConnect(
          ptyID: id,
          cursor: resume ? cursor : null,
          location: _location,
        ),
        (socket) {
          _socket = socket;
          terminal.onOutput = sendInput;
          if (resume) {
            terminal.write('\r\n\x1b[2m[reconnected]\x1b[0m\r\n');
          }
          status = TerminalStatus.running;
          unawaited(_notify());
          _scheduleResize(_pendingCols, _pendingRows);
          if (!ready.isCompleted) ready.complete();
          return client
              .ptyFrames<Unit>(socket)
              .runForEach(
                (frame) => Effect.sync<Unit, OpenCodeError, Unit>(() {
                  _applyFrame(frame);
                  return Unit.value;
                }),
              );
        },
        (socket, _) => client.ptyClose<Unit>(socket),
      ).scoped(),
    );
    _consumer = fiber;
    unawaited(
      fiber.awaitExit().then(
        (exit) => _handleConsumerExit(generation, ready, exit),
      ),
    );
    await ready.future;
  }

  void _handleConsumerExit(
    int generation,
    Completer<void> ready,
    Exit<Unit, OpenCodeError> exit,
  ) {
    if (!ready.isCompleted) {
      // Failed before the socket was wired: [start]/[restart] reports it.
      ready.completeError(switch (exit) {
        Success() => StateError('The PTY connection ended before it opened'),
        Failure(:final cause) => ptyCauseError(cause),
      });
      return;
    }
    if (_disposed || generation != _generation) return;
    _consumer = null;
    switch (exit) {
      case Success():
        _socket = null;
        terminal.onOutput = null;
        terminal.write('\r\n\x1b[2m[connection closed]\x1b[0m\r\n');
        status = TerminalStatus.exited;
        unawaited(_notify());
      case Failure(:final cause):
        if (ptyCauseInterrupted(cause)) return; // Teardown owns the state.
        _socket = null;
        terminal.onOutput = null;
        status = TerminalStatus.failed;
        error = '${ptyCauseError(cause)}';
        unawaited(_notify());
    }
  }

  void _applyFrame(PtyFrame frame) {
    switch (frame) {
      case PtyCursor(:final cursor):
        this.cursor = cursor;
      case PtyOutput(:final data):
        terminal.write(data);
    }
  }

  void _setFailure(String message) {
    if (_disposed) return;
    status = TerminalStatus.failed;
    error = message;
  }

  /// Callback invoked whenever [status] changes.
  Future<void> Function()? onStatusChanged;

  Future<void> _notify() async {
    final callback = onStatusChanged;
    if (callback != null) await callback();
  }

  /// Restarts the shell, resuming from the last cursor.
  Future<void> restart() async {
    final client = _client;
    final runtime = _runtime;
    if (client == null || runtime == null) return;
    await _teardownSocket();
    status = TerminalStatus.starting;
    await _notify();
    try {
      await _connect(resume: true);
    } on Object catch (failure) {
      if (_disposed) return;
      status = TerminalStatus.failed;
      error = '$failure';
      await _notify();
    }
  }

  /// Recreates the PTY from scratch (used after the shell exits).
  Future<void> recreate() async {
    final client = _client;
    final runtime = _runtime;
    if (client == null || runtime == null) return;
    await _teardownSocket();
    ptyID = null;
    terminal.write('\x1b[2J\x1b[H');
    await start(client, runtime, location: _location ?? const LocationRef());
  }

  /// Sends raw terminal input.
  void sendInput(String data) => _socket?.sendInput(data);

  void _scheduleResize(int cols, int rows) {
    _pendingCols = cols;
    _pendingRows = rows;
    _resizeTimer.cancel();
    _resizeTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(_pushResize());
    });
  }

  Future<void> _pushResize() async {
    final client = _client;
    final runtime = _runtime;
    final id = ptyID;
    if (client == null || runtime == null || id == null) return;
    try {
      await runtime.runOpenCode(
        client.call(
          (options) => client.sdk.pty.update(
            ptyID: id,
            location: _location,
            size: PtyUpdateInputSize(rows: _pendingRows, cols: _pendingCols),
            options: options,
          ),
        ),
      );
    } on OpenCodeApiError {
      // Resizing is best effort; the session may have exited.
    }
  }

  Future<void> _teardownSocket() async {
    terminal.onOutput = null;
    _generation++;
    final consumer = _consumer;
    _consumer = null;
    _socket = null;
    // Interrupting the fiber runs the socket release (`ptyClose`).
    await consumer?.interruptAndAwait();
  }

  /// Terminates the PTY process and releases the socket.
  Future<void> dispose() async {
    _disposed = true;
    _resizeTimer.cancel();
    await _teardownSocket();
    final client = _client;
    final runtime = _runtime;
    final id = ptyID;
    if (client != null && runtime != null && id != null) {
      try {
        await runtime.runOpenCode(
          client.call(
            (options) => client.sdk.pty.remove(
              ptyID: id,
              location: _location,
              options: options,
            ),
          ),
        );
      } on Object {
        // Best effort cleanup: the shell may already be gone, or an enclosing
        // teardown may be closing the client at the same time.
      }
    }
    ptyID = null;
  }
}

/// Terminal lifecycle for the UI.
enum TerminalStatus { idle, starting, running, exited, failed }
