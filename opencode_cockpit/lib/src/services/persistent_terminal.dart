import 'dart:async';

import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';
import 'package:xterm/xterm.dart';

/// Attaches to ONE persistent terminal (server-side session) and feeds an
/// xterm emulator. Detaching does not kill the server-side terminal.
///
/// The persistent PTY WebSocket streams terminal output as text frames and
/// resume cursors as binary frames. [attach] resumes from [cursor] when
/// reconnecting; [detach] only closes the socket, so the server keeps the
/// terminal (and its scrollback) alive until the user explicitly kills it.
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
  StreamSubscription<PtyFrame>? _frames;
  bool _connecting = false;
  int _generation = 0;

  /// Attaches to [info], connecting the WebSocket and streaming output.
  ///
  /// [takeover] steals an existing attachment and [attachmentID] re-attaches
  /// to a known one. Resume from [cursor] when reconnecting. A second call
  /// while attached or connecting is ignored. Failures are reported through
  /// [status] and [error]; this method never throws.
  Future<void> attach(
    OpenCodeClient client,
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
    try {
      final socket = await client.persistentPty.connectSocket(
        ptyID: info.id,
        cursor: cursor > 0 ? '$cursor' : null,
        takeover: takeover,
        attachmentID: attachmentID,
      );
      if (generation != _generation) {
        // Detached while the socket was still connecting.
        await socket.close();
        return;
      }
      _connecting = false;
      _socket = socket;
      terminal.onOutput = sendInput;
      _frames = socket.frames.listen(
        applyFrame,
        onDone: () => _handleDone(generation),
        onError: (Object failure, StackTrace _) =>
            _handleError(generation, failure),
      );
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

  /// Closes the socket without touching the server-side terminal.
  Future<void> detach() async {
    _generation++;
    _connecting = false;
    terminal.onOutput = null;
    final frames = _frames;
    _frames = null;
    final socket = _socket;
    _socket = null;
    await frames?.cancel();
    await socket?.close();
    if (status != PersistentTerminalStatus.failed) {
      status = PersistentTerminalStatus.detached;
    }
    _notify();
  }

  /// Applies one frame — public and unit-testable (cursor vs output).
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

  void _handleDone(int generation) {
    if (generation != _generation) return;
    // A socket error is usually followed by `done`; keep the failure visible.
    if (status == PersistentTerminalStatus.failed) return;
    _socket = null;
    terminal.onOutput = null;
    terminal.write('\r\n\x1b[2m[detached]\x1b[0m\r\n');
    status = PersistentTerminalStatus.detached;
    _notify();
  }

  void _handleError(int generation, Object failure) {
    if (generation != _generation) return;
    _socket = null;
    terminal.onOutput = null;
    status = PersistentTerminalStatus.failed;
    error = '$failure';
    _notify();
  }

  void _notify() => onChanged?.call();
}

/// Attachment lifecycle for the UI.
enum PersistentTerminalStatus { detached, connecting, attached, failed }
