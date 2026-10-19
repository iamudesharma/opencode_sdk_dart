// Copyright 2026 The genkit_opencode_custom authors.
// SPDX-License-Identifier: MIT

import 'package:effect_core/effect_core.dart' as effect;
import 'package:genkit/plugin.dart';
import 'package:genkit_opencode_custom/src/errors.dart';
import 'package:opencode_effect/opencode_effect.dart' as bridge;
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart' as sdk;
import 'package:test/test.dart';

void main() {
  group('openCodeError over the effect bridge', () {
    test('keeps the HTTP status and the decoded SDK exception', () {
      final api = sdk.OpenCodeStatusException(
        statusCode: 429,
        message: 'slow down',
      )..attachStatusCode(429);

      final mapped = openCodeError(bridge.OpenCodeApiError(api));

      expect(mapped.status, StatusCode.resourceExhausted);
      expect(mapped.message, 'slow down');
      expect(mapped.cause, same(api));
    });

    test('maps transport failures to UNAVAILABLE', () {
      final cause = sdk.OpenCodeTransportException(
        StateError('connection refused'),
      );

      final mapped = openCodeError(bridge.OpenCodeTransportError(cause));

      expect(mapped.status, StatusCode.unavailable);
      expect(mapped.message, contains('connection refused'));
      expect(mapped.cause, same(cause));
    });

    test('maps execution failures to INTERNAL', () {
      final mapped = openCodeError(
        bridge.OpenCodeExecutionFailed(
          sdk.OpenCodeExecutionException('the turn failed'),
        ),
      );

      expect(mapped.status, StatusCode.internal);
      expect(mapped.message, 'the turn failed');
    });

    test('maps service failures to UNAVAILABLE with the reason', () {
      final mapped = openCodeError(
        bridge.OpenCodeServiceError(
          'Could not discover the local OpenCode service',
          cause: StateError('spawn failed'),
        ),
      );

      expect(mapped.status, StatusCode.unavailable);
      expect(mapped.message, contains('Could not discover'));
      expect(mapped.cause, isA<StateError>());
    });

    test('maps interruption to CANCELLED', () {
      final mapped = openCodeCauseError(const effect.Interrupted());

      expect(mapped.status, StatusCode.cancelled);
    });

    test('unwraps an EffectException cause', () {
      final exitCause = effect.Expected(
        bridge.OpenCodeCallCancelled(sdk.OpenCodeCancelledException()),
      );

      final mapped = openCodeError(effect.EffectException(exitCause));

      expect(mapped.status, StatusCode.cancelled);
    });

    test('passes GenkitException through untouched', () {
      final original = GenkitException('nope', status: StatusCode.notFound);

      expect(identical(openCodeError(original), original), isTrue);
    });
  });
}
