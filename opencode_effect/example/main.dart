// ignore_for_file: avoid_print
import 'dart:io';

import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

/// End-to-end tour of the effect bridge against the local OpenCode service.
///
/// Run with `dart run example/main.dart` from `opencode_effect/`; the service
/// is discovered (or started) automatically, so no configuration is needed.
///
/// The whole program is one effect: the layer acquires the client when the
/// program starts and releases it (HTTP pool + event connection) when the
/// program — or an interruption — finishes. Reads compose `withReadRetry()`;
/// the prompt turn is a write and is never retried.
Future<void> main() async {
  final runtime = Runtime<Unit>(Unit.value);
  try {
    final program = openCodeClientService.effect<OpenCodeError>().flatMap(
      _tour,
    );
    await runtime.runOpenCode(withOpenCodeClient(program));
  } finally {
    await runtime.shutdown();
  }
}

Effect<Unit, OpenCodeError, Context> _tour(EffectOpenCodeClient client) {
  return client
      .call<ServerInfo, Context>(
        (options) => client.sdk.server.info(options: options),
      )
      .withReadRetry()
      .flatMap((info) {
        print('Connected to OpenCode ${info.version} (pid ${info.pid})');
        print('URLs: ${info.urls.join(', ')}');
        return client
            .call<LocatedResponse<List<AgentInfo>>, Context>(
              (options) => client.sdk.agent.list(options: options),
            )
            .withReadRetry();
      })
      .flatMap((agents) {
        print('Agents: ${agents.data.map((agent) => agent.name).join(', ')}');
        // A write: single-shot, never retried.
        return client.call<SessionInfo, Context>(
          (options) => client.sdk.session.create(
            title: 'opencode_effect example',
            options: options,
          ),
        );
      })
      .flatMap((session) {
        print('Created session ${session.id}');
        return client.runTurn<Context>(
          sessionID: session.id,
          text: 'In one short sentence, what is the OpenCode SDK?',
          onEvent: (event) {
            switch (event) {
              case SessionTurnTextDelta(:final delta):
                stdout.write(delta);
              case SessionTurnReasoningDelta(:final delta):
                stderr.write(delta);
              case SessionTurnStepUsage(:final usage):
                print('\n[step done: ${usage.totalTokens} tokens so far]');
              case SessionTurnCompleted():
                break;
            }
          },
        );
      })
      .flatMap((result) {
        print('\nAnswer: ${result.text}');
        print('Total tokens: ${result.usage.totalTokens}');
        return client
            .call<SessionsResponse, Context>(
              (options) => client.sdk.session.list(
                limit: '3',
                order: SessionListOrder.desc,
                options: options,
              ),
            )
            .withReadRetry();
      })
      .map((sessions) {
        print('Recent sessions:');
        for (final session in sessions.data) {
          print('  ${session.title ?? '(untitled)'}');
        }
        return Unit.value;
      });
}
