import 'dart:async';

import 'package:effect_core/effect_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:http/http.dart' as http;
import 'package:opencode_effect/opencode_effect.dart';
import 'package:opencode_sdk_dart/opencode_sdk_dart.dart';

import 'chat_models.dart';

/// Connection lifecycle of the app.
enum ChatConnection { idle, connecting, connected, failed }

/// Coordinates the OpenCode SDK, session state, and the live event stream.
///
/// OpenCode work runs through `opencode_effect`: a [Runtime] owns the forked
/// fibers (reads, writes and the event consumption), and an
/// [EffectOpenCodeClient] wraps the SDK client. Closing the client plus
/// `Runtime.shutdown()` in [dispose] stops everything the controller started.
class ChatController extends ChangeNotifier {
  /// Creates an unconnected controller; call [connect] to start.
  ///
  /// [clientFactory] is a test seam: when set, the SDK client created by
  /// [connectTo]/[connectLocal] takes every dedicated HTTP client (each
  /// effect-bound request plus the event connection) from it.
  ChatController({this._clientFactory});

  final Runtime<Unit> _runtime = Runtime<Unit>(Unit.value);
  final http.Client Function()? _clientFactory;
  EffectOpenCodeClient? _client;
  StreamSubscription<OpenCodeEvent>? _events;
  Timer? _reconnectTimer;
  Timer? _sessionRefreshDebounce;
  Timer? _notifyTimer;
  bool _notifyPending = false;
  bool _disposed = false;

  ChatConnection connection = ChatConnection.idle;
  String? connectionError;
  String? serverVersion;
  Uri? baseUrl;

  /// Current theme mode; toggled from the header.
  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  /// Sessions ordered newest first.
  List<SessionInfo> sessions = const [];

  /// The session currently shown in the transcript.
  SessionInfo? activeSession;

  /// Transcript of [activeSession].
  List<ChatMessage> messages = const [];

  /// Session ids with a running execution.
  final Set<String> busySessionIDs = <String>{};

  /// Latest usage per session id.
  final Map<String, ({MoneyUSD cost, TokenUsageInfo tokens})> usage = {};

  /// Pending permission requests for the active session.
  List<PermissionRequest> pendingPermissions = const [];

  /// Selectable agents, loaded after connecting.
  List<AgentInfo> agents = const [];

  /// Selectable models, loaded after connecting.
  List<ModelInfo> models = const [];

  /// Whether the transcript for [activeSession] is loading.
  bool loadingMessages = false;

  /// Whether a send request is in flight.
  bool sending = false;

  /// Schedules a listener notification for the end of the current frame.
  ///
  /// Notifications are coalesced: listeners hear about at most one change per
  /// frame (~16 ms), and never after [dispose].
  void _notify() {
    if (_disposed) return;
    _notifyPending = true;
    if (_notifyTimer != null) return;
    _notifyTimer = Timer(const Duration(milliseconds: 16), _flushNotify);
  }

  void _flushNotify() {
    _notifyTimer = null;
    if (_disposed || !_notifyPending) return;
    _notifyPending = false;
    notifyListeners();
  }

  /// Flips between the dark (default) and light themes.
  void toggleThemeMode() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  /// The connected SDK client, or null while unconnected.
  OpenCodeClient? get client => _client?.sdk;

  bool get isConnected => connection == ChatConnection.connected;

  /// Whether the active session is currently executing.
  bool get activeBusy =>
      activeSession != null && busySessionIDs.contains(activeSession!.id);

  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  /// Base URL baked in at build time:
  /// `--dart-define=OPENCODE_BASE_URL=http://192.168.1.20:4096`.
  static const String environmentBaseUrl =
      String.fromEnvironment('OPENCODE_BASE_URL');

  /// Connects to the configured server: the `OPENCODE_BASE_URL` define when
  /// set, the serving origin on the web, and the discovered local service
  /// otherwise.
  Future<void> connectLocal() async {
    if (environmentBaseUrl.isNotEmpty) {
      await connectTo(Uri.parse(environmentBaseUrl));
      return;
    }
    if (kIsWeb) {
      // A LAN host serves this app same-origin and proxies the API with auth
      // injection, so there is nothing to discover.
      await connectTo(Uri.parse(Uri.base.origin));
      return;
    }
    await _connect(discover: true);
  }

  /// Connects to an explicit server [url].
  Future<void> connectTo(Uri url, {Map<String, String>? headers}) async {
    await _connect(url: url, headers: headers, discover: false);
  }

  Future<void> _connect({
    Uri? url,
    Map<String, String>? headers,
    required bool discover,
  }) async {
    await _teardown();
    connection = ChatConnection.connecting;
    connectionError = null;
    _notify();
    try {
      if (discover) {
        final endpoint = await _runtime.runOpenCode(_discoverOrStart());
        url = endpoint.url;
        headers = OpenCodeService.headers(endpoint);
      }
      // Reads retry through `withReadRetry()` on the effect; the SDK's own
      // transport retry stays off so an attempt is never retried twice.
      final sdk = OpenCodeClient(
        baseUrl: url!,
        headers: headers,
        clientFactory: _clientFactory,
      );
      sdk.transport.retry = null;
      final client = EffectOpenCodeClient(sdk);
      _client = client;
      baseUrl = sdk.transport.baseUrl;
      final info = await _runtime.runOpenCode(
        _read(client, (options) => client.sdk.server.info(options: options)),
      );
      serverVersion = info.version;
      connection = ChatConnection.connected;
      debugPrint('OpenCode Chat connected to ${client.sdk.transport.baseUrl} '
          '(v${info.version})');
      _notify();
      _listen();
      await Future.wait<void>([
        refreshSessions(),
        _loadAgentsAndModels(),
      ]);
    } on Object catch (error) {
      connection = ChatConnection.failed;
      connectionError = _describe(error);
      _notify();
    }
  }

  /// Discovers a running local service, starting one when none is registered.
  Effect<ServiceEndpoint, OpenCodeError, Unit> _discoverOrStart() =>
      discoverOpenCodeService<Unit>().flatMap(
        (endpoint) => endpoint == null
            ? ensureOpenCodeService<Unit>()
            : Effect.succeed<ServiceEndpoint, OpenCodeError, Unit>(endpoint),
      );

  /// Binds a read and composes the standard read retry policy.
  ///
  /// Only for idempotent GETs; writes must never retry (a prompt that timed
  /// out may already have been admitted).
  Effect<A, OpenCodeError, Unit> _read<A>(
    EffectOpenCodeClient client,
    Future<A> Function(RequestOptions options) invoke,
  ) => client.call<A, Unit>(invoke).withReadRetry();

  String _describe(Object error) {
    return switch (error) {
      OpenCodeApiError(:final message) => message,
      OpenCodeTransportError(:final reason) =>
        'Cannot reach the server ($reason)',
      OpenCodeDecodeError(:final message) => 'Unexpected response: $message',
      OpenCodeMalformedResponseError(:final message) =>
        'Unexpected response: $message',
      OpenCodeServiceError(:final message) => message,
      _ => '$error',
    };
  }

  void _listen() {
    _events?.cancel();
    final client = _client;
    if (client == null) return;
    // `toNative` runs the pull stream on its own fiber; cancelling the
    // subscription interrupts that fiber and waits for its cleanup.
    _events = client
        .events<Unit>()
        .toNative(_runtime)
        .listen(
          handleEvent,
          onError: (Object error, StackTrace stackTrace) {
            if (_disposed) return;
            connectionError = 'Event stream lost; reconnecting\u2026';
            _notify();
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(const Duration(seconds: 2), () {
              if (_disposed || !isConnected) return;
              connectionError = null;
              _notify();
              _listen();
            });
          },
          onDone: () {
            if (_disposed || !isConnected) return;
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(const Duration(seconds: 2), () {
              if (_disposed || !isConnected) return;
              _listen();
            });
          },
        );
  }

  Future<void> _teardown() async {
    _reconnectTimer?.cancel();
    _sessionRefreshDebounce?.cancel();
    await _events?.cancel();
    _events = null;
    _client?.close();
    _client = null;
    sessions = const [];
    activeSession = null;
    messages = const [];
    busySessionIDs.clear();
    usage.clear();
    pendingPermissions = const [];
    agents = const [];
    models = const [];
  }

  // ---------------------------------------------------------------------------
  // Sessions and messages
  // ---------------------------------------------------------------------------

  Future<void> refreshSessions() async {
    if (_disposed) return;
    final client = _client;
    if (client == null || !isConnected) return;
    try {
      final result = await _runtime.runOpenCode(
        _read(
          client,
          (options) => client.sdk.session.list(
            limit: '60',
            order: SessionListOrder.desc,
            options: options,
          ),
        ),
      );
      sessions = result.data;
      if (activeSession != null) {
        final refreshed = _sessionById(activeSession!.id);
        if (refreshed != null) activeSession = refreshed;
      }
    } on Object {
      // Sidebar refresh failures are non-fatal.
    }
    _notify();
  }

  SessionInfo? _sessionById(String id) {
    for (final session in sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  Future<void> _loadAgentsAndModels() async {
    final client = _client;
    if (client == null) return;
    try {
      final agentResult = await _runtime.runOpenCode(
        _read(client, (options) => client.sdk.agent.list(options: options)),
      );
      agents = agentResult.data;
    } on Object {
      // Agent list is optional.
    }
    try {
      final modelResult = await _runtime.runOpenCode(
        _read(client, (options) => client.sdk.model.list(options: options)),
      );
      models = modelResult.data.where((model) => model.enabled).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } on Object {
      // Model list is optional.
    }
    _notify();
  }

  /// Opens [session] and loads its transcript.
  Future<void> openSession(SessionInfo session) async {
    activeSession = session;
    messages = const [];
    loadingMessages = true;
    _notify();
    await loadMessages();
  }

  /// Reloads the transcript of the active session.
  ///
  /// Server messages are merged with in-flight streaming messages instead of
  /// replacing the list, so a reconcile that races live deltas never drops
  /// text or tool state that has already arrived.
  Future<void> loadMessages() async {
    if (_disposed) return;
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    loadingMessages = true;
    _notify();
    try {
      final response = await _runtime.runOpenCode(
        _read(
          client,
          (options) => client.sdk.session.message.list(
            sessionID: session.id,
            limit: '200',
            options: options,
          ),
        ),
      );
      final loaded = <ChatMessage>[];
      for (final item in response.data) {
        final message = ChatMessage.fromApi(item);
        if (message != null && !message.isEmpty) loaded.add(message);
      }
      if (activeSession?.id == session.id) {
        messages = mergeLoadedMessages(loaded, messages);
      }
    } on Object catch (error) {
      connectionError = _describe(error);
    } finally {
      loadingMessages = false;
      _notify();
    }
  }

  /// Creates a new session and opens it.
  Future<SessionInfo?> newSession() async {
    final client = _client;
    if (client == null || !isConnected) return null;
    try {
      // A POST: the prompt state is created server-side, never retried.
      final session = await _runtime.runOpenCode(
        client.call((options) => client.sdk.session.create(options: options)),
      );
      sessions = [session, ...sessions];
      _notify();
      await openSession(session);
      return session;
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
      return null;
    }
  }

  /// Deletes [sessionID] and clears it from the UI when active.
  Future<void> deleteSession(String sessionID) async {
    final client = _client;
    if (client == null) return;
    try {
      await _runtime.runOpenCode(
        client.call(
          (options) => client.sdk.session.remove(
            sessionID: SessionID(sessionID),
            options: options,
          ),
        ),
      );
    } on Object catch (error) {
      connectionError = _describe(error);
    }
    sessions = [
      for (final session in sessions)
        if (session.id != sessionID) session,
    ];
    if (activeSession?.id == sessionID) {
      activeSession = null;
      messages = const [];
    }
    _notify();
  }

  /// Renames the active session.
  Future<void> renameActiveSession(String title) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    await _runtime.runOpenCode(
      client.call(
        (options) => client.sdk.session.update(
          sessionID: session.id,
          title: title,
          options: options,
        ),
      ),
    );
    activeSession = _copyWithTitle(session, title);
    sessions = [
      for (final candidate in sessions)
        if (candidate.id == session.id) _copyWithTitle(candidate, title) else candidate,
    ];
    _notify();
  }

  static SessionInfo _copyWithTitle(SessionInfo session, String title) {
    final json = session.toJson()..['title'] = title;
    return SessionInfo.fromJson(json);
  }

  /// Switches the agent of the active session.
  Future<void> switchAgent(String agent) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    await _runtime.runOpenCode(
      client.call(
        (options) => client.sdk.session.switchAgent(
          sessionID: session.id,
          agent: AgentID(agent),
          options: options,
        ),
      ),
    );
    await refreshSessions();
  }

  /// Switches the model of the active session.
  Future<void> switchModel(ModelRef model) async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    await _runtime.runOpenCode(
      client.call(
        (options) => client.sdk.session.switchModel(
          sessionID: session.id,
          model: model,
          options: options,
        ),
      ),
    );
    await refreshSessions();
  }

  // ---------------------------------------------------------------------------
  // Prompting
  // ---------------------------------------------------------------------------

  /// Sends [text] to the active session, creating one when needed.
  ///
  /// [files] are attached to the prompt (paths on desktop, LAN-host paths on
  /// the web).
  Future<void> send(
    String text, {
    List<PromptInputFileAttachment> files = const [],
  }) async {
    var session = activeSession;
    if (session == null) {
      session = await newSession();
      if (session == null) return;
    }
    final client = _client;
    if (client == null) return;
    sending = true;
    try {
      // Optimistic echo so the prompt appears immediately. Attachment-only
      // sends echo the file names.
      final echoText = text.isNotEmpty
          ? text
          : files
              .map((file) => file.name ?? file.uri)
              .where((name) => name.isNotEmpty)
              .join(', ');
      final optimistic = ChatMessage(
        id: 'local_${DateTime.now().microsecondsSinceEpoch}',
        role: ChatRole.user,
        time: DateTime.now(),
        text: echoText,
      );
      if (activeSession?.id == session.id) {
        messages = [...messages, optimistic];
        _notify();
      }
      final sentSessionID = session.id;
      // Prompt admission is a write: no retry, so a retried prompt can never
      // be executed twice. Deltas arrive on the shared event subscription;
      // the live transcript is settled from the API when the turn ends.
      await _runtime.runOpenCode(
        client.call(
          (options) => client.sdk.session.prompt(
            sessionID: sentSessionID,
            text: text,
            files: files.isEmpty ? null : files,
            options: options,
          ),
        ),
      );
      // The server admits the message; refresh shortly to replace the echo
      // with the recorded user message. While the turn is still running the
      // live deltas own the transcript and the completion reconcile replaces
      // the list when the step ends, so this refetch is skipped.
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (activeSession?.id == sentSessionID && !activeBusy) {
            return loadMessages();
          }
          return Future<void>.value();
        }),
      );
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
    } finally {
      sending = false;
      _notify();
    }
  }

  /// Interrupts the active session execution.
  Future<void> interrupt() async {
    final client = _client;
    final session = activeSession;
    if (client == null || session == null) return;
    try {
      await _runtime.runOpenCode(
        client.call(
          (options) => client.sdk.session.interrupt(
            sessionID: session.id,
            options: options,
          ),
        ),
      );
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
    }
  }

  /// Replies to a pending permission request.
  Future<void> replyPermission(
    PermissionRequest request,
    PermissionReply decision,
  ) async {
    final client = _client;
    if (client == null) return;
    try {
      await _runtime.runOpenCode(
        client.call(
          (options) => client.sdk.permission.reply(
            sessionID: request.sessionID,
            requestID: request.id,
            decision: decision,
            options: options,
          ),
        ),
      );
      pendingPermissions = [
        for (final candidate in pendingPermissions)
          if (candidate.id != request.id) candidate,
      ];
      _notify();
    } on Object catch (error) {
      connectionError = _describe(error);
      _notify();
    }
  }

  // ---------------------------------------------------------------------------
  // Live events
  // ---------------------------------------------------------------------------

  /// Applies one server event to the UI state.
  @visibleForTesting
  void handleEvent(OpenCodeEvent event) {
    if (_disposed) return;
    final sessionID = event.data['sessionID'];
    final session = sessionID is String ? sessionID : null;
    final isActive = session != null && session == activeSession?.id;

    switch (event.type) {
      case 'server.connected':
        connectionError = null;
        _debounceSessions();
      case 'session.created':
      case 'session.deleted':
      case 'session.renamed':
      case 'session.moved':
      case 'session.agent.selected':
      case 'session.model.selected':
      case 'session.usage.updated':
        if (event.type == 'session.usage.updated' &&
            session != null &&
            event.data['cost'] is num &&
            event.data['tokens'] is Map) {
          usage[session] = (
            cost: MoneyUSD.fromJson(event.data['cost']),
            tokens: TokenUsageInfo.fromJson(
              asJsonMap(event.data['tokens']),
            ),
          );
        }
        _debounceSessions();
      case 'session.execution.started':
        if (session != null) busySessionIDs.add(session);
      case 'session.execution.succeeded':
      case 'session.execution.failed':
      case 'session.execution.interrupted':
        if (session != null) busySessionIDs.remove(session);
        if (isActive) {
          unawaited(loadMessages());
        }
        _debounceSessions();
      case 'session.inbox.delivered':
      case 'session.message.content.updated':
        if (isActive) _debounceMessages();
      case 'session.step.started':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          message
            ..streaming = true
            ..agent = event.data['agent'] as String?
            ..model = switch (event.data['model']) {
              final Map map => ModelRef.fromJson(asJsonMap(map)),
              _ => message.model,
            };
          return message;
        });
      case 'session.step.streamed':
        break;
      case 'session.step.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          message.streaming = false;
          final finish = event.data['finish'];
          if (finish is String) message.finish = finish;
          final cost = event.data['cost'];
          if (cost is num) message.cost = MoneyUSD.fromJson(cost);
          final tokens = event.data['tokens'];
          if (tokens is Map) {
            message.tokens = TokenUsageInfo.fromJson(asJsonMap(tokens));
          }
          for (final part in message.parts) {
            if (part is ChatTextPart) part.done = true;
            if (part is ChatReasoningPart) part.done = true;
          }
          return message;
        });
      case 'session.step.failed':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          message.streaming = false;
          final error = event.data['error'];
          if (error is Map) {
            message.errorMessage = '${error['message'] ?? error}';
          }
          return message;
        });
      case 'session.text.started':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          if (!message.parts.any(
            (part) => part is ChatTextPart && part.ordinal == ordinal,
          )) {
            message.parts.add(ChatTextPart(ordinal: ordinal));
          }
          return message;
        });
      case 'session.text.delta':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          final part = _textPart(message, ordinal);
          part.text += '${event.data['delta'] ?? ''}';
          return message;
        });
      case 'session.text.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          final part = _textPart(message, ordinal);
          final text = event.data['text'];
          if (text is String) part.text = text;
          part.done = true;
          return message;
        });
      case 'session.reasoning.started':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          if (!message.parts.any(
            (part) => part is ChatReasoningPart && part.ordinal == ordinal,
          )) {
            message.parts.add(ChatReasoningPart(ordinal: ordinal));
          }
          return message;
        });
      case 'session.reasoning.delta':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          final part = _reasoningPart(message, ordinal);
          part.text += '${event.data['delta'] ?? ''}';
          return message;
        });
      case 'session.reasoning.ended':
        if (!isActive) return;
        _upsertAssistant(event, (message) {
          final ordinal = _ordinalOf(event);
          final part = _reasoningPart(message, ordinal);
          final text = event.data['text'];
          if (text is String) part.text = text;
          part.done = true;
          return message;
        });
      case 'session.tool.input.started':
        if (!isActive) return;
        _upsertTool(event, create: true, (tool) => tool);
      case 'session.tool.input.delta':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          if (tool.status == ChatToolStatus.streaming) {
            tool.input += '${event.data['delta'] ?? ''}';
          }
          return tool;
        });
      case 'session.tool.input.ended':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          if (tool.status == ChatToolStatus.streaming) {
            final text = event.data['text'];
            if (text is String) tool.input = text;
          }
          return tool;
        });
      case 'session.tool.called':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          tool.status = ChatToolStatus.running;
          final input = event.data['input'];
          if (input is Map) tool.inputJson = asJsonMap(input);
          return tool;
        });
      case 'session.tool.progress':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          final metadata = event.data['metadata'];
          if (metadata is Map) tool.metadata = asJsonMap(metadata);
          return tool;
        });
      case 'session.tool.success':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          tool.status = ChatToolStatus.completed;
          final metadata = event.data['metadata'];
          if (metadata is Map) tool.metadata = asJsonMap(metadata);
          tool.output = _toolOutputPreview(event.data['content']);
          return tool;
        });
      case 'session.tool.failed':
        if (!isActive) return;
        _upsertTool(event, (tool) {
          tool.status = ChatToolStatus.failed;
          final error = event.data['error'];
          tool.error = error is Map ? '${error['message'] ?? error}' : '$error';
          final metadata = event.data['metadata'];
          if (metadata is Map) tool.metadata = asJsonMap(metadata);
          tool.output = _toolOutputPreview(event.data['content']);
          return tool;
        });
      case 'permission.asked':
        if (event.data['id'] is String &&
            !pendingPermissions.any((item) => item.id == event.data['id'])) {
          pendingPermissions = [
            ...pendingPermissions,
            PermissionRequest.fromJson(event.data),
          ];
        }
      case 'permission.replied':
        pendingPermissions = [
          for (final request in pendingPermissions)
            if (request.id != event.data['requestID']) request,
        ];
    }
    // Drop stale permissions from other sessions when switching.
    if (activeSession != null) {
      pendingPermissions = [
        for (final request in pendingPermissions)
          if (request.sessionID == activeSession!.id) request,
      ];
    }
    _notify();
  }

  int _ordinalOf(OpenCodeEvent event) {
    final ordinal = event.data['ordinal'];
    if (ordinal is int) return ordinal;
    if (ordinal is num) return ordinal.toInt();
    return 0;
  }

  ChatMessage _upsertAssistant(
    OpenCodeEvent event,
    ChatMessage Function(ChatMessage message) mutate,
  ) {
    final id = '${event.data['assistantMessageID']}';
    var index = messages.indexWhere((message) => message.id == id);
    if (index == -1) {
      final message = ChatMessage(
        id: id,
        role: ChatRole.assistant,
        time: _eventTime(event),
        streaming: true,
      );
      messages = [...messages, message];
      index = messages.length - 1;
    } else {
      messages = List<ChatMessage>.of(messages);
    }
    messages[index] = mutate(messages[index]);
    return messages[index];
  }

  ChatToolPart _upsertTool(
    OpenCodeEvent event,
    ChatPart Function(ChatToolPart tool) mutate, {
    bool create = false,
  }) {
    final id = '${event.data['id']}';
    _upsertAssistant(event, (message) {
      for (final part in message.parts) {
        if (part is ChatToolPart && part.id == id) {
          mutate(part);
          return message;
        }
      }
      final name = event.data['name'];
      final tool = ChatToolPart(
        id: id,
        name: name is String ? name : 'tool',
      );
      message.parts.add(mutate(tool));
      message.toolCount = message.parts.whereType<ChatToolPart>().length;
      return message;
    });
    final message =
        messages.lastWhere((message) => message.parts.any((p) => p is ChatToolPart && p.id == id));
    return message.parts.firstWhere((p) => p is ChatToolPart && p.id == id)
        as ChatToolPart;
  }

  static String? _toolOutputPreview(Object? content) {
    if (content is! List) return null;
    final decoded = <ToolContent>[];
    for (final item in content) {
      if (item is! Map) continue;
      try {
        decoded.add(ToolContent.fromJson(asJsonMap(item)));
      } on Object {
        // Ignore malformed tool content during streaming.
      }
    }
    if (decoded.isEmpty) return null;
    final preview = toolContentPreview(decoded);
    return preview.isEmpty ? null : preview;
  }

  ChatTextPart _textPart(ChatMessage message, int ordinal) {
    for (final part in message.parts) {
      if (part is ChatTextPart && part.ordinal == ordinal) return part;
    }
    final part = ChatTextPart(ordinal: ordinal);
    message.parts.add(part);
    return part;
  }

  ChatReasoningPart _reasoningPart(ChatMessage message, int ordinal) {
    for (final part in message.parts) {
      if (part is ChatReasoningPart && part.ordinal == ordinal) return part;
    }
    final part = ChatReasoningPart(ordinal: ordinal);
    message.parts.add(part);
    return part;
  }

  static DateTime _eventTime(OpenCodeEvent event) {
    final created = event.raw['created'];
    if (created is num) {
      return DateTime.fromMillisecondsSinceEpoch(created.round());
    }
    return DateTime.now();
  }

  void _debounceSessions() {
    _sessionRefreshDebounce?.cancel();
    _sessionRefreshDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed) refreshSessions();
    });
  }

  void _debounceMessages() {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (!_disposed) return loadMessages();
        return Future<void>.value();
      }),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _notifyTimer?.cancel();
    _notifyTimer = null;
    if (_notifyPending) {
      // Flush a pending UI update before tearing down.
      _notifyPending = false;
      notifyListeners();
    }
    final events = _events;
    _events = null;
    final client = _client;
    _client = null;
    _reconnectTimer?.cancel();
    _sessionRefreshDebounce?.cancel();
    themeMode.dispose();
    unawaited(events?.cancel());
    client?.close();
    // Stops every fiber the controller forked (reads, writes, the event
    // consumption); the client is already closed, so in-flight requests abort.
    unawaited(_runtime.shutdown());
    super.dispose();
  }
}

/// Merges a freshly loaded transcript with in-flight streaming messages.
///
/// The server's record of a turn can lag the live event stream, so replacing
/// the list outright would drop text or tool state that has already arrived.
/// A live streaming message wins over its server version, and one the server
/// has not recorded yet is kept at the end.
@visibleForTesting
List<ChatMessage> mergeLoadedMessages(
  List<ChatMessage> loaded,
  List<ChatMessage> current,
) {
  final live = <String, ChatMessage>{
    for (final message in current)
      if (message.streaming) message.id: message,
  };
  return [
    for (final message in loaded) live.remove(message.id) ?? message,
    ...live.values,
  ];
}
