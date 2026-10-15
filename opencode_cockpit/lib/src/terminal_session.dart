import 'dart:async';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:xterm/xterm.dart';

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

  OpenCodeClient? _client;
  LocationRef? _location;
  PtySocket? _socket;
  StreamSubscription<PtyFrame>? _frames;

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
    OpenCodeClient client, {
    required LocationRef location,
    String? title,
    String? command,
  }) async {
    await _teardownSocket();
    _client = client;
    _location = location;
    cursor = 0;
    status = TerminalStatus.starting;
    error = null;
    try {
      if (ptyID == null) {
        final created = await client.pty.create(
          location: location,
          title: title ?? 'cockpit',
          command: command,
        );
        ptyID = created.data.id;
      }
      await _connect(resume: false);
    } on OpenCodeApiException catch (failure) {
      status = TerminalStatus.failed;
      error = failure.message;
    } on Object catch (failure) {
      status = TerminalStatus.failed;
      error = '$failure';
    }
  }

  Future<void> _connect({required bool resume}) async {
    final client = _client;
    final id = ptyID;
    if (client == null || id == null) return;
    final socket = await client.pty.connectSocket(
      ptyID: id,
      cursor: resume ? cursor : null,
      location: _location,
    );
    _socket = socket;
    if (resume) {
      terminal.write('\r\n\x1b[2m[reconnected]\x1b[0m\r\n');
    }
    _frames = socket.frames.listen(
      (frame) {
        switch (frame) {
          case PtyCursor(:final cursor):
            this.cursor = cursor;
          case PtyOutput(:final data):
            terminal.write(data);
        }
      },
      onDone: () {
        if (_disposed) return;
        terminal.write('\r\n\x1b[2m[connection closed]\x1b[0m\r\n');
        status = TerminalStatus.exited;
        terminal.onOutput = null;
        unawaited(_notify());
      },
      onError: (Object failure, StackTrace stackTrace) {
        if (_disposed) return;
        status = TerminalStatus.failed;
        error = '$failure';
        unawaited(_notify());
      },
    );
    status = TerminalStatus.running;
    unawaited(_notify());
    _scheduleResize(_pendingCols, _pendingRows);
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
    if (client == null) return;
    await _teardownSocket();
    status = TerminalStatus.starting;
    await _notify();
    try {
      await _connect(resume: true);
    } on Object catch (failure) {
      status = TerminalStatus.failed;
      error = '$failure';
      await _notify();
    }
  }

  /// Recreates the PTY from scratch (used after the shell exits).
  Future<void> recreate() async {
    final client = _client;
    if (client == null) return;
    await _teardownSocket();
    ptyID = null;
    terminal.write('\x1b[2J\x1b[H');
    await start(client, location: _location ?? const LocationRef());
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
    final id = ptyID;
    if (client == null || id == null) return;
    try {
      await client.pty.update(
        ptyID: id,
        location: _location,
        size: PtyUpdateInputSize(rows: _pendingRows, cols: _pendingCols),
      );
    } on OpenCodeApiException {
      // Resizing is best effort; the session may have exited.
    }
  }

  Future<void> _teardownSocket() async {
    terminal.onOutput = null;
    await _frames?.cancel();
    _frames = null;
    await _socket?.close();
    _socket = null;
  }

  /// Terminates the PTY process and releases the socket.
  Future<void> dispose() async {
    _disposed = true;
    _resizeTimer.cancel();
    await _teardownSocket();
    final client = _client;
    final id = ptyID;
    if (client != null && id != null) {
      try {
        await client.pty.remove(ptyID: id, location: _location);
      } on OpenCodeApiException {
        // Already gone.
      }
    }
    ptyID = null;
  }
}

/// Terminal lifecycle for the UI.
enum TerminalStatus { idle, starting, running, exited, failed }
