import 'dart:async';

import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:xterm/xterm.dart';

import '../pty_frames.dart';

/// Attaches to ONE persistent terminal (server-side session) and feeds an
/// xterm emulator. Detaching does not kill the server-side terminal.
///
/// The persistent PTY WebSocket streams terminal output as text frames and
/// resume cursors as binary frames. [attach] resumes from [cursor] when
/// reconnecting; [detach] only closes the socket, so the server keeps the
/// terminal (and its scrollback) alive until the user explicitly kills it.
///
/// The attachment is one forked effect fiber: the socket is acquired with
/// `Effect.acquireUseRelease`, consumed through `ptyFrames`, and released with
/// `ptyClose` when [detach] (or a controller teardown) interrupts the fiber.
class PersistentTerminalSession {
  PersistentTerminalSession({this.maxLines = 10000})
    : terminal = Terminal(maxLines: maxLines) {
    terminal.onResize = (cols, rows, _, _) => resize(cols, rows);
  }

  /// Frame encoder for the negotiated `input_protocol=1` channel.
  final PtyInputFrames inputFrames = PtyInputFrames();

  /// Scrollback limit of the emulator.
  final int maxLines;

  /// The xterm emulator rendered by the UI.
  final Terminal terminal;

  /// Metadata of the terminal currently attached to, when known.
  PersistentPtyInfo? info;

  /// Lifecycle state for the UI.
  PersistentTerminalStatus status = PersistentTerminalStatus.detached;

  /// Human readable failure, when [status] is [PersistentTerminalStatus.failed].
  String? error;

  /// Byte offset of the last emitted output, used to resume.
  int cursor = 0;

  /// Invoked whenever [status], [error] or [cursor] change.
  void Function()? onChanged;

  PtySocket? _socket;
  Fiber<Unit, OpenCodeError>? _consumer;
  bool _connecting = false;
  int _generation = 0;

  /// Attaches to [info], connecting the WebSocket and streaming output.
  ///
  /// [takeover] steals an existing attachment and [attachmentID] re-attaches
  /// to a known one. Resume from [cursor] when reconnecting. A second call
  /// while attached or connecting is ignored. Failures are reported through
  /// [status] and [error]; this method never throws.
  Future<void> attach(
    EffectOpenCodeClient client,
    Runtime<Unit> runtime,
    PersistentPtyInfo info, {
    bool takeover = false,
    String? attachmentID,
  }) async {
    if (_connecting || _socket != null) return;
    if (this.info?.id != info.id) cursor = 0;
    final generation = ++_generation;
    this.info = info;
    _connecting = true;
    error = null;
    status = PersistentTerminalStatus.connecting;
    _notify();
    final ready = Completer<void>();
    final fiber = runtime.fork(
      Effect.acquireUseRelease<PtySocket, Unit, OpenCodeError, Unit>(
        client.persistentPtyConnect(
          ptyID: info.id,
          cursor: cursor > 0 ? '$cursor' : null,
          takeover: takeover,
          attachmentID: attachmentID,
        ),
        (socket) {
          _connecting = false;
          _socket = socket;
          terminal.onOutput = sendInput;
          if (!ready.isCompleted) ready.complete();
          return client
              .ptyFrames<Unit>(socket)
              .runForEach(
                (frame) => Effect.sync<Unit, OpenCodeError, Unit>(() {
                  applyFrame(frame);
                  return Unit.value;
                }),
              );
        },
        (socket, _) {
          if (identical(_socket, socket)) _socket = null;
          return client.ptyClose<Unit>(socket);
        },
      ).scoped(),
    );
    _consumer = fiber;
    unawaited(
      fiber.awaitExit().then(
        (exit) => _handleConsumerExit(generation, ready, exit),
      ),
    );
    try {
      await ready.future;
      if (generation != _generation) return;
      status = PersistentTerminalStatus.attached;
      _notify();
    } on Object catch (failure) {
      if (generation != _generation) return;
      _connecting = false;
      status = PersistentTerminalStatus.failed;
      error = '$failure';
      _notify();
    }
  }

  void _handleConsumerExit(
    int generation,
    Completer<void> ready,
    Exit<Unit, OpenCodeError> exit,
  ) {
    if (!ready.isCompleted) {
      // Failed before the socket was wired: [attach] reports it.
      ready.completeError(switch (exit) {
        Success() => StateError('The terminal attachment ended before opening'),
        Failure(:final cause) => ptyCauseError(cause),
      });
      return;
    }
    if (generation != _generation) return;
    _consumer = null;
    switch (exit) {
      case Success():
        // A socket error is usually followed by `done`; keep the failure
        // visible (the server-side terminal lives on either way).
        if (status == PersistentTerminalStatus.failed) return;
        _socket = null;
        terminal.onOutput = null;
        terminal.write('\r\n\x1b[2m[detached]\x1b[0m\r\n');
        status = PersistentTerminalStatus.detached;
        _notify();
      case Failure(:final cause):
        if (ptyCauseInterrupted(cause)) return; // [detach] owns the state.
        _socket = null;
        terminal.onOutput = null;
        status = PersistentTerminalStatus.failed;
        error = '${ptyCauseError(cause)}';
        _notify();
    }
  }

  /// Closes the socket without touching the server-side terminal.
  Future<void> detach() async {
    _generation++;
    _connecting = false;
    terminal.onOutput = null;
    final consumer = _consumer;
    _consumer = null;
    _socket = null;
    // Interrupting the fiber runs the socket release (`ptyClose`).
    await consumer?.interruptAndAwait();
    if (status != PersistentTerminalStatus.failed) {
      status = PersistentTerminalStatus.detached;
    }
    _notify();
  }

  /// Applies one typed frame from the socket's effect stream ([ptyFrames]).
  void applyFrame(PtyFrame frame) {
    switch (frame) {
      case PtyCursor(:final cursor):
        this.cursor = cursor;
        _notify();
      case PtyOutput(:final data):
        terminal.write(data);
    }
  }

  /// Renders a snapshot's plain text into the terminal (used after detach or
  /// for previews). Does not clear previous content by default.
  void applySnapshotText(String text) => terminal.write(text);

  /// Sends raw input to the terminal, framed for `input_protocol=1`.
  void sendInput(String data) => _socket?.send(inputFrames.input(data));

  /// Sends a resize control frame (atomic with the current input size).
  void resize(int cols, int rows) {
    if (cols <= 0 || rows <= 0) return;
    if (inputFrames.cols == cols && inputFrames.rows == rows) return;
    final frame = inputFrames.resize(cols: cols, rows: rows);
    _socket?.send(frame);
  }

  void _notify() => onChanged?.call();
}

/// Attachment lifecycle for the UI.
enum PersistentTerminalStatus { detached, connecting, attached, failed }
