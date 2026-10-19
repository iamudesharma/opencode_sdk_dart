import 'package:effect_core/effect_core.dart';
import 'package:opencode_effect/opencode_effect.dart';
import 'package:test/test.dart';

import 'support/fake_server.dart';

void main() {
  late Runtime<Unit> runtime;

  setUp(() => runtime = Runtime<Unit>(Unit.value));

  OpenCodeEffectConfig configFor(FakeOpenCodeServer server) =>
      OpenCodeEffectConfig(
        baseUrl: Uri.parse('http://fake.opencode'),
        httpClient: server.client,
        clientFactory: () => server.client,
      );

  test('layer provides one client and closes it with the scope', () async {
    final server = FakeOpenCodeServer();
    EffectOpenCodeClient? captured;
    final effect = openCodeClientService.effect<OpenCodeError>().flatMap((
      client,
    ) {
      captured = client;
      return client.call((options) => client.sdk.server.info(options: options));
    });

    final info = await runtime.runFuture(
      withOpenCodeClient(effect, config: configFor(server)),
    );
    expect(info.version, '1.2.3');
    expect(captured, isNotNull);
    expect(server.infoCalls, 1);

    // The scope is closed: the client's event multiplexer is disposed and a
    // new subscription fails immediately.
    final exit = await runtime.runExit(
      captured!.events<Unit>().take(1).runCollect(),
    );
    expect(exit.expectedError, isA<OpenCodeStreamError>());
  });

  test('layer memoizes the client across dependencies in one scope', () async {
    final server = FakeOpenCodeServer();
    final effect = openCodeClientService.effect<OpenCodeError>().flatMap(
      (first) => openCodeClientService.effect<OpenCodeError>().flatMap(
        (second) => Effect.sync(() => identical(first, second)),
      ),
    );

    final identicalClients = await runtime.runFuture(
      withOpenCodeClient(effect, config: configFor(server)),
    );
    expect(identicalClients, isTrue);
  });

  test('two runs acquire independent clients', () async {
    final server = FakeOpenCodeServer();
    final seen = <EffectOpenCodeClient>[];
    final effect = openCodeClientService.effect<OpenCodeError>().flatMap(
      (client) => Effect.sync(() => seen.add(client)),
    );

    await runtime.runFuture(
      withOpenCodeClient(effect, config: configFor(server)),
    );
    await runtime.runFuture(
      withOpenCodeClient(effect, config: configFor(server)),
    );
    expect(seen.length, 2);
    expect(identical(seen[0], seen[1]), isFalse);
  });
}
