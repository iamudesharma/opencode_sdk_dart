/// PTY cause helpers shared by the cockpit terminal services.
///
/// Terminal sockets are consumed through `EffectOpenCodeClient.ptyFrames`, which
/// yields typed [PtyFrame]s: terminal output as [PtyOutput] and resume cursors
/// as [PtyCursor] (including binary cursor markers). These helpers only
/// describe consumer-fiber failures for the UI.
library;

import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';

/// Whether [cause] carries an interruption (possibly combined with cleanup
/// failures), which means the consumer fiber was stopped on purpose.
bool ptyCauseInterrupted(Cause<OpenCodeError> cause) => switch (cause) {
  Interrupted() => true,
  // Cleanup failures follow the primary cause; an interrupted body still
  // means the consumer was stopped on purpose.
  Sequential(:final first) => ptyCauseInterrupted(first),
  _ => false,
};

/// The error a terminal service surfaces for a failed consumer fiber.
///
/// Expected failures keep their typed [OpenCodeError]; defects keep their
/// original object; interruption becomes a [StateError] so the failure stays
/// visible if it ever reaches a status field.
Object ptyCauseError(Cause<OpenCodeError> cause) => switch (cause) {
  Expected(:final error) => error,
  Defect(:final error) => error,
  Interrupted() => StateError('The PTY connection was interrupted'),
  // The body failure is followed by cleanup failures; the body is primary.
  Sequential(:final first) => ptyCauseError(first),
};
